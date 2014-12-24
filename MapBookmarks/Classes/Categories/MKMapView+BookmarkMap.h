//
//  MKMapView+BookmarkMap.h
//  MapBookmarks
//
//  Created by Sapa Denys on 24.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (BookmarkMap)

- (MKAnnotationView *)pinViewForAnnotation:(id<MKAnnotation>)annotation;
- (void)calculateRouteToLocation:(CLLocation *)dest;
- (void)centerMapViewForLocation:(CLLocation *)mapCenter;
- (void)hideUsersBookmarks;

@end
