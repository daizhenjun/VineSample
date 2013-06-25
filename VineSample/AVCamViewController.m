/*
     File: AVCamViewController.m
 Abstract: A view controller that coordinates the transfer of information between the user interface and the capture manager.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "NSTimerExtension.h"

static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface AVCamViewController () <UIGestureRecognizerDelegate>
@end

@interface AVCamViewController (InternalMethods)
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;
@end

@interface AVCamViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end

@implementation AVCamViewController

@synthesize captureManager;
@synthesize cameraToggleButton;
@synthesize stillButton;
@synthesize nextButton;
@synthesize focusModeLabel;
@synthesize videoPreviewView;
@synthesize captureVideoPreviewLayer;
@synthesize videoArray;

NSTimer* itemHoldTimer;
BOOL finished;
bool isPlay;
int currentPlayId = 0;

- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode
{
	NSString *focusString = @"";
	
	switch (focusMode) {
		case AVCaptureFocusModeLocked:
			focusString = @"locked";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"auto";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"continuous";
			break;
	}
	
	return focusString;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode"];
    captureManager = nil;
    videoPreviewView  = nil;
	captureVideoPreviewLayer = nil;
    cameraToggleButton  = nil;
    nextButton  = nil;
    stillButton  = nil;
    focusModeLabel  = nil;
    finished = YES;
    self.slider = nil;
    //[super dealloc];
}

-(void) showSheetMenu{
    if(self.slider.value > 2.0){
    UIActionSheet *menu = [[UIActionSheet alloc]
                           initWithTitle: @""
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:@"Delete post"
                           otherButtonTitles:nil, nil];
    
        [menu showInView:self.view];
    }else{
        [self nextBtnClick:nil];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [self nextBtnClick:nil];
    }
}

- (void)viewDidLoad
{
    self.stillButton.hidden = YES;
    self.nextButton.hidden = YES;
    finished = YES;
    self.videoArray = [[NSMutableArray alloc] init];
    [self.slider setThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RecordCloseButton@2x.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSheetMenu) ];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.navigationItem setHidesBackButton:YES];
    
 	if ([self captureManager] == nil) {
		AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
		[self setCaptureManager:manager];
		//[manager release];
		[[self captureManager] setDelegate:self];

		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
			AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			UIView *view = [self videoPreviewView];
			CALayer *viewLayer = [view layer];
			[viewLayer setMasksToBounds:YES];
			
			CGRect bounds = [view bounds];
			[newCaptureVideoPreviewLayer setFrame:bounds];
			
			if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
				[newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
			}
			
			[newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			
			[viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			
			[self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            //[newCaptureVideoPreviewLayer release];
			
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
			});
			
            [self updateButtonStates];
			
            // Create the focus mode UI overlay
			UILabel *newFocusModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, viewLayer.bounds.size.width - 20, 20)];
			[newFocusModeLabel setBackgroundColor:[UIColor clearColor]];
			[newFocusModeLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.50]];
			AVCaptureFocusMode initialFocusMode = [[[captureManager videoInput] device] focusMode];
			[newFocusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:initialFocusMode]]];
			[view addSubview:newFocusModeLabel];
			[self addObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode" options:NSKeyValueObservingOptionNew context:AVCamFocusModeObserverContext];
			[self setFocusModeLabel:newFocusModeLabel];
            //[newFocusModeLabel release];

            UIButton *button = [[UIButton alloc] initWithFrame:self.cameraView.frame];
            [button addTarget:self action:@selector(itemTouchDown) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(itemTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            
            [self.view bringSubviewToFront:self.cameraToggleButton];
            [self.view bringSubviewToFront:self.nextButton];
            [self.view bringSubviewToFront:self.stillButton];
		}		
	}
		
    [super viewDidLoad];
}


- (void) moviePlayBackDidFinish : (NSNotification *) notification
{
    currentPlayId++;
    if(currentPlayId>=self.videoArray.count){
        currentPlayId = 0;
    }
    NSString* filePath = [self.videoArray objectAtIndex:currentPlayId];
    NSLog(@"=====ORIGIN RECORED MOVIE URL===%@", [NSURL URLWithString:filePath]);
    MPMoviePlayerController * player = notification.object;
    [player setContentURL:[NSURL URLWithString:filePath]];
    [player play];
}

-(void) playRecordVideo{
    //load record movie
    NSString* filePath = [self.videoArray objectAtIndex:currentPlayId];
    self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:filePath]];
    //NSLog(@"=====RECORED MOVIE URL===%@", filePath);
    self.videoPlayer.controlStyle             = MPMovieControlStyleNone;
    self.videoPlayer.scalingMode              = MPMovieScalingModeAspectFit;
    self.videoPlayer.shouldAutoplay           = NO;
    self.videoPlayer.view.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.videoPlayer.view.autoresizesSubviews = YES;
    self.videoPlayer.view.frame               = self.cameraView.bounds;
    //self.videoPlayer.repeatMode               = MPMovieRepeatModeOne;
    [self.videoPlayer playableDuration];
    [self.videoPlayer prepareToPlay];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(moviePlayBackDidFinish:)
                   name:MPMoviePlayerPlaybackDidFinishNotification
                 object:self.videoPlayer];

    currentPlayId = 0;
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleSingleTap:)];
    UIView *touchView = [[UIView alloc] initWithFrame:self.videoPlayer.view.bounds];
    [touchView addGestureRecognizer:singleFingerTap];
    [touchView addGestureRecognizer:singleFingerTap];
    [self.videoPlayer.view addSubview:touchView];
    [self.cameraView addSubview:self.videoPlayer.view];
    [self.videoPlayer play];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if(isPlay == false){
        isPlay = true;
        [self.videoPlayer play];
    }else{
        isPlay = false;
        [self.videoPlayer pause];
    }
}

-(void)itemHoldTime:(NSTimer *)timer
{
    if(pressed == NO) return;
    
    if((self.slider.value) >= self.slider.maximumValue){
        finished = YES;
        [self itemTouchUpInside];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playRecordVideo) userInfo:nil repeats:NO];
    }else{
        if((self.slider.value + itemHoldTimer.timeInterval) > 2.0){
            self.stillButton.hidden = NO;
        }
        NSLog(@"%f", itemHoldTimer.timeInterval); 

        [UIView animateWithDuration:0.03 animations:^{
            [self.slider setValue:self.slider.value];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.01 animations:^{
                [self.slider setValue:(self.slider.value + itemHoldTimer.timeInterval)];
            }];
        }];

    }
}

int getRandomInt(int a, int b) {
    return rand()%((b)-(a)) + (a);
}
BOOL pressed = NO;

-(void)itemTouchDown{
    pressed = YES;
    if(finished == YES && self.slider.value == 0){
        itemHoldTimer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(itemHoldTime:) userInfo:nil repeats:YES];
        [itemHoldTimer fire];
        finished = NO;
        self.slider.value = 0;
    }else if(finished == NO){
        [itemHoldTimer resume];
    }
    
    NSString* filePath = [[[self captureManager] recorder] outputFileURL].path;
    filePath = [filePath stringByReplacingOccurrencesOfString:@".mov" withString:[NSString stringWithFormat:@"%d.mov", getRandomInt(0, 1000)]];
    if(![filePath hasPrefix:@"file://"]){
        filePath = [NSString  stringWithFormat: @"file://localhost%@", filePath];
    }
    [self.videoArray addObject:filePath];
    [[self captureManager] recorder].outputFileURL = [NSURL URLWithString:filePath];
    [[self captureManager] startRecording];
}

-(void)itemTouchUpInside {
    pressed = NO;
    if(finished == NO ){
        [itemHoldTimer pause];
    }else{
        [itemHoldTimer invalidate];
        itemHoldTimer = nil;
    }
    [[self captureManager] stopRecording];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVCamFocusModeObserverContext) {
        // Update the focus UI overlay string when the focus mode changes
		[focusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Toolbar Actions
- (IBAction)toggleCamera:(id)sender
{
    // Toggle between cameras when there is more than one
    [[self captureManager] toggleCamera];    
    // Do an initial focus
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}


- (IBAction)nextBtnClick:(id)sender{
    [self.videoPlayer stop];
    self.videoPlayer = nil;
    //self.captureManager = nil;
    //[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
    //self..isDismissingView = YES;
    //[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)captureStillVideo:(id)sender
{
    [self playRecordVideo];
    self.nextButton.hidden = NO;
    self.cameraToggleButton.hidden = YES;
    self.stillButton.hidden = YES;
}

@end

@implementation AVCamViewController (InternalMethods)

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    if ([captureVideoPreviewLayer isMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }    

    if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;

                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)updateButtonStates
{
	NSUInteger cameraCount = [[self captureManager] cameraCount];
	NSUInteger micCount = [[self captureManager] micCount];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (cameraCount < 2) {
            [[self cameraToggleButton] setEnabled:NO]; 
            if (cameraCount < 1) {
                [[self stillButton] setEnabled:NO];
            } else {
                [[self stillButton] setEnabled:YES];
            }
        } else {
            [[self cameraToggleButton] setEnabled:YES];
            [[self stillButton] setEnabled:YES];
        }
    });
}

@end

@implementation AVCamViewController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
        //[alertView release];
    });
}

- (void)captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
       // [[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Toggle recording button stop title")];
        //[[self recordButton] setEnabled:YES];
    });
}

- (void)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
       // [[self recordButton] setTitle:NSLocalizedString(@"Record", @"Toggle recording button record title")];
        //[[self recordButton] setEnabled:YES];
    });
    
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self stillButton] setEnabled:YES];
    });
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}

@end
