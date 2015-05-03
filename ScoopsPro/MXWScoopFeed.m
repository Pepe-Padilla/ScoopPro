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
@import CoreLocation;

@interface MXWScoopFeed () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) CLLocation * authorLocation;

@end


@implementation MXWScoopFeed

-(id) init {
    
    if (self = [super init]) {
        _worldScoops = [[NSMutableArray alloc] init];
        _myScoops = [[NSMutableArray alloc] init];
        _loadingMyScoops = YES;
        _loadingWorldScoops = YES;
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
    
    [self locationStarter];
    
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
            
            /*[self handleSaSURLToDownload:[NSURL URLWithString:scoop.photoImg]
                     completionHandleSaS:^(id result, NSError *error) {
                     
                   scoop.imageScoop = result;
                   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                   NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                                      object: self
                                                                    userInfo: nil ];
                   [nc postNotification:n];
               }];*/
            
            [self imageOfScoop:scoop
               completionBlock:^(UIImage *image) {
                   scoop.imageScoop = image;
                   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                   NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                                      object: self
                                                                    userInfo: nil ];
                   [nc postNotification:n];
               }];
            
            [self addWorldScoopsObject:scoop];
            _loadingWorldScoops = NO;

            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                               object: self
                                                             userInfo: nil ];
            [nc postNotification:n];
        }
        _loadingWorldScoops = NO;
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
            
            
            /*[self handleSaSURLToDownload:[NSURL URLWithString:scoop.photoImg]
                     completionHandleSaS:^(id result, NSError *error) {
                         
                         
                         scoop.imageScoop = result;
                         //[self addMyScoopsObject:scoop];
                         //_loadingMyScoops = NO;
                         NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                         NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                                            object: self
                                                                          userInfo: nil ];
                         [nc postNotification:n];
                     }];*/

            
            [self imageOfScoop:scoop
               completionBlock:^(UIImage *image) {
                   scoop.imageScoop = image;
                   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                   NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                                      object: self
                                                                    userInfo: nil ];
                   [nc postNotification:n];
               }];
            
            [self addMyScoopsObject:scoop];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                               object: self
                                                             userInfo: nil ];
            [nc postNotification:n];
            _loadingMyScoops = NO;
            
        }
        _loadingMyScoops = NO;
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
        
        [self getSasUrlWithScoop:aScoop withCompletion:^(NSString *sasUrl) {
            
            if(sasUrl)
                aScoop.photoImg = [NSString stringWithFormat:@"%@%@/%@.jpg",KAZURE_BLOBURL,KAZURE_BLOBCONTAINERNAME,aScoop.scoopID];
            
            if(self.authorLocation) {
                aScoop.latitude = [NSNumber numberWithDouble:self.authorLocation.coordinate.latitude];
                aScoop.longitude = [NSNumber numberWithDouble:self.authorLocation.coordinate.longitude];
            }
            
            if (aScoop.imageScoop && aScoop.photoImg && ![aScoop.photoImg isEqualToString:@""])
            [self handleImageToUploadAzureBlob:[NSURL URLWithString:sasUrl]
                                       blobImg:aScoop.imageScoop
                          completionUploadTask:^(id result, NSError *error) {
                              if (error) NSLog(@"error ar upload image --> %@", error);
                              else NSLog(@"Upload Image OK: %@", result);
                          }];
            
            [table update:[aScoop dictionaryForScoop]
               completion:^(NSDictionary *item, NSError *error) {
                   if (error) {
                       NSLog(@"Error en el update");
                   } else {
                       MXWScoop * newScoop = [[MXWScoop alloc] initWithDictionary:item];
                       newScoop.imageScoop = aScoop.imageScoop;
                       [self replaceObjectInMyScoopsAtIndex:[scoopMod unsignedIntegerValue]
                                                 withObject:newScoop];
                       
                       if ([newScoop.status isEqualToNumber:MXWSTATUS_SUBMITTED] ||
                           [newScoop.status isEqualToNumber:MXWSTATUS_EDITING]) {
                           
                           NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                           NSNotification * n = [NSNotification notificationWithName: SCOOP_DID_CHANGE_NOTIFICATION
                                                                              object: self
                                                                            userInfo: nil ];
                           [nc postNotification:n];
                       }
                   }
               }];
            
            
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

- (void)handleImageToUploadAzureBlob:(NSURL *)theURL
                             blobImg:(UIImage*)blobImg
                completionUploadTask:(void (^)(id result, NSError * error))completion{
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:theURL];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = UIImageJPEGRepresentation(blobImg, 1.f);
    
    NSURLSessionUploadTask *uploadTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSLog(@"resultado --> %@", response);
        } else NSLog(@"error al subir imagen: %@",error);
        
    }];
    [uploadTask resume];
}

- (void) getSasUrlWithScoop: (MXWScoop *) aScoop
             withCompletion:(CompletionWithSasBlock) completion {
    if (!aScoop.imageScoop) {
        completion(@"");
    } else
    [self.client invokeAPI:@"sasurl"
                      body:nil
                HTTPMethod:@"GET"
                parameters:@{@"blobName" : [aScoop.scoopID stringByAppendingString:@".jpg"], @"blobContainer" : KAZURE_BLOBCONTAINERNAME}
                   headers:nil
                completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"%@",error);
                        completion(@"");
                    }
                    
                    NSLog(@"header of sasurl --> %@",[result valueForKey:@"sasUrl"]);
                    completion([result valueForKey:@"sasUrl"]);
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

- (void)handleSaSURLToDownload:(NSURL *)theUrl completionHandleSaS:(void (^)(id result, NSError *error))completion{
    
    if(theUrl && ![[theUrl absoluteString] isEqualToString:@""]) {
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:theUrl];
        
        [request setHTTPMethod:@"GET"];
        [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        
        NSURLSessionDownloadTask * downloadTask = [[NSURLSession sharedSession]downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            
            if (!error) {
                
                NSLog(@"resultado --> %@", response);
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                completion(image, error);
            } else completion(nil,error);
            
            
            
        }];
        [downloadTask resume];
    } else {
        completion (nil,nil);
    }
    
}



#pragma mark - Geo Localization
- (void) locationStarter {
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if((status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusNotDetermined) &&
       [CLLocationManager locationServicesEnabled] &&
       !self.authorLocation) {
        // tenemos permisos para usar la geolocalización
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [self.locationManager startUpdatingLocation];
        
        NSLog(@"Stariting location");
        
    }
}

#pragma mark - CLLocationManagerDelegate
-(void) locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // parar la geolocalización
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    NSLog(@"Localization Stoped");
    
    self.authorLocation = [locations lastObject];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // parar la geolocalización
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    NSLog(@"Localization Stoped with errors: %@", error);
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
