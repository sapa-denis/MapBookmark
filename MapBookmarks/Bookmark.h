//
//  Bookmark.h
//  MapBookmarks
//
//  Created by Sapa Denys on 21.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface Bookmark : NSManagedObject

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, copy) NSString *locationName;
@property (nonatomic, getter=isNamed) BOOL named;

+ (instancetype)createBookmark;

@end
