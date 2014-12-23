//
//  SelectDestinationPointViewController.m
//  MapBookmarks
//
//  Created by Sapa Denys on 22.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "SelectDestinationPointViewController.h"

@interface SelectDestinationPointViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *destinationPointsTableView;

@end

@implementation SelectDestinationPointViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
//
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	return [self.destinationPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [aTableView dequeueReusableCellWithIdentifier:@"SelectDestinationPointCell"];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectDestinationPointCell"];
	}
	cell.textLabel.text = [[self.destinationPoints objectAtIndex:indexPath.row] description];
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.delegate destinationsPointViewController:self
								 didSelectBookmark:[self.destinationPoints objectAtIndex:indexPath.row]];
}

@end
