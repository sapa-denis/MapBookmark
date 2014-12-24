//
//  BookmarkPinAnnotationView.m
//  MapBookmarks
//
//  Created by Sapa Denys on 23.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import "BookmarkPointAnnotation.h"
#import "Bookmark.h"

@interface BookmarkPointAnnotation ()

@end

@implementation BookmarkPointAnnotation

- (instancetype)initWithBookmark:(Bookmark *)bookmark
{
	self = [super init];
	if (self) {
		_annotationBookmark = bookmark;
		[self setCoordinate:bookmark.location.coordinate];
		[self setTitle:bookmark.locationName];
	}
	return self;
}

@end
