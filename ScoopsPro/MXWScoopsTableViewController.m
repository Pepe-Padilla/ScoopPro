//
//  MXWScoopsTableViewController.m
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/28/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

#import "MXWScoopsTableViewController.h"
#import "MXWScoopFeed.h"
#import "MXWScoop.h"
#import "Header.h"

@interface MXWScoopsTableViewController ()
@property (nonatomic) BOOL myAuthor;
@property (strong, nonatomic) MSUser * user;

@end

@implementation MXWScoopsTableViewController

- (id) initWithModel:(MXWScoopFeed *)sFeed {
    
    if (self = [super initWithNibName:nil
                               bundle:nil]) {
        _theScoops = sFeed;
        _myAuthor = YES;
        _user = nil;
    }
    
    return  self;
}

#pragma mark - Life cycle
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self clientStatus];
    
    
    [self configureTable];
    [self setKVO];
    
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self turnDownKVO];
}

#pragma mark - Utilities
- (void) clientStatus {
    [self.theScoops warmupClient];
    
    if (!self.user){
        
        self.user = [[MSUser alloc] init];
        [self.theScoops loginAppInViewController:self withCompletion:^(MSUser *user, NSError *err) {
            if (err) {
                NSLog(@"Error at logging in--> %@", err);
            } else {
                self.user = user;
                [self.theScoops performSelector:@selector(chargeTables) withObject:nil afterDelay:1];
                //[self.theScoops chargeTables];
            }
        }];
        
        
        
    }
    
}
- (void) configureTable {
    if (self.myAuthor) {
        
        UIBarButtonItem *addScoop = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                   target:self action:@selector(addScoop)];
        
        self.navigationItem.rightBarButtonItem = addScoop;
        
        UIBarButtonItem *goToWorldScoops = [[UIBarButtonItem alloc] initWithTitle:@"World Scoops"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(toggleTable)];
        self.navigationItem.leftBarButtonItem =goToWorldScoops;
        self.title = @"My Scoops";
    }
    else {
        
        self.navigationItem.rightBarButtonItem = nil;
        
        UIBarButtonItem *goToMyScoops = [[UIBarButtonItem alloc] initWithTitle:@"My Scoops"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(toggleTable)];
        self.navigationItem.leftBarButtonItem =goToMyScoops;
        self.title = @"World Scoops";
    }
}

- (void) toggleTable {
    self.myAuthor = !self.myAuthor;
    [self configureTable];
    [self.tableView reloadData];
}

-(void) addScoop {
    [self.theScoops addNewScoopWithitle:@"New Scoop"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.myAuthor) {
        return self.theScoops.myScoops.count;
    } else {
        return self.theScoops.worldScoops.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellID = @"HMXWLibary";
    UITableViewCell * cell= [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        // crear cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellID];
    }
    
    MXWScoop * aScoop = nil;
    if (self.myAuthor) {
        aScoop = [self.theScoops.myScoops objectAtIndex:indexPath.row];
    } else {
        aScoop = [self.theScoops.worldScoops objectAtIndex:indexPath.row];
    }
    
    
    //Configurar celda
    cell.imageView.image = aScoop.imageScoop;
    cell.textLabel.text = aScoop.titleScoop;
    
    if (self.myAuthor) {
        if ([aScoop.status isEqualToNumber:MXWSTATUS_SUBMITTED]) {
            cell.detailTextLabel.text = @"Submited";
        } else if ([aScoop.status isEqualToNumber:MXWSTATUS_EDITING]) {
            cell.detailTextLabel.text = @"Editing";
        } else if ([aScoop.status isEqualToNumber:MXWSTATUS_DENIED]) {
            cell.detailTextLabel.text = @"Denied";
        } else if ([aScoop.status isEqualToNumber:MXWSTATUS_ACCEPTED]) {
            cell.detailTextLabel.text = @"Publicated";
        } else cell.detailTextLabel.text = aScoop.authorName;
    } else {
        cell.detailTextLabel.text = aScoop.authorName;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)  tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
  forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
*/

#pragma mark - KVO
-(void) setKVO {
    [self.theScoops addObserver:self
                     forKeyPath:@"myScoops"
                        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                        context:NULL];
    [self.theScoops addObserver:self
                     forKeyPath:@"worldScoops"
                        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                        context:NULL];
}

-(void) turnDownKVO {
    [self.theScoops removeObserver:self
                        forKeyPath:@"myScoops"];
    [self.theScoops removeObserver:self
                        forKeyPath:@"worldScoops"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    
    [self.tableView reloadData];
    
}


@end
