//
//  ContentfulModelObject.h
//  ContentfulUFO
//
//  Created by Boris Bügling on 11.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContentfulModelObject <NSObject>

+(instancetype)modelObjectFromDictionary:(NSDictionary*)dictionary;

@end
