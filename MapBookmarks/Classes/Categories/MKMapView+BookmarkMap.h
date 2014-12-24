//
//  MKMapView+BookmarkMap.h
//  MapBookmarks
//
//  Created by Sapa Denys on 24.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (BookmarkMap)

- (MKAnnotationView *)mbm_viewForAnnotation:(id<MKAnnotation>)annotation;
- (void)mbm_calculateRouteToLocation:(CLLocation *)dest;
- (void)mbm_centerMapViewForLocation:(CLLocation *)mapCenter;
- (void)mbm_hideUsersBookmarks;

@end
