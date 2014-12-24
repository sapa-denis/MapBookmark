//
//  ForsquareAPI.h
//  MapBookmarks
//
//  Created by Sapa Denys on 24.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface ForsquareAPI : NSObject

+ (void)getNearLocationsNamesForLocation:(CLLocation *)location
								 success:(void (^)(NSArray *locationsNames))handle
								 failure:(void (^)(NSError *error))failure;

@end
