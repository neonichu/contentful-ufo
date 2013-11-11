//
//  BBUUFOSighting.m
//  ContentfulUFO
//
//  Created by Boris Bügling on 11.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <KZPropertyMapper/KZPropertyMapper.h>

#import "BBUUFOSighting.h"

@implementation BBUUFOSighting

@synthesize coordinate;
@synthesize title;

#pragma mark -

+(instancetype)modelObjectFromDictionary:(NSDictionary *)dictionary {
    return [self UFOSightingFromDictionary:dictionary];
}

+(instancetype)UFOSightingFromDictionary:(NSDictionary*)dictionary {
    return [[[self class] alloc] initWithDictionary:dictionary];
}

#pragma mark -

-(NSDate*)dateFromString:(NSString*)dateString {
    return [[ISO8601DateFormatter new] dateFromString:dateString];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"UFO sighting: %@ at %.2f - %.2f", self.title,
            self.coordinate.latitude, self.coordinate.longitude];
}

-(id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        static NSString* const defaultLocale = @"en-US";
        
        [KZPropertyMapper logIgnoredValues:NO];
        [KZPropertyMapper mapValuesFrom:dictionary
                             toInstance:self
                           usingMapping:@{ @"fields": @{
                                                   @"description": @{ defaultLocale: KZProperty(sightingDescription) },
                                                   @"locationName": @{ defaultLocale: KZProperty(title) },
                                                   @"reportedAt": @{ defaultLocale: KZCall(dateFromString:, reportedAt) },
                                                   @"sightedAt": @{ defaultLocale: KZCall(dateFromString:, sightedAt) },
                                                   @"location": @{ defaultLocale: KZCall(locationFromDictionary:, coordinate) },
                                                   }
                                           }];
    }
    return self;
}

-(id)locationFromDictionary:(NSDictionary*)dictionary {
    CLLocationCoordinate2D location;
    location.latitude = [dictionary[@"lat"] floatValue];
    location.longitude = [dictionary[@"lon"] floatValue];
    return [NSValue valueWithMKCoordinate:location];
}

-(NSString *)subtitle {
    return [NSDateFormatter localizedStringFromDate:self.sightedAt
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

@end
