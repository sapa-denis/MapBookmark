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

#import "AppDelegate.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) NSArray* usersBookmarks;

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
	
	
	[self.locationManager startUpdatingLocation];
	[self.mapView setAutoresizingMask: UIViewAutoresizingFlexibleWidth
									 | UIViewAutoresizingFlexibleHeight];
	


}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate performSelector:@selector(managedObjectContext)]) {
		_managedObjectContext = [delegate managedObjectContext];
	}


	
	self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[self.locationManager startUpdatingLocation];

	MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
	region.center.latitude = self.locationManager.location.coordinate.latitude;
	region.center.longitude = self.locationManager.location.coordinate.longitude;
	region.span.longitudeDelta = 0.01f;
	region.span.longitudeDelta = 0.01f;
	[self.mapView setRegion:region animated:YES];
	
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
		
		MKPointAnnotation *point = [MKPointAnnotation new];
		
		[point setCoordinate:coordinateOnMap];
		[self.mapView addAnnotation:point];
		
		NSManagedObject *newBookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark"
															   inManagedObjectContext:self.managedObjectContext];
		
		[newBookmark setValue:@(coordinateOnMap.latitude) forKey:@"latitude"];
		[newBookmark setValue:@(coordinateOnMap.longitude) forKey:@"longitude"];
		
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
		}
	}
}

- (IBAction)routBarButtonTouchUp:(UIBarButtonItem *)sender
{
	if (sender.tag == 0) {
		[sender setTitle:@"Clear Route"];
		[sender setTag:1];
		[self hideUsersBookmarks];
		

		NSManagedObject *bookmark = [self.usersBookmarks lastObject];
		double latitude = [[bookmark valueForKey:@"latitude"] doubleValue];
		double longitude = [[bookmark valueForKey:@"longitude"] doubleValue];

			
		CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];



		
		[self calculateRouteToLocation:destinationLocation];

	} else if (sender.tag == 1) {
		[sender setTag:0];
		[sender setTitle:@"Route"];
		[self.mapView removeOverlays:[self.mapView overlays]];
		[self hideUsersBookmarks];
		[self showUsersBookmarks];
	}
	
}

- (IBAction)bookmarkBarButtonTouchUp:(UIBarButtonItem *)sender
{
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

- (void)showUsersBookmarks
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmark"];
	self.usersBookmarks = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
	for (NSManagedObject *bookmark in self.usersBookmarks) {
		double latitude = [[bookmark valueForKey:@"latitude"] doubleValue];
		double longitude = [[bookmark valueForKey:@"longitude"] doubleValue];
		CLLocationCoordinate2D coordinate = {latitude, longitude};
		
		MKPointAnnotation *point = [MKPointAnnotation new];
		[point setCoordinate:coordinate];
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
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
	[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
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

@end
