//
//  SampleTrackData.m
//  Sample Stream
//
//  Created by Mark Shepherd on 10/19/15.
//  Copyright © 2015 Your Company. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface SimilarArtistDataController : NSObject<NSURLConnectionDelegate>


//-(NSMutableArray *)getSimilarArtist:(NSString *)currentArtist;

@property (strong, nonatomic) NSMutableArray *similarArtists;


@end



@implementation SimilarArtistDataController {
 
#define echonestBaseURL "http://developer.echonest.com/"
#define echoNestAPIKey "NHODB2F3ZZFQVHMPV"
//#define spotifyBucket "spotify-US"


}
@synthesize similarArtists;


-(id)init{
    
     similarArtists = [[NSMutableArray alloc]init];
    
    return self;
}



//Get Echo nest response for similar artists
-(void)getSimilarArtist:(NSString *)currentArtistID{
    

    NSString *URLString = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/artist/similar?api_key=NHODB2F3ZZFQVHMPV&id=spotify:artist:08rMCq2ek1YjdDBsCPVH2s&results=3&bucket=id:spotify"];
    
    
    NSURL *url = [NSURL URLWithString:URLString];
   
    
    
   
    [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        // Check if any data returned.
        if (data != nil) {
            // Convert the returned data into a dictionary.
            NSError *error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            else{
                    
           //         NSLog(@"Similar to current artist playing:");
                    for(int i = 0; i< [[[returnedDict objectForKey:@"response"] objectForKey:@"artists"] count];i++){
                        
                        [similarArtists addObject:[[[[returnedDict objectForKey:@"response"] objectForKey:@"artists"]objectAtIndex:i]objectForKey:@"name"]];
                        NSLog(@"%@",[similarArtists objectAtIndex:i]);
                        
                        
                    }
                    
              
            
                
                
                //    NSLog(@"%@",[returnedDict objectForKey:@"response"] );
                
                
                
                
                
            }
        }
    }];


 
}
 


//Shuffle Answer choices
-(NSMutableArray *)shuffleArray: (NSMutableArray *)artists
{
    NSUInteger count = [artists count];
    for (NSUInteger i = 0; i < count; ++i) {
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [artists exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return artists;    
}




    

    
    








@end
