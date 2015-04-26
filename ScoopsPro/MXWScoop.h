//
//  MXWScoop.h
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/25/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

@import Foundation;
@import UIKit;
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@interface MXWScoop : NSObject

@property (copy, nonatomic) NSString * titleScoop;
@property (copy, nonatomic) NSString * textScoop;
@property (copy, nonatomic) NSString * authorName;
@property (strong, nonatomic) NSDate * fxCreation;
@property (strong, nonatomic) NSDate * fxSubmitied;
@property (strong, nonatomic) UIImage * photoImg;
@property (strong, nonatomic) NSNumber * latitude;
@property (strong, nonatomic) NSNumber * longitude;
@property (strong, nonatomic) NSNumber * ranking;
@property (strong, nonatomic) NSNumber * status;
@property (copy, nonatomic) NSString * scoopID;
@property (copy, nonatomic) NSString * authorID;


-(id) initWithDictionary:(NSDictionary*) dictionary
                  client:(MSClient *) aClient;

-(NSDictionary*) dictionaryForScoop;

+(instancetype)scoopWithTitle: (NSString*) title
                     authorID: (NSString*) authorID
                      cliennt: (MSClient *) aClient;

@end
