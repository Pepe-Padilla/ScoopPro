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
@property (strong, nonatomic) NSMutableDictionary * scoopsD;


-(void) warmupClient;
-(void) chargeTable;
-(void) addNewToAzureWithScoop:(MXWScoop*) aScoop;

@end
