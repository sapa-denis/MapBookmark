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

@interface BookmarksList () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
//@property (nonatomic, strong) NSMutableArray *usersBookmarks;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation BookmarksList

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.clearsSelectionOnViewWillAppear = NO;
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate respondsToSelector:@selector(managedObjectContext)]) {
		_managedObjectContext = [delegate performSelector:@selector(managedObjectContext)];
	}
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

//- (void)viewWillAppear:(BOOL)animated
//{
//	[super viewWillAppear:animated];
//
//	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmark"];
//	self.usersBookmarks = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
//}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell"
															forIndexPath:indexPath];
	
	
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
		  atIndexPath:(NSIndexPath *)indexPath
{
	Bookmark *bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = bookmark.locationName;
	cell.detailTextLabel.text = bookmark.location.description;
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
		
		Bookmark *bookmarkToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[self.managedObjectContext deleteObject:bookmarkToDelete];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
 
	UITableView *tableView = self.tableView;
 
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath]
					atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
 
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
	if ([segue.identifier isEqualToString:@"BookmarkDetails"]) {
		BookmarkDetailsViewController *destination = [segue destinationViewController];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		destination.bookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
}

#pragma mark - CoreData

- (NSFetchedResultsController *)fetchedResultsController {
 
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
 
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription
								   entityForName:@"Bookmark" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
							  initWithKey:@"locationName" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
 
	[fetchRequest setFetchBatchSize:20];
 
	NSFetchedResultsController *theFetchedResultsController =
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
												   cacheName:nil];
	self.fetchedResultsController = theFetchedResultsController;
	_fetchedResultsController.delegate = self;
 
	return _fetchedResultsController;
 
}


@end
