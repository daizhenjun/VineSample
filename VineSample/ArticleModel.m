//
//  ArticleModel.m
//  LikeVine
//
//  Created by 代 震军 on 13-6-17.
//  Copyright (c) 2013年 代 震军. All rights reserved.
//

#import "ArticleModel.h"

@implementation ArticleModel
@synthesize aId = _aId;
@synthesize cnId = _cnId;
@synthesize sId =_sId;
@synthesize posted = _posted;
@synthesize commentId = _commentId;
@synthesize commentTimestamp = _commentTimestamp;
@synthesize commentDigs = _commentDigs;
@synthesize subject = _subject;
@synthesize author =_author;
@synthesize commentContent = _commentContent;
@synthesize commentUser = _commentUser;
@synthesize isFavorite = _isFavorite;
@synthesize content = _content;
@synthesize commentsHot = _commentsHot;
@synthesize commentsRecently = _commentsRecently;
@synthesize videoUrl = _videoUrl;
- (void)dealloc
{
    self.aId = nil;
    self.cnId = nil;
    self.sId = nil;
    self.posted = nil;
    self.commentId = nil;
    self.commentTimestamp = nil;
    self.commentDigs = nil;
    self.subject = nil;
    self.author = nil;
    self.commentContent = nil;
    self.commentUser = nil;
    self.isFavorite = nil;
    self.content = nil;
    self.commentsHot = nil;
    self.commentsRecently = nil;
    self.commentNum = nil;
    self.videoUrl = nil;
   // [super dealloc];
}

@end
