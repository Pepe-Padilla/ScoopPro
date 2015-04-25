//
//  MXWScoopFeed.m
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/25/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

#import "MXWScoopFeed.h"
#import "Header.h"
#import "MXWScoop.h"


@implementation MXWScoopFeed


#pragma mark - Azure manager
-(void) warmupClient {
    self.client = [MSClient clientWithApplicationURL: [NSURL URLWithString:KAZURE_ENDPOINT]
                                      applicationKey: KAZURE_APPKEY];
    
    NSLog(@"%@", self.client.debugDescription);
}

-(void) chargeTable {
    
}

-(void) addNewToAzureWithScoop:(MXWScoop*) aScoop {
    //self.client
    MSTable * news = [self.client tableWithName:@"news"];
    
    [news insert:[aScoop dictionaryForScoop]
      completion:^(NSDictionary *item, NSError *error) {
          if(error){
              NSLog(@"%@",error);
          } else {
              NSLog(@"OK");
          }
      }];
    
}

@end
