//
//  ViewController.h
//  VineSample
//
//  Created by 代 震军 on 13-6-17.
//  Copyright (c) 2013年 代 震军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIButton*  vineListButton;
@property (retain, nonatomic) IBOutlet UIButton*  vineVideoButton;
- (IBAction)vineListClick:(id) sender;
- (IBAction)vineVideoClick:(id) sender;
@end
