//
//  ContentfulSessionManager.h
//  ContentfulUFO
//
//  Created by Boris Bügling on 11.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "ContentfulModelObject.h"

typedef void(^ContentfulItemsCompletionHandler)(NSArray* items, NSError* error);

@interface ContentfulSessionManager : AFHTTPSessionManager

@property Class<ContentfulModelObject> modelClass;

-(id)initWithAccessToken:(NSString*)accessToken;
-(void)syncedSpace:(NSString*)space withCompletionHandler:(ContentfulItemsCompletionHandler)completionHandler;

@end
