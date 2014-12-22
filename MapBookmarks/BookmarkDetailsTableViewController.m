//
//  BookmarkDetailsTableViewController.m
//  MapBookmarks
//
//  Created by Sapa Denys on 21.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "BookmarkDetailsTableViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface BookmarkDetailsTableViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *nearPlacesPickerView;
@end

@implementation BookmarkDetailsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	/*
	https://api.foursquare.com/v2/venues/search?ll=40.7,-74&client_id=CLIENT_ID&client_secret=CLIENT_SECRET&v=YYYYMMDD
	*/
	NSDictionary *parametrs = @{ @"ll"				: @"48.39, 35.03",
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
				 NSLog(@"VANUE: %@", venue);
			 }
		 }
		 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			 NSLog(@"Error: %@", [error localizedDescription]);
		 }
	 ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 1;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
