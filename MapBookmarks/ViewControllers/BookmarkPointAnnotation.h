//
//  BookmarkPinAnnotationView.h
//  MapBookmarks
//
//  Created by Sapa Denys on 23.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Bookmark;

@interface BookmarkPointAnnotation : MKPointAnnotation

@property (nonatomic, weak) Bookmark *annotationBookmark;

- (instancetype)initWithBookmark:(Bookmark *)bookmark;

@end
