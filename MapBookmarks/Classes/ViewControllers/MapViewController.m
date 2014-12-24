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
#import "Bookmark.h"
#import "BookmarkPointAnnotation.h"
#import "BookmarkDetailsViewController.h"
#import "MKMapView+BookmarkMap.h"


typedef NS_ENUM(NSInteger, MapViewControllerState) {
	MapViewControllerRouteState,
	MapViewControllerBookmarksState
};

@interface MapViewController () <MKMapViewDelegate,
								CLLocationManagerDelegate,
								WYPopoverControllerDelegate,
								SelectDestinationPointViewControllerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *routeBarButton;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableArray *usersBookmarks;

@property (nonatomic, strong) WYPopoverController *destinationsPopoverController;

@property (nonatomic) MapViewControllerState mapViewState;

@end

@implementation MapViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDelegate:self];
		[_locationManager requestAlwaysAuthorization];
		_mapViewState = MapViewControllerBookmarksState;
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
	if (self.mapViewState == MapViewControllerBookmarksState) {
		[self showUsersBookmarks];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[self managedObjectContext] save:nil];
	[self.mapView removeAnnotations:self.mapView.annotations];
}

- (IBAction)putNewBookmark:(UILongPressGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateBegan) {
		CGPoint locationOnView = [sender locationInView:self.mapView];
		CLLocationCoordinate2D coordinateOnMap = [self.mapView convertPoint:locationOnView
													   toCoordinateFromView:self.mapView];
		
		Bookmark *newBookmark = [Bookmark createBookmark];

		CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinateOnMap
															 altitude:10
												   horizontalAccuracy:10
													 verticalAccuracy:10
															timestamp:[NSDate date]];
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
	
	self.mapViewState = MapViewControllerBookmarksState;
	[self.mapView removeOverlays:[self.mapView overlays]];
	[self.mapView mbm_hideUsersBookmarks];
	[self showUsersBookmarks];

	[sender setAction:@selector(routBarButtonTouchUp:)];
	[sender setTarget:self];
}

- (void)routBarButtonTouchUp:(UIBarButtonItem *)sender
{
	[self performSegueWithIdentifier:@"SelectDestinationPointSegue"
							  sender:sender];
}

- (void)drawRoadToLocaton:(CLLocation *)destination
{
	[self.routeBarButton setTitle:@"Clear Route"];
	[self.routeBarButton setAction:@selector(clearRoutBarButtonTouchUp:)];
	[self.routeBarButton setTarget:self];
	
	[self.mapView mbm_hideUsersBookmarks];
	self.mapViewState = MapViewControllerRouteState;
	[self.mapView mbm_calculateRouteToLocation:destination];
}

- (void)centerMapViewForLocation:(CLLocation *)mapCenter
{
	[self.mapView mbm_centerMapViewForLocation:mapCenter];
}

- (void)showUsersBookmarks
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmark"];
	self.usersBookmarks = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
	for (Bookmark *bookmark in self.usersBookmarks) {
		BookmarkPointAnnotation *pointAnnotation = [[BookmarkPointAnnotation alloc] initWithBookmark:bookmark];
		[self.mapView addAnnotation:pointAnnotation];
	}
}

#pragma mark - MKMapViewDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	[self centerMapViewForLocation:userLocation.location];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	return [mapView mbm_viewForAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
	[self performSegueWithIdentifier:@"BookmarkDetails" sender:view];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView
			viewForOverlay:(id)overlay
{
 
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolylineView* polylineView = [[MKPolylineView alloc]initWithPolyline:(MKPolyline*)overlay] ;
		polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
		polylineView.lineWidth = 10;
		return polylineView;
	}
	return nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	[self.locationManager requestWhenInUseAuthorization];
	[self.locationManager startUpdatingLocation];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
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
	} else if ([segue.identifier isEqualToString:@"BookmarkDetails"]) {
		MKAnnotationView *view = sender;
		BookmarkPointAnnotation *annotation = view.annotation;
		BookmarkDetailsViewController *destination = [segue destinationViewController];
		destination.bookmark = annotation.annotationBookmark;
	}
}

@end
