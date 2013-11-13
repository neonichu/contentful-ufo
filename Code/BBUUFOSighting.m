//
//  BBUUFOSighting.m
//  ContentfulUFO
//
//  Created by Boris Bügling on 11.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <KZPropertyMapper/KZPropertyMapper.h>
#import <ObjectiveRecord/ObjectiveRecord.h>

#import "BBUUFOSighting.h"

@interface BBUUFOSighting ()

@property NSData* coordinateValue;

@end

#pragma mark -

@implementation BBUUFOSighting

@dynamic coordinateValue;
@dynamic reportedAt;
@dynamic sightedAt;
@dynamic sightingDescription;
@dynamic title;

#pragma mark -

+(void)load {
    [[CoreDataManager sharedManager] setModelName:@"UFO"];
}

+(instancetype)modelObjectFromDictionary:(NSDictionary *)dictionary {
    return [self UFOSightingFromDictionary:dictionary];
}

+(instancetype)UFOSightingFromDictionary:(NSDictionary*)dictionary {
    BBUUFOSighting* sighting = [[self class] create];
    [sighting fillWithDictionary:dictionary];
    return sighting;
}

#pragma mark -

-(CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;
    [self.coordinateValue getBytes:&coordinate length:sizeof(coordinate)];
    return coordinate;
}

-(NSDate*)dateFromString:(NSString*)dateString {
    return [[ISO8601DateFormatter new] dateFromString:dateString];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"UFO sighting: %@ at %.2f - %.2f", self.title,
            self.coordinate.latitude, self.coordinate.longitude];
}

-(void)fillWithDictionary:(NSDictionary*)dictionary {
    static NSString* const defaultLocale = @"en-US";
    
    [KZPropertyMapper logIgnoredValues:NO];
    [KZPropertyMapper mapValuesFrom:dictionary
                         toInstance:self
                       usingMapping:@{ @"fields": @{
                                               @"description": @{ defaultLocale: KZProperty(sightingDescription) },
                                               @"locationName": @{ defaultLocale: KZProperty(title) },
                                               @"reportedAt": @{ defaultLocale: KZCall(dateFromString:, reportedAt) },
                                               @"sightedAt": @{ defaultLocale: KZCall(dateFromString:, sightedAt) },
                                               @"location": @{ defaultLocale: KZCall(locationFromDictionary:, coordinateValue) },
                                               }
                                       }];
}

-(id)locationFromDictionary:(NSDictionary*)dictionary {
    CLLocationCoordinate2D location;
    location.latitude = [dictionary[@"lat"] floatValue];
    location.longitude = [dictionary[@"lon"] floatValue];
    return [NSData dataWithBytes:&location length:sizeof(CLLocationCoordinate2D)];
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.coordinateValue = [NSData dataWithBytes:&newCoordinate length:sizeof(CLLocationCoordinate2D)];
}

-(NSString *)subtitle {
    return [NSDateFormatter localizedStringFromDate:self.sightedAt
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

@end
