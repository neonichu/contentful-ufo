//
//  ContentfulSyncInfo.m
//  ContentfulUFO
//
//  Created by Boris Bügling on 13.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "ContentfulSyncInfo.h"

@implementation ContentfulSyncInfo

@dynamic space;
@dynamic nextSyncUrl;

#pragma mark -

+(void)addNextSyncUrl:(NSString *)nextSyncUrl forSpace:(NSString *)space {
    ContentfulSyncInfo* info = [self syncInfoForSpace:space];
    
    if (!info) {
        info = [[self class] create];
    }
    
    info.nextSyncUrl = nextSyncUrl;
    info.space = space;
    
    [info save];
}

+(instancetype)syncInfoForSpace:(NSString *)space {
    return [[ContentfulSyncInfo where:[NSString stringWithFormat:@"space == '%@'", space]] firstObject];
}

@end
