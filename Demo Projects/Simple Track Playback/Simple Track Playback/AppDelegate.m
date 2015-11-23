/*
 Copyright 2015 Spotify AB

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "Config.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set up shared authentication information
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = @kClientId;
    auth.requestedScopes = @[SPTAuthStreamingScope];
    auth.redirectURL = [NSURL URLWithString:@kCallbackURL];
    #ifdef kTokenSwapServiceURL
    auth.tokenSwapURL = [NSURL URLWithString:@kTokenSwapServiceURL];
    #endif
    #ifdef kTokenRefreshServiceURL
    auth.tokenRefreshURL = [NSURL URLWithString:@kTokenRefreshServiceURL];
    #endif
    auth.sessionUserDefaultsKey = @kSessionUserDefaultsKey;
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    SPTAuth *auth = [SPTAuth defaultInstance];

    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).

        if (error != nil) {
            NSLog(@"*** Auth error: %@", error);
            return;
        }

        auth.session = session;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    };
    
    /*
     Handle the callback from the authentication service. -[SPAuth -canHandleURL:]
     helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
     */
    
    if ([auth canHandleURL:url]) {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }

    return NO;
}


//@Mark 
 +(void)downloadDataFromURL:(NSURL *)url withCompletionHandler:(void (^)(NSData *))completionHandler{
 // Instantiate a session configuration object.
 NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
 
 // Instantiate a session object.
 NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
 
 // Create a data task object to perform the data downloading.
 NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
 
 if (error != nil) {
 // If any error occurs then just display its description on the console.
 NSLog(@"%@", [error localizedDescription]);
 }
 else{
 // If no error occurs, check the HTTP status code.
 NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
 
 // If it's other than 200, then show it on the console.
 if (HTTPStatusCode != 200) {
 NSLog(@"HTTP status code = %d", HTTPStatusCode);
 }
 
 // Call the completion handler with the returned data on the main thread.
 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
 completionHandler(data);
 }];
 }
 }];
 
 // Resume the task.
 [task resume];
 }
 

@end
