//
//  MXWScoopsTableViewController.h
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/28/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

@import UIKit;
@class MXWScoopFeed;
@class MXWScoop;
@class MXWScoopsTableViewController;

@protocol MXWScoopTableViewControllerDelegate <NSObject>

@optional
-(void) scoopTableViewController: (MXWScoopsTableViewController *) tVC
                    andScoopFeed: (MXWScoopFeed *) scoopFeed
                  didSelectScoop: (MXWScoop *) aScoop;


@end


@interface MXWScoopsTableViewController : UITableViewController <MXWScoopTableViewControllerDelegate>

@property (strong, nonatomic) MXWScoopFeed * theScoops;

@property (weak, nonatomic) id<MXWScoopTableViewControllerDelegate> delegate;



- (id) initWithModel: (MXWScoopFeed*) sFeed;

@end
