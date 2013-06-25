//
//  ArticleModel.h
//  LikeVine
//
//  Created by 代 震军 on 13-6-17.
//  Copyright (c) 2013年 代 震军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleModel : NSObject


@property (nonatomic,copy) NSString *aId;//文章ID
@property (nonatomic,copy) NSString *cnId;//频道ID
@property (nonatomic,copy) NSString *sId;//站点ID
@property (nonatomic,copy) NSString *posted;//发表时间(UTC时间戳)
@property (nonatomic,copy) NSString *commentId;//评论条目Id
@property (nonatomic,copy) NSString *commentTimestamp;//评论时间戳
@property (nonatomic,copy) NSString *commentDigs;//顶顶数目
@property (nonatomic,copy) NSString *subject;//标题
@property (nonatomic,copy) NSString *author;//作者
@property (nonatomic,copy) NSString *commentContent;//评论内容
@property (nonatomic,copy) NSString *commentUser;//评论者名称
@property (nonatomic,copy) NSString *isFavorite;//是否收藏
@property (nonatomic,retain) NSMutableArray *content;//正文内容
@property (nonatomic,retain) NSMutableArray *commentsHot;//热门评论数组
@property (nonatomic,retain) NSMutableArray *commentsRecently;//最新评论数组
@property (nonatomic,retain) NSString *sUrl;
@property (nonatomic,retain) NSString *sourceURL;
@property (nonatomic,retain) NSString *digged;//是否被顶过
@property (nonatomic,retain) NSString *source;// article source
@property (nonatomic,retain) NSString *videoUrl;
//channellist model
@property (nonatomic,copy) NSString *aType;//
@property (nonatomic,copy) NSString *sName;//
@property (nonatomic,copy) NSString *summary;//摘要
@property (nonatomic,copy) NSString *imageURL;
@property (nonatomic,copy) NSString *commentyNum;
@property (nonatomic,copy) NSString *imageWidth;
@property (nonatomic,copy) NSString *imageHeight;
@property (nonatomic,copy) NSString *commentNum;

- (BOOL)hasImage;

@end
