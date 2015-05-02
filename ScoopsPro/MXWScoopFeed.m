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

-(id) init {
    
    if (self = [super init]) {
        _worldScoops = [[NSMutableArray alloc] init];
        _myScoops = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark - Azure manager
-(void) warmupClient {
    self.client = [MSClient clientWithApplicationURL: [NSURL URLWithString:KAZURE_ENDPOINT]
                                      applicationKey: KAZURE_APPKEY];
    
    self.clientBlob= [MSClient clientWithApplicationURL: [NSURL URLWithString:KAZURE_BLOBURL]
                                         applicationKey: KAZURE_BLOBKEY];
    
    NSLog(@"%@", self.client.debugDescription);
    NSLog(@"%@", self.clientBlob.debugDescription);
}

-(void) chargeTables {
    
    MSTable *table = [self.client tableWithName:@"news"];
    
    //[table queryWithPredicate:[NSPredicate predicateWithFormat:@"%K = %@",MXWSTATUS,MXWSTATUS_ACCEPTED]];
    //MSQuery *queryModel = [[MSQuery alloc]initWithTable:table];
    
    MSQuery *queryModel = [table queryWithPredicate:[NSPredicate predicateWithFormat:@"%K = %@",MXWSTATUS,MXWSTATUS_ACCEPTED]];
    
    
    [queryModel orderByDescending:MXWFXSUBMITED];
    queryModel.fetchLimit = 50;
    
    [queryModel readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        
        if (error) {
            NSLog(@"error at query: %@", error);
            //completionBlock(error); return;
        }
        for (id item in items) {
            NSLog(@"item -> %@", item);
            
            MXWScoop * scoop = [[MXWScoop alloc] initWithDictionary: item];
            
            if (![scoop.photoImg isEqualToString:@""] && scoop.photoImg)
                scoop.imageScoop = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:scoop.photoImg]]];
            
            [self addWorldScoopsObject:scoop];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                               object: self
                                                             userInfo: nil ];
            [nc postNotification:n];
            
        }
    }];
    
    MSTable *tableA = [self.client tableWithName:@"news"];
    
    //[tableA queryWithPredicate:[NSPredicate predicateWithFormat:@"%K = %@",MXWAUTHORID,self.userFBId]];
    //MSQuery *queryModelA = [[MSQuery alloc]initWithTable:tableA];
    MSQuery *queryModelA = [tableA queryWithPredicate:[NSPredicate predicateWithFormat:@"%K = %@",MXWAUTHORID,self.userFBId]];
    
    [queryModelA orderByDescending:MXWFXCREATION];
    
    [queryModelA readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        
        if (error) {
            NSLog(@"error at query: %@", error);
            //completionBlock(error); return;
        }
        for (id item in items) {
            NSLog(@"item -> %@", item);
            
            MXWScoop * scoop = [[MXWScoop alloc] initWithDictionary: item];
            
            if (![scoop.photoImg isEqualToString:@""] && scoop.photoImg)
                scoop.imageScoop = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:scoop.photoImg]]];
            
            
            [self addMyScoopsObject:scoop];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                               object: self
                                                             userInfo: nil ];
            [nc postNotification:n];
        }
    }];
    
    //completionBlock(nil);

}

-(void) addNewScoopWithitle: (NSString*) title {
    //self.client
    
    MXWScoop * aScoop = [MXWScoop scoopWithTitle:title
                                        authorID:self.userFBId
                                      authorName:self.userName];
    
    MSTable * news = [self.client tableWithName:@"news"];
    
    [news insert:[aScoop dictionaryForScoop]
      completion:^(NSDictionary *item, NSError *error) {
          if(error){
              NSLog(@"%@",error);
          } else {
              NSLog(@"OK");
              MXWScoop * scoop = [[MXWScoop alloc] initWithDictionary: item];
              
              [self addMyScoopsObject:scoop];
              
              NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
              NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                                 object: self
                                                               userInfo: nil ];
              [nc postNotification:n];
          }
      }];
    
}

-(void) updateScoopWithScoop: (MXWScoop *) aScoop {
    
    NSNumber * scoopMod = @-1;
    
    for (int i = 0; i<self.myScoops.count; i++) {
        MXWScoop* compScoop = [self.myScoops objectAtIndex:[@(i) unsignedIntegerValue]];
        
        if ([compScoop.scoopID isEqualToString:aScoop.scoopID]) {
            scoopMod = @(i);
        }
        
    }
    
    if ([scoopMod intValue] > -1) {
        MSTable *table = [self.client tableWithName:@"news"];
        
        if (aScoop.imageScoop) {
            aScoop.photoImg = [self setScoop:aScoop image:aScoop.imageScoop];
        }
        
        [table update:[aScoop dictionaryForScoop]
           completion:^(NSDictionary *item, NSError *error) {
               if (error) {
                   NSLog(@"Error en el update");
               } else {
                   MXWScoop * newScoop = [[MXWScoop alloc] initWithDictionary:item];
                   [self replaceObjectInMyScoopsAtIndex:[scoopMod unsignedIntegerValue]
                                             withObject:newScoop];
                   
                   if (![newScoop.status isEqualToNumber:aScoop.status]) {
                       NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                       NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                                          object: self
                                                                        userInfo: nil ];
                       [nc postNotification:n];
                   }
               }
           }];
    } else NSLog(@"Scoop no reconocido en el update");
    
    
}

-(void) deleteScoopWithScoop: (MXWScoop *) aScoop{
    NSNumber * scoopMod = @-1;
    
    for (int i = 0; i<self.myScoops.count; i++) {
        MXWScoop* compScoop = [self.myScoops objectAtIndex:[@(i) unsignedIntegerValue]];
        
        if ([compScoop.scoopID isEqualToString:aScoop.scoopID]) {
            scoopMod = @(i);
        }
        
    }
    
    if ([scoopMod intValue] > -1) {
        MSTable *table = [self.client tableWithName:@"news"];
        
        [table deleteWithId:aScoop.scoopID completion:^(id itemId, NSError *error) {
            
                if (error) {
                   NSLog(@"Error en el update");
               } else {
                   [self removeObjectFromMyScoopsAtIndex:[scoopMod unsignedIntegerValue]];
                   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                   NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                                      object: self
                                                                    userInfo: nil ];
                   [nc postNotification:n];
               }
           }];
    } else NSLog(@"Scoop no reconocido en el delete");
}

-(void) rankScoop:(MXWScoop*) aScoop
            value:(NSInteger)value
   withCompletion: (void (^)(NSError *err))completionBlock {
    aScoop.ranked = YES;
    aScoop.ranking = [NSNumber numberWithInteger:value];
    
    //[NSString stringWithFormat:@"{%@ : %@, %@ : %@}",MXWSCOOPID,aScoop.scoopID,MXWRANKING,[NSNumber numberWithInteger:value]]
    [self.client invokeAPI:@"rankscoop"
                      body:nil //@{MXWSCOOPID : aScoop.scoopID, MXWRANKING : [NSNumber numberWithInteger:value]}
                HTTPMethod:@"GET"
                parameters:@{MXWSCOOPID : aScoop.scoopID, MXWRANKING : [NSNumber numberWithInteger:value]}
                   headers:nil //@{MXWSCOOPID : aScoop.scoopID, MXWRANKING : [NSNumber numberWithInteger:value]}
                completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                    if (error) NSLog(@"%@",error);
                    completionBlock(error);
                }];
    
}

#pragma mark - storage
- (NSString*) setScoop:(MXWScoop*) aScoop image: (UIImage*) anImage {
    
    //[self getSasUrlForNewBlob: [NSString stringWithFormat:@"%@.jpg",aScoop.scoopID]
    //             forContainer: KAZURE_BLOBACOUNTNAME
    //           withCompletion: ^(NSString *sasUrl) {
    NSString * sasUrl = [NSString stringWithFormat:@"%@%@/",KAZURE_BLOBURL,KAZURE_BLOBACOUNTNAME];
                   NSData *imageData = UIImageJPEGRepresentation(anImage, 0.5);
                   
                   NSURL *urlIMG = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.jpg",sasUrl,aScoop.scoopID]];
                   
                   NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL: urlIMG ];
                   [theRequest setHTTPMethod: @"PUT"];
                   [theRequest setHTTPBody: imageData];
                   [theRequest setValue:@"image/JPG" forHTTPHeaderField:@"Content-Type"];
                   [theRequest setValue:@"BlockBlob"  forHTTPHeaderField:@"x-ms-blob-type"];
                   [theRequest setValue:[NSString stringWithFormat:@"%@",[NSDate date]] forHTTPHeaderField:@"x-ms-date"];
                   [theRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[imageData length]] forHTTPHeaderField:@"Content-Length"];
                   [theRequest setValue:[NSString stringWithFormat:@"SharedKey %@:%@",@"storagekas",KAZURE_BLOBKEY] forHTTPHeaderField:@"Authorization"];
                   //nuevos x2
                   //[theRequest setValue:@"containerName" forHTTPHeaderField:KAZURE_BLOBACOUNTNAME];
                   //[theRequest setValue:@"blobName" forHTTPHeaderField:[NSString stringWithFormat:@"%@.jpg",aScoop.scoopID]];
                   NSData *response;
                   NSError *WSerror;
                   NSURLResponse *WSresponse;
                   NSString *responseString;
                   response = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&WSresponse error:&WSerror];
                   responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                   NSLog(@"%@",responseString);
    //           }];

    
    //MSTable * blobTable = [self.client tableWithName:@"storagekas"];
    //NSDictionary *params = @{ @"containerName" : KAZURE_BLOBACOUNTNAME, @"blobName" : [NSString stringWithFormat:@"%@.jpg",aScoop.scoopID]};
    
    //[blobTable ];
    
    return [NSString stringWithFormat:@"%@%@/%@.jpg",KAZURE_BLOBURL,KAZURE_BLOBACOUNTNAME,aScoop.scoopID];
}

- (void) getSasUrlForNewBlob:(NSString *)blobName forContainer:(NSString *)containerName withCompletion:(CompletionWithSasBlock) completion {
    MSTable * blobTable = [self.clientBlob tableWithName:@"containerkas"];
    NSDictionary *item = @{  };
    NSDictionary *params = @{ @"containerName" : containerName, @"blobName" : blobName };
    [blobTable insert:item parameters:params completion:^(NSDictionary *item, NSError *error) {
        NSLog(@"Item: %@", item);
        completion([item objectForKey:@"sasUrl"]);
    }];
}

- (void) imageOfScoop: (MXWScoop *) aScoop
      completionBlock:(void (^)(UIImage*image))completionBlock{
    
    
    // nos vamos a 2º plano a descargar la imagen
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        
        if (!aScoop.photoImg || [aScoop.photoImg isEqualToString:@""]) {
            completionBlock(nil);
        } else {
            
            NSURL * anURL = [NSURL URLWithString:aScoop.photoImg];
            NSData *data = [NSData dataWithContentsOfURL:anURL];
            UIImage *img = [UIImage imageWithData:data];
            
            // cuando la tengo, me voy a primer plano
            // llamo al completionBlock
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(img);
            });
        }
    });
    
    
}


#pragma mark - Login FB
- (void) loginAppInViewController: (UIViewController*) controller
                   withCompletion: (void (^)(MSUser*user, NSError *err))completionBlock {
    
    [self loadUserAuthInfo];
    
    if (self.client.currentUser) {
        [self.client invokeAPI:@"getuserinfo"
                          body:nil
                    HTTPMethod:@"GET"
                    parameters:nil
                       headers:nil
                    completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                        self.authorPhotoURL = [NSURL URLWithString:
                                               result[@"picture"][@"data"][@"url"]];
                        self.userName = result[@"name"];
                        
                        completionBlock(self.client.currentUser,error);
                    }];
    } else {
        
        [self.client loginWithProvider:@"facebook"
                            controller:controller
                              animated:YES
                            completion:^(MSUser *user, NSError *error) {
                                NSLog(@"User -> %@", user);
                                if (error) completionBlock(user,error);
                                else {
                                    self.client.currentUser = user;
                                    [self saveAuthInfo];
                                    
                                    [self.client invokeAPI:@"getuserinfo"
                                                      body:nil
                                                HTTPMethod:@"GET"
                                                parameters:nil
                                                   headers:nil
                                                completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                                                    self.authorPhotoURL = [NSURL URLWithString:
                                                                           result[@"picture"][@"data"][@"url"]];
                                                    self.userName = result[@"name"];
                                                    
                                                    completionBlock(self.client.currentUser,error);
                                                }];

                                    
                                }
                            }];
        
    }
}

- (void) saveAuthInfo {
    
    self.userFBId = self.client.currentUser.userId;
    self.tokenFB = self.client.currentUser.mobileServiceAuthenticationToken;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.userFBId
                                              forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.tokenFB
                                              forKey:@"tokenFB"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) loadUserAuthInfo {
    self.userFBId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    self.tokenFB = [[NSUserDefaults standardUserDefaults] objectForKey:@"tokenFB"];
    
    if (self.userFBId) {
        self.client.currentUser = [[MSUser alloc] initWithUserId: self.userFBId];
        self.client.currentUser.mobileServiceAuthenticationToken = self.tokenFB;
        return YES;
    }
    
    
    return NO;
}

#pragma mark - arrays KVOables
-(NSInteger) countOfMyScoops {
    return self.myScoops.count;
}

-(NSInteger) countOfWorldScoops {
    return self.worldScoops.count;
}

-(void) addMyScoopsObject:(MXWScoop *)object {
    [self.myScoops addObject:object];
}

-(void) addWorldScoopsObject:(MXWScoop *)object {
    [self.worldScoops addObject:object];
}
-(void) removeObjectFromMyScoopsAtIndex:(NSUInteger)index{
    [self.myScoops removeObjectAtIndex:index];
}

-(void) replaceObjectInMyScoopsAtIndex:(NSUInteger)index
                            withObject:(id)object{
    [self.myScoops replaceObjectAtIndex:index
                             withObject:object];
}

@end
