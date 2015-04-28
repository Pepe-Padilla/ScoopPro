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
                     authorID: (NSString*) authorID{
    
    NSDictionary* aScoop = @{MXWTITLESCOOP : title,
                             MXWTEXTSCOOP  : @"",
                             MXWAUTHORNAME : @"",
                             MXWFXCREATION : [NSDate date],
                             //MXWFXSUBMITED : nil,
                             //MXWPHOTOIMG   : nil,
                             MXWLATITUDE   : @0,
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
        _ranking = [dictionary valueForKey:MXWRANKING];
        _status = [dictionary valueForKey:MXWSTATUS];
        _scoopID = [dictionary valueForKey:MXWSCOOPID];
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
             MXWRANKING    : self.ranking,
             MXWSTATUS     : self.status,
             MXWSCOOPID    : self.scoopID};
}

@end
