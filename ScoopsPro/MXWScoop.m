//
//  MXWScoop.m
//  ScoopsPro
//
//  Created by Pepe Padilla on 15/25/04.
//  Copyright (c) 2015 maxeiware. All rights reserved.
//

#import "MXWScoop.h"

#import "Header.h"

@interface MXWScoop ()


@end


@implementation MXWScoop

+(instancetype)scoopWithTitle: (NSString*) title
                     authorID: (NSString*) authorID
                   authorName: (NSString*) authorName {
    
    NSDictionary* aScoop = @{MXWTITLESCOOP : title,
                             MXWTEXTSCOOP  : @"",
                             MXWAUTHORNAME : authorName,
                             MXWFXCREATION : [NSDate date],
                             MXWFXSUBMITED : [NSDate date],
                             MXWPHOTOIMG   : @"",
                             MXWLATITUDE   : @0,
                             MXWLONGITUDE  : @0,
                             MXWRANKING    : @0,
                             MXWSTATUS     : MXWSTATUS_EDITING,
                             MXWSCOOPID    : @"",
                             MXWAUTHORID   : authorID};
    return [[MXWScoop alloc] initWithDictionary:aScoop];
}

-(id) initWithDictionary:(NSDictionary*) dictionary {
    
    if (self = [super init]) {
        _titleScoop = [dictionary valueForKey:MXWTITLESCOOP];
        _textScoop = [dictionary valueForKey:MXWTEXTSCOOP];
        _authorName = [dictionary valueForKey:MXWAUTHORNAME];
        _fxCreation = [dictionary valueForKey:MXWFXCREATION];
        _fxSubmitied = [dictionary valueForKey:MXWFXSUBMITED];
        _photoImg = [dictionary valueForKey:MXWPHOTOIMG];
        _latitude = [dictionary valueForKey:MXWLATITUDE];
        _longitude = [dictionary valueForKey:MXWLONGITUDE];
        _ranking = [dictionary valueForKey:MXWRANKING];
        _status = [dictionary valueForKey:MXWSTATUS];
        _scoopID = [dictionary valueForKey:MXWSCOOPID];
        _authorID = [dictionary valueForKey:MXWAUTHORID];
        _ranked = NO;
    }
    
    return self;
}

-(NSDictionary*) dictionaryForScoop{
    return @{MXWTITLESCOOP : self.titleScoop,
             MXWTEXTSCOOP  : self.textScoop,
             MXWAUTHORNAME : self.authorName,
             MXWFXCREATION : self.fxCreation,
             MXWFXSUBMITED : self.fxSubmitied,
             MXWPHOTOIMG   : self.photoImg,
             MXWLATITUDE   : self.latitude,
             MXWLONGITUDE  : self.longitude,
             MXWRANKING    : self.ranking,
             MXWSTATUS     : self.status,
             MXWSCOOPID    : self.scoopID,
             MXWAUTHORID   : self.authorID};
}

@end
