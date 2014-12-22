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
#import "AppDelegate.h"

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
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bookmark"];
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate performSelector:@selector(managedObjectContext)]) {
		_managedObjectContext = [delegate managedObjectContext];
	}
	
	self.usersBookmarks = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];

//	_dataSource = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//													  managedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]
//														sectionNameKeyPath:@"latitude" cacheName:nil];
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
    
	cell.textLabel.text = @"Bookmark";
	
	NSManagedObject *bookmark = [self.usersBookmarks objectAtIndex:indexPath.row];
	double latitude = [[bookmark valueForKey:@"latitude"] doubleValue];
	double longitude = [[bookmark valueForKey:@"longitude"] doubleValue];

	CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
	cell.detailTextLabel.text = location.description;
    
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
		
		

		NSManagedObject *eventToDelete = [self.usersBookmarks objectAtIndex:indexPath.row];
		[self.managedObjectContext deleteObject:eventToDelete];
		
		// Update the array and table view.
		[self.usersBookmarks removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
		

		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
