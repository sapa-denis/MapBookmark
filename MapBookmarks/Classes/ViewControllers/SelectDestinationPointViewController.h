//
//  SelectDestinationPointViewController.h
//  MapBookmarks
//
//  Created by Sapa Denys on 22.12.14.
//  Copyright (c) 2014 Sapa Denys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectDestinationPointViewController;
@class Bookmark;

@protocol SelectDestinationPointViewControllerDelegate <NSObject>

@optional

- (void)destinationsPointViewController:(SelectDestinationPointViewController *)controller
					  didSelectBookmark:(Bookmark *)bookmark;

@end

@interface SelectDestinationPointViewController : UIViewController

@property (nonatomic, strong) NSArray *destinationPoints;
@property (nonatomic, weak) id<SelectDestinationPointViewControllerDelegate> delegate;

@end
