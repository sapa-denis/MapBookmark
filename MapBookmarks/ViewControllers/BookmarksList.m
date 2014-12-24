//
//  BookmarksList.m
//  MapBookmarks
//
//  Created by Sapa Denys on 21.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "BookmarksList.h"
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "BookmarkDetailsViewController.h"
#import "Bookmark.h"

@interface BookmarksList ()

@property (nonatomic, strong) NSFetchedResultsController *dataSource;
@property (nonatomic, strong) NSMutableArray *usersBookmarks;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation BookmarksList

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.clearsSelectionOnViewWillAppear = NO;
	self.navigationItem.rightBarButtonItem = self.editButtonItem;

//	_dataSource = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//													  managedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]
//														sectionNameKeyPath:@"latitude" cacheName:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate respondsToSelector:@selector(managedObjectContext)]) {
		_managedObjectContext = [delegate performSelector:@selector(managedObjectContext)];
	}
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmark"];
	self.usersBookmarks = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.usersBookmarks count];
//	id <NSFetchedResultsSectionInfo> sectionInfo = self.dataSource.sections[section];
//	return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell"
															forIndexPath:indexPath];
    
	
	Bookmark *bookmark = [self.usersBookmarks objectAtIndex:indexPath.row];
	cell.textLabel.text = bookmark.locationName;
	cell.detailTextLabel.text = bookmark.location.description;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		Bookmark *bookmarkToDelete = [self.usersBookmarks objectAtIndex:indexPath.row];
		[self.managedObjectContext deleteObject:bookmarkToDelete];
		[self.usersBookmarks removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
		
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
	if ([segue.identifier isEqualToString:@"BookmarkDetails"]) {
		BookmarkDetailsViewController *destination = [segue destinationViewController];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		destination.bookmark = [self.usersBookmarks objectAtIndex:indexPath.row];
	}
}


@end
