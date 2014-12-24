//
//  BookmarkDetailsTableViewController.m
//  MapBookmarks
//
//  Created by Sapa Denys on 21.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "BookmarkDetailsViewController.h"

#import "Bookmark.h"
#import "MapViewController.h"
#import <SAMHUDView/SAMHUDView.h>
#import "ForsquareAPI.h"

@interface BookmarkDetailsViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) IBOutlet UIPickerView *nearPlacesPickerView;
@property (nonatomic, weak) IBOutlet UILabel *bookmarkNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *loadPlacesButton;
@property (nonatomic, strong) NSMutableArray *nearbyPlaces;
@property (nonatomic, strong) SAMHUDView *hud;

@end

@implementation BookmarkDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_nearbyPlaces = [NSMutableArray new];
	
	_hud = [[SAMHUDView alloc] initWithTitle:@"Loading…" loading:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.bookmarkNameLabel.text = self.bookmark.locationName;
	if (self.bookmark.isNamed) {
		[self.loadPlacesButton setHidden:NO];
		[self.nearPlacesPickerView setHidden:YES];
	} else {
		[self.loadPlacesButton setHidden:YES];
		[self.nearPlacesPickerView setHidden:NO];
		[self loadNearbyPlaces];
	}
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
- (IBAction)loadPlacesButtonTouchUp:(id)sender
{
	[self loadPlacesButton];
}

- (void)loadNearbyPlaces
{
	self.view.backgroundColor = [UIColor grayColor];
	[self.hud show];
	
	[ForsquareAPI getNearLocationsNamesForLocation:self.bookmark.location
										   success:^(NSArray *locationsNames) {
											   self.nearbyPlaces = [locationsNames copy];
											   [self dismissHud];
											   [self.loadPlacesButton setHidden:YES];
											   [self.nearPlacesPickerView setHidden:NO];
											   [self.nearPlacesPickerView reloadAllComponents];
										   }
										   failure:^(NSError *error) {
											   [self dismissHud];
											   NSLog(@"Error: %@", [error localizedDescription]);
										   }];
}

- (void)dismissHud
{
	self.view.backgroundColor = [UIColor whiteColor];
	[self.hud dismissAnimated:YES];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.nearbyPlaces count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [self.nearbyPlaces objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	self.bookmark.named = YES;
	self.bookmark.locationName = [self.nearbyPlaces objectAtIndex:row];
	self.bookmarkNameLabel.text = self.bookmark.locationName;
}

@end
