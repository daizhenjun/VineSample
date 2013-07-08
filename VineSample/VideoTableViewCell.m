//
//  SubscribeSiteCell.m
//  Discuz2
//
//  Created by comsenz on 13-4-17.
//  Copyright (c) 2013年 Lone Choy. All rights reserved.
//

#import "VideoTableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoTableViewCell
@synthesize imgView = _imgView,siteNameLabel = _siteNameLabel,timeLabel = _timeLabel,desLabel = _desLabel, videoBtn = _videoBtn, isPlaying = _isPlaying;


- (void)dealloc
{
    self.imgView = nil;
    self.siteNameLabel = nil;
    self.desLabel = nil;
    self.timeLabel = nil;
    self.videoBtn = nil;
    
    if(self.videoPlayer != nil){
       [self.videoPlayer stop];
        self.videoPlayer = nil;
    }
    
    videoUrlStr = nil;
    iv = nil;
    self.isPlaying = NO;
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"VideoTableViewCell====dealloc");
    //[super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    self.isPlaying = NO;
    return self;
}

//获取本地视频截图
-(UIImage *)getImage
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:videoUrlStr];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = self.videoBtn.bounds.size;//CGSizeMake(600, 450);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(10, 10) actualTime:NULL error:&error];
    return [UIImage imageWithCGImage: img];
}


-(void) startDownLoad{
    @try {
        NSURL *video_Url = [NSURL URLWithString:videoUrlStr];
        //if ([video_Url checkResourceIsReachableAndReturnError:nil] == NO)
        //{
        //    NSLog(@"Video doesn't not exist.");
        //    return;
        //}
        //if(self.videoPlayer == nil){
            self.videoPlayer = [[MPMoviePlayerController alloc] init];
            self.videoPlayer.controlStyle             = MPMovieControlStyleNone;////MPMovieControlStyleDefault;//
            self.videoPlayer.scalingMode              = MPMovieScalingModeFill;//MPMovieScalingModeAspectFit;
            self.videoPlayer.shouldAutoplay           = NO;
            self.videoPlayer.view.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.videoPlayer.view.autoresizesSubviews = YES;
            self.videoPlayer.view.frame               = self.videoBtn.bounds;
            //self.videoPlayer.view.backgroundColor = [UIColor blueColor];
            self.videoPlayer.repeatMode               = MPMovieRepeatModeOne;
            [self.videoPlayer playableDuration];
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center addObserver:self
                       selector:@selector(moviePlayBackDidFinish:)
                           name:MPMoviePlayerPlaybackDidFinishNotification
                         object:self.videoPlayer];

        //}
        [self.videoPlayer setContentURL:video_Url];
        [self.videoPlayer prepareToPlay];
        
                
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleSingleTap:)];
        //if(thumbnail == nil){
        UIImage * thumbnail = [self.videoPlayer thumbnailImageAtTime:0.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
            if(thumbnail == nil){
                thumbnail = [UIImage imageNamed:@"play.png"];
            }
        //}
        iv =[[UIImageView alloc] initWithImage:thumbnail];
        iv.userInteractionEnabled = YES;
        iv.frame = self.videoPlayer.view.frame;
        [iv addGestureRecognizer:singleFingerTap];
        
        
        UIView *touchView = [[UIView alloc] initWithFrame:self.videoPlayer.view.bounds];
        [touchView addGestureRecognizer:singleFingerTap];
        [touchView addSubview:iv];
        
        [self.videoBtn addSubview:self.videoPlayer.view];
        [self.videoBtn addSubview:touchView];
        //if(isPlay && self.videoPlayer != nil && self.videoPlayer.loadState != MPMovieLoadStateUnknown){
            //[self.videoPlayer play];
            [self play];
            //[self performSelectorInBackground:@selector(play) withObject:self];
        //}
    }
    @catch (NSException *exception) {
//        iv =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play.png"]];
        if(exception != nil)
            NSLog(@"%@",[NSString stringWithFormat:@"StartDownLoad====error====%@===%@",exception.reason, exception.description]);
//        self.videoPlayer = nil;
    }
    @finally {
        ;
    }
    
}

- (void) moviePlayBackDidFinish : (NSNotification *) notification
{
    iv.hidden = NO;
    
    MPMoviePlayerController * player = notification.object;
    [player stop];
    //rplayer = nil;
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isPlaying = NO;
    NSLog(@"======moviePlayBackDidFinish=========");
}

- (void) setVideoUrl:(NSString*)url{
     videoUrlStr = url;
}

//仅在本类内部使用
-(void) play{
    @try {
        iv.hidden = YES;
        if(self.videoPlayer != nil) {/*&& self.videoPlayer.loadState != MPMovieLoadStateUnknown*/
            [self.videoPlayer play];
            self.isPlaying = YES;
        }
    }@catch (NSException *exception) {
        NSLog(@"%@",[NSString stringWithFormat:@"StartDownLoad====error====%@===%@",exception.reason, exception.description]);
        self.isPlaying = NO;
    }
}

- (void)preparePlay{
    @try {
        [self performSelectorInBackground:@selector(startDownLoad) withObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[NSString stringWithFormat:@"StartDownLoad====error====%@===%@",exception.reason, exception.description]);
    }
}



- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if(self.isPlaying == false){
        [self play];
    }else{
        self.isPlaying = false;
        [self.videoPlayer pause];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    //[_siteNameLabel setTextColor:[SRColor colorWithHexString:@"#1F1F1F"]];
    //[_siteNameLabel setHighlightedTextColor:[SRColor colorWithHexString:@"#1F1F1F"]];
}

//
//- (void)setNewPosted:(NSNumber *)newNum
//{
//    if ([newNum intValue] >0) {
//        [_badgeBtn setTitle:[NSString stringWithFormat:@"%@",newNum] forState:UIControlStateNormal];
//        [_badgeBtn sizeToFit];
//        UIImage *image = [UIImage imageNamed:@"dot.png"];
//        if ([image respondsToSelector:@selector(stretchableImageWithLeftCapWidth:topCapHeight:)]) {
//            image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:0];
//        } else {
//            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)];
//        }
//        [_badgeBtn setBackgroundImage:image forState:UIControlStateNormal];
//        [_siteNameLabel sizeToFit];
//        CGRect frame = _badgeBtn.frame;
//        frame.origin.x = _siteNameLabel.frame.origin.x + _siteNameLabel.frame.size.width +5.0;
//        [_badgeBtn setFrame:frame];
//        [_badgeBtn setHidden:NO];
//    } else {
//        [_siteNameLabel sizeToFit];
//        [_badgeBtn setHidden:YES];
//    }
//
//    
//}

@end
