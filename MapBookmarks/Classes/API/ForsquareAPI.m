//
//  ForsquareAPI.m
//  MapBookmarks
//
//  Created by Sapa Denys on 24.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "ForsquareAPI.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>

/*
 https://api.foursquare.com/v2/venues/search?ll=40.7,-74&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&v=YYYYMMDD
 */

static NSString *const kBaseURL = @"https://api.foursquare.com/v2/venues/search";
static NSString *const kClientID = @"SL1J0SGRZIUVM52ZVGG4A1RD4PZG0QG3SKZX52JMURTZTXH3";
static NSString *const kClientSecret = @"RQEJVOGGZXBQIVAP2ZKJWDWRUNM4CCKXFLGY3UEDH153ITLE";

@implementation ForsquareAPI

+ (void)getNearLocationsNamesForLocation:(CLLocation *)location
								 success:(void (^)(NSMutableArray *locationsNames))handle
								 failure:(void (^)(NSError *error))failure
{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

	NSString *coordinate = [NSString stringWithFormat:@"%.3f, %.3f", location.coordinate.latitude, location.coordinate.longitude ];
	NSDictionary *parametrs = @{ @"ll"				: coordinate,
								 @"llAcc"			: @"200.0",
								 @"radius"			: @"250",
								 @"client_id"		: kClientID,
								 @"client_secret"	: kClientSecret,
								 @"v"				: @"20141222"};
	
	[manager GET:kBaseURL
	  parameters:parametrs
		 success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
			 
			 NSMutableArray *result = [NSMutableArray new];
			 NSDictionary *response = [responseObject valueForKey:@"response"];
			 NSArray *venues = [response objectForKey:@"venues"];
			 for (NSDictionary *venue in venues) {
				 NSString *locationName = [venue valueForKey:@"name"];
				 [result addObject:locationName];
			 }
			 
			 [result sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
				 return [obj1 compare:obj2];
			 }];
			 
			 handle(result);
		 }
		 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			 failure(error);
		 }
	 ];

}

@end
