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
    
    NSLog(@"%@", self.client.debugDescription);
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
               }
           }];
    } else NSLog(@"Scoop no reconocido en el update");
    
    
}

#pragma mark - storage
- (NSString*) setScoop:(MXWScoop*) aScoop image: (UIImage*) anImage {
    NSData *imageData = UIImageJPEGRepresentation(anImage, 0.5);
    
    NSURL *urlIMG = [NSURL URLWithString: [NSString stringWithFormat:@"%@%@.jpg",KAZURE_BLOBURL,aScoop.scoopID]];
    
    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL: urlIMG ];
    [theRequest setHTTPMethod: @"PUT"];
    [theRequest setHTTPBody: imageData];
    [theRequest setValue:@"image/JPG" forHTTPHeaderField:@"Content-Type"];
    [theRequest setValue:@"BlockBlob"  forHTTPHeaderField:@"x-ms-blob-type"];
    [theRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[imageData length]] forHTTPHeaderField:@"Content-Length"];
    [theRequest setValue:[NSString stringWithFormat:@"SharedKey %@:%@",KAZURE_BLOBACOUNTNAME,KAZURE_BLOBKEY] forHTTPHeaderField:@"Authorization"];
    NSData *response;
    NSError *WSerror;
    NSURLResponse *WSresponse;
    NSString *responseString;
    response = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&WSresponse error:&WSerror];
    responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] ;
    
    return [urlIMG absoluteString];
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
