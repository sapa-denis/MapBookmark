//
//  Bookmark.m
//  MapBookmarks
//
//  Created by Sapa Denys on 21.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "Bookmark.h"
#import "AppDelegate.h"

static NSString *const kLocationName = @"locationName";
static NSString *const kLocation = @"location";
static NSString *const kNamed = @"named";

@implementation Bookmark

@dynamic location;
@dynamic locationName;
@dynamic named;

+ (instancetype)createBookmark
{
	NSManagedObjectContext *context;
	id delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate respondsToSelector:@selector(managedObjectContext)]) {
		context = [delegate performSelector:@selector(managedObjectContext)];
	}
	
	Bookmark *newEntity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
														inManagedObjectContext:context];
	newEntity.locationName = @"NoName Location";
	newEntity.named = NO;
	return newEntity;
}


-(CLLocation *)location
{
	[self willAccessValueForKey:kLocation];
	CLLocation *loc = [self primitiveValueForKey:kLocation];
	[self didChangeValueForKey:kLocation];
	return loc;
}

- (void)setLocation:(CLLocation *)location
{
	[self willChangeValueForKey:kLocation];
	[self setPrimitiveValue:location forKey:kLocation];
	[self didChangeValueForKey:kLocation];
}

- (NSString *)locationName
{
	[self willAccessValueForKey:kLocationName];
	NSString *locName = [self primitiveValueForKey:kLocationName];
	[self didChangeValueForKey:kLocationName];
	return locName;
}

- (void)setLocationName:(NSString *)locationName
{
	[self willChangeValueForKey:kLocationName];
	[self setPrimitiveValue:locationName forKey:kLocationName];
	[self didChangeValueForKey:kLocationName];
}

- (BOOL)isNamed
{
	[self willAccessValueForKey:kNamed];
	BOOL named = [[self primitiveValueForKey:kNamed] boolValue];
	[self didChangeValueForKey:kNamed];
	return named;
}

- (void)setNamed:(BOOL)named
{
	[self willChangeValueForKey:kNamed];
	[self setPrimitiveValue:[NSNumber numberWithBool:named] forKey:kNamed];
	[self didChangeValueForKey:kNamed];
}

@end
