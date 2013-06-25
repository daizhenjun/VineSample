//
//  VideoTableViewController.h
//  LikeVine
//
//  Created by 代 震军 on 13-6-17.
//  Copyright (c) 2013年 代 震军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *list;
-(void) setVideoUrl:(NSString*)url;
@end
