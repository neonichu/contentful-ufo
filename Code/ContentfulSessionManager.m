//
//  ContentfulSessionManager.m
//  ContentfulUFO
//
//  Created by Boris Bügling on 11.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "ContentfulSessionManager.h"
#import "ContentfulSyncInfo.h"

@interface ContentfulSessionManager ()

@property NSString* accessToken;

@end

#pragma mark -

@implementation ContentfulSessionManager

-(void)handleResponse:(id)responseObject
            withArray:(NSMutableArray*)items
    completionHandler:(ContentfulItemsCompletionHandler)completionHandler {
    for (NSDictionary* item in responseObject[@"items"]) {
        [items addObject:[self.modelClass modelObjectFromDictionary:item]];
    }
    
    if (responseObject[@"nextPageUrl"]) {
        NSString* endpoint = [self relativeURLStringFromURLString:responseObject[@"nextPageUrl"]];
        [self pagedArrayFromEndpoint:endpoint appendTo:items withCompletionHandler:completionHandler];
        return;
    }
    
    if (responseObject[@"nextSyncUrl"]) {
        NSString* endpoint = [self relativeURLStringFromURLString:responseObject[@"nextSyncUrl"]];
        NSString* space = [[endpoint componentsSeparatedByString:@"/"] firstObject];
        [ContentfulSyncInfo addNextSyncUrl:endpoint forSpace:space];
    }
    
    if (completionHandler) {
        completionHandler([items copy], nil);
    }
}

-(void)initialSyncedSpace:(NSString*)space withCompletionHandler:(ContentfulItemsCompletionHandler)completionHandler {
    [self GET:[space stringByAppendingString:@"/sync"]
   parameters:@{ @"initial": @"true", @"access_token": self.accessToken }
      success:^(NSURLSessionDataTask *task, id responseObject) {
          [self handleResponse:responseObject withArray:[@[] mutableCopy] completionHandler:completionHandler];
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          if (completionHandler) {
              completionHandler(nil, error);
          }
      }];
}

-(id)initWithAccessToken:(NSString*)accessToken {
    self = [super initWithBaseURL:[NSURL URLWithString:@"https://cdn.contentful.com/spaces"]];
    if (self) {
        self.accessToken = accessToken;
        
        NSMutableSet* acceptableContentTypes = [self.responseSerializer.acceptableContentTypes mutableCopy];
        [acceptableContentTypes addObject:@"application/vnd.contentful.delivery.v1+json"];
        self.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    }
    return self;
}

-(void)pagedArrayFromEndpoint:(NSString*)endpoint
                     appendTo:(NSMutableArray*)array
        withCompletionHandler:(ContentfulItemsCompletionHandler)completionHandler {
    [self GET:endpoint
   parameters:@{ @"access_token": self.accessToken }
      success:^(NSURLSessionDataTask *task, id responseObject) {
          [self handleResponse:responseObject withArray:array completionHandler:completionHandler];
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if (completionHandler) {
              completionHandler(nil, error);
          }
      }];
}

-(NSString*)relativeURLStringFromURLString:(NSString*)urlString {
    return [urlString stringByReplacingOccurrencesOfString:self.baseURL.absoluteString withString:@""];
}

-(void)syncedSpace:(NSString*)space withCompletionHandler:(ContentfulItemsCompletionHandler)completionHandler {
    if (!completionHandler) {
        return;
    }
    
    NSArray* items = [self.modelClass all];
    if (items.count > 0) {
        ContentfulSyncInfo* syncInfo = [ContentfulSyncInfo syncInfoForSpace:space];
        NSAssert(syncInfo, @"Missing nextSyncUrl.");
        [self pagedArrayFromEndpoint:syncInfo.nextSyncUrl appendTo:[items mutableCopy] withCompletionHandler:completionHandler];
        return;
    }
    
    [self initialSyncedSpace:space withCompletionHandler:^(NSArray *items, NSError *error) {
        if (!items) {
            completionHandler(nil, error);
            return;
        }
        
        [items makeObjectsPerformSelector:@selector(save)];
        
        completionHandler(items, nil);
    }];
}

@end
