//
//  ContentfulSessionManager.m
//  ContentfulUFO
//
//  Created by Boris Bügling on 11.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "ContentfulSessionManager.h"

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
        NSString* endpoint = responseObject[@"nextPageUrl"];
        [endpoint stringByReplacingOccurrencesOfString:self.baseURL.absoluteString withString:@""];
        [self pagedArrayFromEndpoint:endpoint appendTo:items withCompletionHandler:completionHandler];
        return;
    }
    
    if (completionHandler) {
        completionHandler([items copy], nil);
    }
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

-(void)syncedSpace:(NSString*)space withCompletionHandler:(ContentfulItemsCompletionHandler)completionHandler {
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

@end
