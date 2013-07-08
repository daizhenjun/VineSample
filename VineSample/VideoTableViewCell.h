//
//  VideoTableViewCell.h
//  Discuz2
//
//  Created by comsenz on 13-4-17.
//  Copyright (c) 2013年 Lone Choy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoTableViewCell : UITableViewCell{
    NSString* videoUrlStr;
    UIImageView *iv;
}

@property (nonatomic, retain) MPMoviePlayerController* videoPlayer; 


@property(nonatomic,retain) IBOutlet UIImageView *imgView;
@property(nonatomic,retain) IBOutlet UILabel *siteNameLabel;
@property(nonatomic,retain) IBOutlet UILabel *desLabel;
@property(nonatomic,retain) IBOutlet UILabel *timeLabel;
@property(nonatomic,retain) IBOutlet UIButton *videoBtn;
@property(nonatomic)  BOOL  isPlaying;
//+ (MoviePlayerViewController *)controller:(NSURL *)videoUrl;
-(void) startDownLoad;
- (void) setVideoUrl:(NSString*)url;
- (void) preparePlay;
@end
