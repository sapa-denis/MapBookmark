//
//  MKMapView+BookmarkMap.m
//  MapBookmarks
//
//  Created by Sapa Denys on 24.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "MKMapView+BookmarkMap.h"

static NSString *const kUserAnnotationIdentifier = @"UserAnnotationViews";
static NSString *const kBookmarkAnnotationIdentifier = @"BookmarkPinAnnotationView";

@implementation MKMapView (BookmarkMap)

- (MKAnnotationView *)mbm_viewForAnnotation:(id<MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		MKAnnotationView *userAnnotationView = (MKAnnotationView*)[self dequeueReusableAnnotationViewWithIdentifier:kUserAnnotationIdentifier];
		if (!userAnnotationView) {
			[[self userLocation] setTitle:@"You are here"];
			userAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
															  reuseIdentifier:kUserAnnotationIdentifier];
			userAnnotationView.canShowCallout = YES;
			userAnnotationView.image = [UIImage imageNamed:@"Arrow"];
			userAnnotationView.centerOffset = CGPointMake(0, userAnnotationView.image.size.height / 2);
			return userAnnotationView;
		}
	} else if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
		MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self dequeueReusableAnnotationViewWithIdentifier:kBookmarkAnnotationIdentifier];
		if (!pinView) {
			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
													  reuseIdentifier:kBookmarkAnnotationIdentifier];
			pinView.canShowCallout = YES;
			pinView.animatesDrop = YES;
			pinView.pinColor = MKPinAnnotationColorGreen;
			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			pinView.rightCalloutAccessoryView = rightButton;
		} else {
			pinView.annotation = annotation;
		}
		return pinView;
	}
	
	return nil;
}

- (void)mbm_calculateRouteToLocation:(CLLocation *)dest
{
	MKPlacemark *source = [[MKPlacemark alloc] initWithCoordinate:[[self userLocation] coordinate]
												addressDictionary:@{ @"": @"" } ];
 
	MKMapItem *srcMapItem = [[MKMapItem alloc] initWithPlacemark:source];
	[srcMapItem setName:@""];
 
	MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:[dest coordinate]
													addressDictionary:@{ @"": @"" } ];
	
	[self addAnnotation:destination];
 
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
		
		MKRoute *rout = [[response routes] firstObject];
		MKPolyline *line = [rout polyline];
		[self addOverlay:line];
	}];
}

- (void)mbm_centerMapViewForLocation:(CLLocation *)mapCenter
{
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapCenter.coordinate, 800, 800);
	[self setRegion:[self regionThatFits:region] animated:YES];
}

- (void)mbm_hideUsersBookmarks
{
	[self removeAnnotations:self.annotations];
}

@end
