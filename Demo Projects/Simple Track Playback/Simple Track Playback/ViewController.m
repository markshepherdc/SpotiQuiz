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

#import "Config.h"
#import "ViewController.h"
#import <Spotify/SPTDiskCache.h>
#import "SimilarArtistDataController.h"
@interface ViewController () <SPTAudioStreamingDelegate>



@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *coverView2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) SPTAudioStreamingController *player;

//@Mark Shepherd
@property (strong, nonatomic) IBOutlet UIButton *rewButton;
@property (strong, nonatomic) IBOutlet UIButton *ffButton;
@property (weak, nonatomic) IBOutlet UIButton *artistAnswer1;
@property (weak, nonatomic) IBOutlet UIButton *artistAnswer2;
@property (weak, nonatomic) IBOutlet UIButton *artistAnswer3;
@property (weak, nonatomic) IBOutlet UIButton *artistAnswer4;


@end

@implementation ViewController{
    
    NSInteger *userPoints;
    UIImage *image;
     SimilarArtistDataController *simArtistCon;
    NSString *arttistID;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Nothing Playing";
    self.albumLabel.text = @"";
    self.artistLabel.text = @"";
    
    self.rewButton.hidden=YES;
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Actions

-(IBAction)rewind:(id)sender {
    [self.player skipPrevious:nil];
}

-(IBAction)playPause:(id)sender {
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
}

-(IBAction)fastForward:(id)sender {
    [self.player skipNext:nil];
}

- (IBAction)logoutClicked:(id)sender {
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (self.player) {
        [self.player logout:^(NSError *error) {
            auth.session = nil;
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


// @ Mark Shepherd - Answers Button Methods
-(IBAction)ans1:(id)sender{
    
//    [self checkAnswer:self.artistAnswer1.titleLabel.text :self.artistLabel.text];
    
}

-(IBAction)ans2:(id)sender{
    
  //  [self checkAnswer:self.artistAnswer2.titleLabel.text :self.artistLabel.text];
}

-(IBAction)ans3:(id)sender{
    
 //   [self checkAnswer:self.artistAnswer3.titleLabel.text :self.artistLabel.text];
}

-(IBAction)ans4:(id)sender{
    
 //   [self checkAnswer:self.artistAnswer4.titleLabel.text :self.artistLabel.text];
}


-(IBAction)resetGame:(id)sender{
    userPoints=0;
   
}

#pragma mark - Logic


- (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur
                   withRadius: (CGFloat)blurRadius {

    CIImage *originalImage = [CIImage imageWithCGImage: imageToBlur.CGImage];
    CIFilter *filter = [CIFilter filterWithName: @"CIGaussianBlur"
                                  keysAndValues: kCIInputImageKey, originalImage,
                        @"inputRadius", @(blurRadius), nil];

    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];

    CGImageRef outImage = [context createCGImage: outputImage
                                        fromRect: [outputImage extent]];

    UIImage *ret = [UIImage imageWithCGImage: outImage];

    CGImageRelease(outImage);

    return ret;
}

-(void)updateUI {
    SPTAuth *auth = [SPTAuth defaultInstance];

    if (self.player.currentTrackURI == nil) {
        self.coverView.image = nil;
        self.coverView2.image = nil;
        return;
    }
    
    [self.spinner startAnimating];

    [SPTTrack trackWithURI:self.player.currentTrackURI
                   session:auth.session
                  callback:^(NSError *error, SPTTrack *track) {

                      self.titleLabel.text = [NSString stringWithFormat:@"Track: %@ ", track.name];
                      self.albumLabel.text = [NSString stringWithFormat:@"Album: %@ ", track.album.name];

                      SPTPartialArtist *artist = [track.artists objectAtIndex:0];
                      self.artistLabel.text = [NSString stringWithFormat:@"Artist: %@ ", artist.name];
                      
                      //@Mark
            //          [simArtistCon.similarArtists addObject:artist.name];
                      NSLog(@"Similar artist: %@",simArtistCon.similarArtists);
                      
                      //Mark - Hide artist from user
                      self.artistLabel.hidden=YES;
                      //Prevent from moving to next track until question is anwered
                      [self.ffButton setEnabled:NO];
                      self.ffButton.alpha = 0.1;

                      NSURL *imageURL = track.album.largestCover.imageURL;
                      if (imageURL == nil) {
                          NSLog(@"Album %@ doesn't have any images!", track.album);
                          self.coverView.image = nil;
                          self.coverView2.image = nil;
                          return;
                      }

                      // Pop over to a background queue to load the image over the network.
                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                          NSError *error = nil;
                          image = nil;
                          NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:0 error:&error];
                           NSLog(@"Similar artist: %@",[simArtistCon.similarArtists objectAtIndex:1]);
                          NSLog(@"Similar artist: %@",[simArtistCon.similarArtists objectAtIndex:2]);
                          NSLog(@"Similar artist: %@",[simArtistCon.similarArtists objectAtIndex:0]);
                          if (imageData != nil) {
                              image = [UIImage imageWithData:imageData];
                          }
                          
                          
                          


                          // …and back to the main queue to display the image.
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self.spinner stopAnimating];
                              
                              
                             //@Mark
                             UIImage *blurmainImage = [self applyBlurOnImage:image withRadius:10.0f];
                              self.coverView.image = blurmainImage;
                              if (image == nil) {
                                  NSLog(@"Couldn't load cover image with error: %@", error);
                                  return;
                              }
                          });
                          
                          // Also generate a blurry version for the background
                          UIImage *blurred = [self applyBlurOnImage:image withRadius:10.0f];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              self.coverView2.image = blurred;
                          });
                      });

    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self handleNewSession];
}

-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];

    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }

    [self.player loginWithSession:auth.session callback:^(NSError *error) {

		if (error != nil) {
			NSLog(@"*** Enabling playback got error: %@", error);
			return;
		}

        [self updateUI];
        
        NSURLRequest *playlistReq = [SPTPlaylistSnapshot createRequestForPlaylistWithURI:[NSURL URLWithString:@"spotify:user:cariboutheband:playlist:4Dg0J0ICj9kKTGDyFu0Cv4"]
                                                                             accessToken:auth.session.accessToken
                                                                                   error:nil];
        
        [[SPTRequest sharedHandler] performRequest:playlistReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
            if (error != nil) {
                NSLog(@"*** Failed to get playlist %@", error);
                return;
            }
            
            SPTPlaylistSnapshot *playlistSnapshot = [SPTPlaylistSnapshot playlistSnapshotFromData:data withResponse:response error:nil];
            
            [self.player playURIs:playlistSnapshot.firstTrackPage.items fromIndex:0 callback:nil];
        }];
	}];
}

//Assign Buttons values or artists
-(void)assignAnswerButtons{
    
    NSArray *answerButtons = [NSArray arrayWithObjects:self.artistAnswer1,self.artistAnswer2, self.artistAnswer3, self.artistAnswer4, nil];
    
    //   NSMutableArray *answerChoices = [simlarArtistData getSimilarArtist:self.artistLabel.text];
    
    for (int i=0; i<answerButtons.count; i++) {
        //        [[answerButtons objectAtIndex:i] setTitle:[answerChoices objectAtIndex:i] forState:UIControlStateNormal];
    }
    
}

//Logic to decide wheather or not answer selected is correct
-(void)checkAnswer:(NSString *)answerSelected :(NSString *)correctAnswer  {
    
    NSString *answerResults;
    
    if([answerSelected isEqual:correctAnswer]){
        NSLog(@"You are correct ");
        answerResults =@"You are correct";
        userPoints++;
        
    }else{
        
        NSLog(@"You are wrong ");
        answerResults =[NSString stringWithFormat:@"You are wrong, the correct answer is %@", self.artistLabel.text];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Answer results"
                                                        message:answerResults
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
    
    //Reveal Everything once question is answeres
    self.artistLabel.hidden=NO;
    self.coverView.image=image;
    [self.ffButton setEnabled:YES];
    self.ffButton.alpha=1.0;
 //   [self showArtistRelatedUIElements:YES];
    
    
}

#pragma mark - Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri {
    NSLog(@"failed to play track: %@", trackUri);
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI]);
   NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataArtistURI]);
    
    
    simArtistCon = [[SimilarArtistDataController alloc]init];
    NSString *iden = @"08rMCq2ek1YjdDBsCPVH2s";
    [simArtistCon getSimilarArtist:iden];
 
    [self updateUI];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"is playing = %d", isPlaying);
}

@end
