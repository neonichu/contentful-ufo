//
//  BBUUFOSighting.h
//  ContentfulUFO
//
//  Created by Boris Bügling on 11.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "ContentfulModelObject.h"

@interface BBUUFOSighting : NSObject <ContentfulModelObject, MKAnnotation>

@property NSString* sightingDescription;
@property NSDate* reportedAt;
@property NSDate* sightedAt;

+(instancetype)UFOSightingFromDictionary:(NSDictionary*)dictionary;

@end
