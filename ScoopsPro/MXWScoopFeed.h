//
//  MXWScoopFeed.h
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/25/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

@import Foundation;
@class MXWScoop;
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@interface MXWScoopFeed : NSObject

@property (strong, nonatomic) MSClient * client;
//@property (strong, nonatomic) NSMutableDictionary * scoopsD;
@property (copy, nonatomic) NSString * userFBId;
@property (copy, nonatomic) NSString * tokenFB;
@property (copy, nonatomic) NSString * userName;
@property (strong, nonatomic) NSURL * authorPhotoURL;

@property (strong, nonatomic) NSMutableArray * worldScoops;
@property (strong, nonatomic) NSMutableArray * myScoops;

//@property (strong, nonatomic) MS


-(void) warmupClient;
//-(void) chargeTableswithCompletion: (void (^)(NSError *err))completionBlock;
-(void) chargeTables;
-(void) addNewScoopWithitle: (NSString*) title;
-(void) updateScoopWithScoop: (MXWScoop *) aScoop;
-(void) loginAppInViewController: (UIViewController*) controller
                  withCompletion: (void (^)(MSUser*user, NSError *err))completionBlock;

//Arrays KVOables
-(NSInteger) countOfMyScoops;
-(NSInteger) countOfWorldScoops;
-(void) addMyScoopsObject:(MXWScoop *)object;
-(void) addWorldScoopsObject:(MXWScoop *)object;
-(void) removeObjectFromMyScoopsAtIndex:(NSUInteger)index;
-(void) replaceObjectInMyScoopsAtIndex:(NSUInteger)index withObject:(id)object;

@end
