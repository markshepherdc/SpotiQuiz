//
//  SimilarArtistDataController.h
//  Simple Track Playback
//
//  Created by Mark Shepherd on 11/5/15.
//  Copyright © 2015 Your Company. All rights reserved.
//

#ifndef SimilarArtistDataController_h
#define SimilarArtistDataController_h


#endif /* SimilarArtistDataController_h */


@interface SimilarArtistDataController : NSObject<NSURLConnectionDelegate>

-(void)getSimilarArtist:(NSString *)currentArtist;
@property (strong, nonatomic) NSMutableArray *similarArtists;

@end