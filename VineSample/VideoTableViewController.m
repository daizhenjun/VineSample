//
//  VideoTableViewController.m
//  LikeVine
//
//  Created by 代 震军 on 13-6-17.
//  Copyright (c) 2013年 代 震军. All rights reserved.
//

#import "VideoTableViewController.h"
#import "ArticleModel.h"
#import "VideoTableViewCell.h"
#import "AVCamViewController.h"
@interface VideoTableViewController ()

@end

@implementation VideoTableViewController
@synthesize tableView = _tableView;
@synthesize list = _list;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i = 0; i < 10 ; i++){
        ArticleModel* article = [[ArticleModel alloc] init];
        article.subject = [NSString stringWithFormat:@"主题%d", i];//标题
        article.author= [NSString stringWithFormat:@"作者%d", i];//作者
        article.commentContent= [NSString stringWithFormat:@"评论内容%d", i];//评论内容
        article.videoUrl= @"http://nt.discuz.net/upload/test.mp4";//
        [array addObject:article];
    }
    self.list = array;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ShootButton.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(vineVideoClick:) ];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    if(visiblePaths.count>0){
        VideoTableViewCell *cell = (VideoTableViewCell*)[self.tableView cellForRowAtIndexPath:[visiblePaths objectAtIndex:0]];
        [cell preparePlay];
    }
}

- (void)vineVideoClick:(id) sender;{
    AVCamViewController* controller = [[AVCamViewController alloc] init];
    //[self.navigationController pushViewController:controller animated:YES];
    //self.navigationItem.backBarButtonItem = [self backButton];
    //[self.view addSubview:controller.view];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Somewhere in your implementation file:
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    NSLog(@"Will begin dragging");
//}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self performSelectorInBackground:@selector(play) withObject:self];
//}

- (void)scrollProcess:(UIScrollView *)scrollView{
    CGFloat currentOffset = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom;
    NSLog(@"scroll position %f", currentOffset);
    
    float halfScreen = [ UIScreen mainScreen ].applicationFrame.size.height/2;
    NSLog(@"halfScreen %f", self.tableView.frame.size.height);
    //NSLog(@"halfScreen %f", halfScreen);
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    if(visiblePaths.count>0){
        VideoTableViewCell *cell = (VideoTableViewCell*)[self.tableView cellForRowAtIndexPath:[visiblePaths objectAtIndex:0]];
        if(visiblePaths.count >1){
            VideoTableViewCell *cell2 = (VideoTableViewCell*)[self.tableView cellForRowAtIndexPath:[visiblePaths objectAtIndex:1]];
            //NSLog(@"cell fill =%f", currentOffset - cell2.frame.origin.y);
            if((halfScreen)< (currentOffset - cell2.frame.origin.y)){
                cell = cell2;
            } 
        }
        NSLog(@"cell frame %f", cell.frame.origin.y);
        NSLog(@"cell size %f", cell.frame.size.height);
        if(currentOffset<= self.tableView.contentSize.height/*到底?*/
           && currentOffset >= self.tableView.frame.size.height/*顶部?*/)
            if(!(cell.isPlaying))
                [cell preparePlay];
    }

    NSLog(@"Will begin dragging");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollProcess:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
        [self scrollProcess:scrollView]; 
}



#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    VideoTableViewCell *cell = (VideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VideoTableViewCell" owner:nil options:nil] objectAtIndex:0];
    }
    ArticleModel *article = [self.list objectAtIndex:indexPath.row];
    [cell.siteNameLabel setText:article.subject];
    [cell.desLabel setText:article.author];
    [cell.timeLabel setText:article.commentContent];
    [cell.imgView setImage:[UIImage imageNamed:@"avatar.png"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone; //点击无色
    [cell setVideoUrl:article.videoUrl];
    NSLog(@"cell row %d", indexPath.row);
	return cell;
}
//NSIndexPath * selectPath;
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
////    NSString *listItem = [self.filteredListContent objectAtIndex:indexPath.row];
////    if ([listItem isEqualToString:@""]) {
////        return nil;
////    }
//    selectPath = indexPath;
//    return indexPath;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 600.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.list count]; 
}

NSIndexPath *selectedIndexPath;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedIndexPath = indexPath;
}


-(void)viewWillAppear:(BOOL)animated{
}
@end
