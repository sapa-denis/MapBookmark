//
//  MapViewController.m
//  MapBookmarks
//
//  Created by Sapa Denys on 14.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import <WYPopoverController/WYStoryboardPopoverSegue.h>
#import "SelectDestinationPointViewController.h"

#import "AppDelegate.h"
#import "Bookmark.h"

@interface MapViewController () <MKMapViewDelegate,
								CLLocationManagerDelegate,
								WYPopoverControllerDelegate,
								SelectDestinationPointViewControllerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *routeBarButton;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;


@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray *usersBookmarks;

@property (nonatomic, strong) WYPopoverController *destinationsPopoverController;

@end

@implementation MapViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDelegate:self];
		[_locationManager requestAlwaysAuthorization];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[self.locationManager startUpdatingLocation];
	[self.mapView setAutoresizingMask: UIViewAutoresizingFlexibleWidth
									 | UIViewAutoresizingFlexibleHeight];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate respondsToSelector:@selector(managedObjectContext)]) {
		_managedObjectContext = [delegate performSelector:@selector(managedObjectContext)];
	}
	
	[self.locationManager startUpdatingLocation];

//	MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
//	region.center.latitude = self.locationManager.location.coordinate.latitude;
//	region.center.longitude = self.locationManager.location.coordinate.longitude;
	
//	[self centerMapViewForLocation:self.locationManager.location];
	
//	region.span.longitudeDelta = 0.01f;
//	region.span.longitudeDelta = 0.01f;
//	[self.mapView setRegion:region animated:YES];
	
	[self showUsersBookmarks];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[self managedObjectContext] save:nil];
}

- (IBAction)putNewBookmark:(UILongPressGestureRecognizer *)sender
{
	NSLog(@"%ld", sender.state);
	if (sender.state == UIGestureRecognizerStateBegan) {
		CGPoint locationOnView = [sender locationInView:self.mapView];
		CLLocationCoordinate2D coordinateOnMap = [self.mapView convertPoint:locationOnView
													   toCoordinateFromView:self.mapView];
		
		Bookmark *newBookmark = [Bookmark createBookmark];

		CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinateOnMap.latitude
														  longitude:coordinateOnMap.longitude];
		[newBookmark setLocation:location];
		[self.usersBookmarks addObject:newBookmark];
		
		MKPointAnnotation *point = [MKPointAnnotation new];
		[point setCoordinate:coordinateOnMap];
		[point setTitle:newBookmark.locationName];
		[self.mapView addAnnotation:point];
		
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
		}

	}
}

- (void)clearRoutBarButtonTouchUp:(UIBarButtonItem *)sender
{
	[sender setTag:0];
	[sender setTitle:@"Route"];
	[self.mapView removeOverlays:[self.mapView overlays]];
	[self hideUsersBookmarks];
	[self showUsersBookmarks];

	[sender setAction:@selector(routBarButtonTouchUp:)];
	[sender setTarget:self];
}

- (void)routBarButtonTouchUp:(UIBarButtonItem *)sender
{
	[self performSegueWithIdentifier:@"SelectDestinationPointSegue"
							  sender:sender];
}

- (void)calculateRouteToLocation:(CLLocation *)dest
{
	MKPlacemark *source = [[MKPlacemark alloc] initWithCoordinate:[[self.mapView userLocation] coordinate]
												addressDictionary:@{ @"": @"" } ];
 
	MKMapItem *srcMapItem = [[MKMapItem alloc] initWithPlacemark:source];
	[srcMapItem setName:@""];
 
	MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:[dest coordinate]
													addressDictionary:@{ @"": @"" } ];
	
	[self.mapView addAnnotation:destination];
 
	MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
	[distMapItem setName:@""];
 
	MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
	[request setSource:srcMapItem];
	[request setDestination:distMapItem];
	[request setTransportType:MKDirectionsTransportTypeWalking];
 
	MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
 
	[direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
		
		if (error) {
			NSLog(@"Route build error: %@", [error localizedDescription]);
			return;
		}
		NSLog(@"response = %@",response);
		NSArray *arrRoutes = [response routes];
		
		MKRoute *rout = [arrRoutes firstObject];
		MKPolyline *line = [rout polyline];
		[self.mapView addOverlay:line];
	}];
}

- (void)drawRoadToLocaton:(CLLocation *)destination
{
	[self.routeBarButton setTitle:@"Clear Route"];
	[self.routeBarButton setAction:@selector(clearRoutBarButtonTouchUp:)];
	[self.routeBarButton setTarget:self];
	
	[self hideUsersBookmarks];
	[self calculateRouteToLocation:destination];
}

- (void)centerMapViewForLocation:(CLLocation *)mapCenter
{
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapCenter.coordinate, 800, 800);
	[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)showUsersBookmarks
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmark"];
	self.usersBookmarks = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
	for (Bookmark *bookmark in self.usersBookmarks) {
		MKPointAnnotation *point = [MKPointAnnotation new];
		[point setCoordinate:bookmark.location.coordinate];
		[point setTitle:bookmark.locationName];
		[self.mapView addAnnotation:point];
	}
}

- (void)hideUsersBookmarks
{
	[self.mapView removeAnnotations:[self.mapView annotations]];
}

#pragma mark -- MKMapViewDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	[self centerMapViewForLocation:userLocation];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
 
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolylineView* aView = [[MKPolylineView alloc]initWithPolyline:(MKPolyline*)overlay] ;
		aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
		aView.lineWidth = 10;
		return aView;
	}
	return nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	[self.locationManager requestWhenInUseAuthorization];
	[self.locationManager startUpdatingLocation];
	self.location = [locations lastObject];
//	CLLocation *userLocation = [locations lastObject];
//	
//	MKCoordinateSpan span = {.latitudeDelta =  0.1, .longitudeDelta =  0.1};
//	MKCoordinateRegion region = {userLocation.coordinate, span};
//	[self.mapView setRegion:region];
//	[self.mapView setZoomEnabled:YES];
//	[self.mapView setShowsUserLocation:YES];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusAuthorizedAlways ||
		status == kCLAuthorizationStatusAuthorizedWhenInUse) {
		[self.mapView setShowsUserLocation:YES];
	}
}

#pragma mark - WYPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
	return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
	if (controller == self.destinationsPopoverController) {
		self.destinationsPopoverController.delegate = nil;
		self.destinationsPopoverController = nil;
	}
}

#pragma mark - SelectDestinationPointViewControllerDelegate

- (void)destinationsPointViewController:(SelectDestinationPointViewController *)controller
					  didSelectBookmark:(Bookmark *)bookmark
{
	controller.delegate = nil;
	[self.destinationsPopoverController dismissPopoverAnimated:YES];
	self.destinationsPopoverController.delegate = nil;
	self.destinationsPopoverController = nil;
	
	[self drawRoadToLocaton:bookmark.location];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIBarButtonItem *)sender
{
	if ([segue.identifier isEqualToString:@"SelectDestinationPointSegue"])
	{
		WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
		SelectDestinationPointViewController *destinationsController = [segue destinationViewController];
		
		
		destinationsController.destinationPoints = self.usersBookmarks;
		destinationsController.delegate = self;
		destinationsController.preferredContentSize = CGSizeMake(320, 240);
		

		
		self.destinationsPopoverController = [popoverSegue popoverControllerWithSender:sender
													permittedArrowDirections:WYPopoverArrowDirectionDown
																	animated:YES
																	 options:WYPopoverAnimationOptionFadeWithScale];
		self.destinationsPopoverController.delegate = self;
	}
}

@end
