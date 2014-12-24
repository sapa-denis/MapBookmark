//
//  MapViewController.h
//  MapBookmarks
//
//  Created by Sapa Denys on 14.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLLocation;

@interface MapViewController : UIViewController

- (void)drawRoadToLocaton:(CLLocation *)destination;
- (void)centerMapViewForLocation:(CLLocation *)mapCenter;

@end
