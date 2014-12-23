//
//  BookmarkDetailsTableViewController.m
//  MapBookmarks
//
//  Created by Sapa Denys on 21.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "BookmarkDetailsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "Bookmark.h"
#import "MapViewController.h"

@interface BookmarkDetailsViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *nearPlacesPickerView;

@property (weak, nonatomic) IBOutlet UILabel *bookmarkNameLabel;

@property (nonatomic, strong) NSMutableArray *nearestLocations;
@end

@implementation BookmarkDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_nearestLocations = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.bookmarkNameLabel.text = self.bookmark.locationName;
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	/*
	https://api.foursquare.com/v2/venues/search?ll=40.7,-74&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&v=YYYYMMDD
	*/
	CLLocation *location = self.bookmark.location;
	
	NSString *coordinate = [NSString stringWithFormat:@"%.3f, %.3f", location.coordinate.latitude, location.coordinate.longitude ];
	NSDictionary *parametrs = @{ @"ll"				: coordinate,
								 @"llAcc"			: @"200.0",
								 @"radius"			: @"250",
								 @"client_id"		: @"SL1J0SGRZIUVM52ZVGG4A1RD4PZG0QG3SKZX52JMURTZTXH3",
								 @"client_secret"	: @"RQEJVOGGZXBQIVAP2ZKJWDWRUNM4CCKXFLGY3UEDH153ITLE",
								 @"v"				: @"20141222"};
	
	[manager GET:@"https://api.foursquare.com/v2/venues/search"
	  parameters:parametrs
		 success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {

			 NSDictionary *response = [responseObject valueForKey:@"response"];
			 NSArray *venues = [response objectForKey:@"venues"];
			 for (NSDictionary *venue in venues) {

				 NSString *locationName = [venue valueForKey:@"name"];
				 CLLocationDegrees latitude = [[[venue valueForKey:@"location"] valueForKey:@"lat"] doubleValue];
				 CLLocationDegrees longitude = [[[venue valueForKey:@"location"] valueForKey:@"lng"] doubleValue];
				 CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
//				 NSArray *imageInfo = [[venue valueForKey:@"categories"] valueForKey:@"icon"];
//				 NSMutableString *imageUrl = [[NSMutableString alloc] initWithString:[[imageInfo  firstObject]
//																					  valueForKey:@"prefix"]];
//				 [imageUrl appendString:[[imageInfo lastObject] valueForKey:@"suffix"]];
//				 NSLog(@"%@", imageUrl);
				 
/*				 Bookmark *newLocation = [Bookmark createBookmark];
				 [newLocation setLocationName:locationName];
				 [newLocation setLocation:location];
*/
				 [self.nearestLocations addObject:locationName];
				 
			 }
			 
			 [self.nearPlacesPickerView reloadAllComponents];
		 }
		 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			 NSLog(@"Error: %@", [error localizedDescription]);
		 }
	 ];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	NSManagedObjectContext *context;
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate respondsToSelector:@selector(managedObjectContext)]) {
		context = [delegate performSelector:@selector(managedObjectContext)];
	}
	
	NSError *error = nil;
	if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

- (IBAction)trashButtonTouchUp:(id)sender
{
	NSManagedObjectContext *context;
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate respondsToSelector:@selector(managedObjectContext)]) {
		context = [delegate performSelector:@selector(managedObjectContext)];
	}
	[context deleteObject:self.bookmark];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)centerOnMapButtonTouchUp:(UIButton *)sender
{
	MapViewController *mapViewController = [[self.navigationController viewControllers] firstObject];
	[mapViewController centerMapViewForLocation:self.bookmark.location];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)buildRouteButtonTouchUp:(id)sender
{
	MapViewController *mapViewController = [[self.navigationController viewControllers] firstObject];
	[mapViewController drawRoadToLocaton:self.bookmark.location];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.nearestLocations count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [self.nearestLocations objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	self.bookmark.named = YES;
	self.bookmark.locationName = [self.nearestLocations objectAtIndex:row];
	self.bookmarkNameLabel.text = self.bookmark.locationName;
}

@end
