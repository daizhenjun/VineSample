//
//  ViewController.m
//  VineSample
//
//  Created by 代 震军 on 13-6-17.
//  Copyright (c) 2013年 代 震军. All rights reserved.
//

#import "ViewController.h"
#import "VideoTableViewController.h"
#import "AVCamViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)vineListClick:(id) sender{
    VideoTableViewController* controller = [[VideoTableViewController alloc] init];
    //    [self.navigationController pushViewController:controller animated:YES];
    //    self.navigationItem.backBarButtonItem = [self backButton];
    //[self.view addSubview:controller.view];
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)vineVideoClick:(id) sender;{
    AVCamViewController* controller = [[AVCamViewController alloc] init];
    //    [self.navigationController pushViewController:controller animated:YES];
    //    self.navigationItem.backBarButtonItem = [self backButton];
    //[self.view addSubview:controller.view];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
