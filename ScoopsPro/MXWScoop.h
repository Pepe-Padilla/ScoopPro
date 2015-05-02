//
//  MXWScoop.h
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/25/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface MXWScoop : NSObject

@property (copy, nonatomic) NSString * titleScoop;
@property (copy, nonatomic) NSString * textScoop;
@property (copy, nonatomic) NSString * authorName;
@property (strong, nonatomic) NSDate * fxCreation;
@property (strong, nonatomic) NSDate * fxSubmitied;
@property (strong, nonatomic) NSString * photoImg;
@property (strong, nonatomic) NSNumber * latitude;
@property (strong, nonatomic) NSNumber * longitude;
@property (strong, nonatomic) NSNumber * ranking;
@property (strong, nonatomic) NSNumber * status;
@property (copy, nonatomic) NSString * scoopID;
@property (copy, nonatomic) NSString * authorID;

@property (strong, nonatomic) UIImage * imageScoop;
@property (nonatomic) BOOL ranked;


-(id) initWithDictionary:(NSDictionary*) dictionary;

-(NSDictionary*) dictionaryForScoop;

+(instancetype)scoopWithTitle: (NSString*) title
                     authorID: (NSString*) authorID
                   authorName: (NSString*) authorName;

@end
