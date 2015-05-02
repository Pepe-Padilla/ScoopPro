//
//  MXWViewController.h
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/30/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MXWScoop;
@class MXWScoopFeed;
#import "MXWScoopsTableViewController.h"

@interface MXWViewController : UIViewController <UISplitViewControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,MXWScoopTableViewControllerDelegate>

//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) MXWScoop * scoop;
@property (strong, nonatomic) MXWScoopFeed * scoopFeed;

@property (weak, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageRankingCollection;


@property (weak, nonatomic) IBOutlet UITextField * textFieldTitleScoop;
@property (weak, nonatomic) IBOutlet UITextView * textViewTextScoop;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewPictureScoop;

-(id) initWithScoopFeeder:(MXWScoopFeed*)scoopFeed andModel: (MXWScoop*) aScoop;

@end
