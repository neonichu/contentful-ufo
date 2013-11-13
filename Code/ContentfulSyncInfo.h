//
//  ContentfulSyncInfo.h
//  ContentfulUFO
//
//  Created by Boris Bügling on 13.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveRecord/ObjectiveRecord.h>

@interface ContentfulSyncInfo : NSManagedObject

@property (nonatomic, retain) NSString * space;
@property (nonatomic, retain) NSString * nextSyncUrl;

+(void)addNextSyncUrl:(NSString*)nextSyncUrl forSpace:(NSString*)space;
+(instancetype)syncInfoForSpace:(NSString*)space;

@end
