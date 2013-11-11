//
//  BBUAppDelegate.m
//  ContentfulUFO
//
//  Created by Boris Bügling on 11.11.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "BBUAppDelegate.h"
#import "BBUUFOMapViewController.h"
#import "BBUUFOSighting.h"
#import "ContentfulSessionManager.h"

@interface BBUAppDelegate ()

@property BBUUFOMapViewController* mapViewController;
@property ContentfulSessionManager* sessionManager;

@end

#pragma mark -

@implementation BBUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.mapViewController = [BBUUFOMapViewController new];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.mapViewController];
    [self.window makeKeyAndVisible];
    
    self.sessionManager = [[ContentfulSessionManager alloc] initWithAccessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
    self.sessionManager.modelClass = [BBUUFOSighting class];
    
    [self.sessionManager syncedSpace:@"lzjz8hygvfgu" withCompletionHandler:^(NSArray *items, NSError *error) {
        if (!items) {
            [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                        message:error.localizedRecoverySuggestion
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
            return;
        }
        
        self.mapViewController.items = items;
    }];
    
    return YES;
}

@end
