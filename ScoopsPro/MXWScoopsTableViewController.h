//
//  MXWScoopsTableViewController.h
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/28/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

@import UIKit;
@class MXWScoopFeed;

@interface MXWScoopsTableViewController : UITableViewController

@property (strong, nonatomic) MXWScoopFeed * theScoops;



- (id) initWithModel: (MXWScoopFeed*) sFeed;

@end
