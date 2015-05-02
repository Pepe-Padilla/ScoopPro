//
//  MXWViewController.m
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/30/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

#import "MXWViewController.h"
#import "MXWScoop.h"
#import "MXWScoopFeed.h"
#import "Header.h"

@interface MXWViewController ()

@end

@implementation MXWViewController

- (id)initWithScoopFeeder:(MXWScoopFeed *)scoopFeed andModel:(MXWScoop *)aScoop {
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        _scoopFeed = scoopFeed;
        _scoop = aScoop;
    }
    
    return  self;
}

#pragma mark - Lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout= UIRectEdgeNone;
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    
    [self chargeInitialValues];
    [self toolBarButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utilities
-(void) chargeInitialValues {
    
    //[self.activityIndicator.];
    
    NSString * subText = @"";
    if ([self.scoop.status isEqualToNumber:MXWSTATUS_EDITING]) {
        subText = @"Editing";
        
        self.textFieldTitleScoop.enabled = YES;
        self.textViewTextScoop.editable = YES;
        
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        subText = [dateFormatter stringFromDate:self.scoop.fxSubmitied];
        
        self.textFieldTitleScoop.enabled = NO;
        self.textViewTextScoop.editable = NO;
    }
    
    if (self.scoop.authorName)
        self.labelAuthor.text = [NSString stringWithFormat:@"%@ \n %@", self.scoop.authorName,subText];
    else
        self.labelAuthor.text = @"";
    
    //self.imageRankingCollection.array;
    
    for (NSInteger i=0; i < self.imageRankingCollection.count; i++) {
        
        UIImageView* rank = self.imageRankingCollection[i];
        if ([self.scoop.status isEqualToNumber:MXWSTATUS_ACCEPTED]) {
            [rank setUserInteractionEnabled:!self.scoop.ranked];
            
            if (rank.gestureRecognizers.count == 0) {
    
                UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(singleTapping:)];
                [singleTap setNumberOfTapsRequired:1];
                [rank addGestureRecognizer:singleTap];
            }
            if ([self.scoop.ranking doubleValue] > ([@(i) doubleValue] + 0.5l)) {
                rank.image = [UIImage imageNamed:@"starUP.png"];
            } else {
                rank.image = [UIImage imageNamed:@"starDOWN.png"];
            }
            
        } else {
            rank.image = nil;
            [rank setUserInteractionEnabled:NO];
        }
    }
    
    self.textFieldTitleScoop.text = self.scoop.titleScoop;
    self.textViewTextScoop.text = self.scoop.textScoop;
    
    self.imageViewPictureScoop.image = self.scoop.imageScoop;
    
        
}

-(void) toolBarButtons {
    
    if ([self.scoop.status isEqualToNumber:MXWSTATUS_EDITING]) {
        UIBarButtonItem *photoB = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                   target:self action:@selector(scoopPhoto)];
        
        UIBarButtonItem *deleteB = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                    target:self action:@selector(deleteScoop)];
        
        UIBarButtonItem *saveB = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                  target:self action:@selector(saveScoop)];
        
        UIBarButtonItem *submitB = [[UIBarButtonItem alloc] initWithTitle:@"Submit Scoop"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(submitScoop)];
        
        NSArray * arrItems = @[deleteB,photoB,saveB,submitB];
        
        self.navigationItem.rightBarButtonItems = arrItems;
    } else self.navigationItem.rightBarButtonItems = @[];
}

#pragma mark - actions
- (void) scoopPhoto {
    
    self.scoop.titleScoop = self.textFieldTitleScoop.text;
    self.scoop.textScoop = self.textViewTextScoop.text;
    
    UIImagePickerController * piker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        piker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        piker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    piker.delegate = self;
    
    piker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:piker animated:YES completion:^{
        
    }];
    
}



-(void) deleteScoop {
    [self.scoopFeed deleteScoopWithScoop:self.scoop];
    self.scoop = [[MXWScoop alloc] init];
    [self chargeInitialValues];
    self.navigationItem.rightBarButtonItems = @[];
}

-(void) saveScoop{
    self.scoop.titleScoop = self.textFieldTitleScoop.text;
    self.scoop.textScoop = self.textViewTextScoop.text;
    [self.scoopFeed updateScoopWithScoop:self.scoop];
}

-(void) submitScoop {
    self.scoop.titleScoop = self.textFieldTitleScoop.text;
    self.scoop.textScoop = self.textViewTextScoop.text;
    self.scoop.status = MXWSTATUS_SUBMITTED;
    [self.scoopFeed updateScoopWithScoop:self.scoop];
    [self chargeInitialValues];
    self.navigationItem.rightBarButtonItems = @[];
}

- (void) singleTapping: (id) obj {
    UIGestureRecognizer *aRec=obj;
    if (aRec.state == UIGestureRecognizerStateRecognized) {
        
        BOOL rankFouded = NO;
        
        for (NSInteger i = 0; i < self.imageRankingCollection.count; i++) {
            
            UIImageView* rank = self.imageRankingCollection[i];
            [rank setUserInteractionEnabled:NO];
            if (rankFouded) rank.image = [UIImage imageNamed:@"starDOWN.png"];
            else rank.image = [UIImage imageNamed:@"starUP.png"];
            
            for (NSInteger j = 0; j < rank.gestureRecognizers.count; j++) {
                if ([[rank.gestureRecognizers objectAtIndex:j]isEqual:obj]) {
                    //rank it with i value!!!
                    rankFouded = YES;
                    NSLog(@"precionó el rango: %ld",(long)i+1);
                    [self.scoopFeed rankScoop:self.scoop
                                        value:(i+1)
                               withCompletion:^(NSError *err) {
                                            
                                        }];
                }
            }
            
        }
    }
}

#pragma mark - UISplitViewControllerDelegate
-(void) splitViewController:(UISplitViewController *)svc
    willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode{
    
    if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        // tabla oculta
        self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem;
        //self.aSel = svc.displayModeButtonItem.action;
    } else {
        //Se muestra la tabla
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    
}


#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Sacamos la UImage del diccionario
    // Pico de memoria asegurado:
    UIImage  * img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    //La guardo en el modelo y la despliego
    self.scoop.imageScoop = img;
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

#pragma mark - MXWScoopTableViewControllerDelegate
-(void) scoopTableViewController: (MXWScoopsTableViewController *) tVC
                    andScoopFeed: (MXWScoopFeed *) scoopFeed
                  didSelectScoop: (MXWScoop *) aScoop{
    
    self.scoopFeed = scoopFeed;
    self.scoop = aScoop;
    [self chargeInitialValues];
    [self toolBarButtons];
    
}

@end
