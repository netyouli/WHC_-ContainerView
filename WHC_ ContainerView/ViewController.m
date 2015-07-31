//
//  ViewController.m
//  WHC_ ContainerView
//
//  Created by 吴海超 on 15/5/15.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */

#import "ViewController.h"
#import "WHC_ContainerView.h"
#import "WHC_ContainerBar.h"
#import "oneView.h"
#import "WHC_BadgeView.h"
@interface ViewController ()<WHC_ContainerViewDelegate>{
    NSMutableArray  * viewArr ;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"QQ:712641411";
    viewArr = [NSMutableArray new];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    CGRect  containerViewRC = {0.0,64.0,self.view.width,self.view.height - 64.0 - 50.0};
    NSArray         * titles = @[@"android",@"ios",@"wp",@"windows",@"apple",@"google",@"baidu",@"腾讯",@"纬创",@"吴海超"];
    NSMutableArray  * titlesArr = [titles mutableCopy];
    NSArray         * laterTitlesArr =  @[@"北京",@"上海",@"深圳",@"广州",@"武汉",@"新洲",@"光谷",@"软件源",@"硬件",@"shit",@"fuck",@"北京",@"上海",@"深圳",@"广州",@"武汉",@"新洲",@"光谷",@"软件源",@"硬件",@"shit",@"fuck",@"北京",@"上海",@"深圳",@"广州",@"武汉",@"新洲",@"光谷",@"软件源",@"硬件",@"shit",@"fuck",@"北京",@"上海",@"深圳",@"广州",@"武汉",@"新洲",@"光谷",@"软件源",@"硬件",@"shit",@"fuck",@"北京",@"上海",@"深圳",@"广州",@"武汉",@"新洲",@"光谷",@"软件源",@"硬件",@"shit",@"fuck",@"北京",@"上海",@"深圳",@"广州",@"武汉",@"新洲",@"光谷",@"软件源",@"硬件",@"shit",@"fuck"];
    if(_tyle == 1){
        WHC_ContainerView  * containerView = [[WHC_ContainerView alloc]initWithFrame:containerViewRC param:[WHC_ContainerBarParam getWHC_ContainerViewParamWithTitles:titlesArr laterTitlesArr:[laterTitlesArr mutableCopy]]];
        containerView.delegate = self;
        [self.view addSubview:containerView];
    }else if(_tyle == 2){
        WHC_ContainerBarParam * param =  [WHC_ContainerBarParam getWHC_ContainerViewParamWithTitles:titlesArr laterTitlesArr:[laterTitlesArr mutableCopy]];
        param.visableCursor = YES;
        param.isHeaderLine = NO;
        param.isFootLine = NO;
        param.isSegmentLine = NO;
        WHC_ContainerView  * containerView = [[WHC_ContainerView alloc]initWithFrame:containerViewRC param:param];
        containerView.delegate = self;
        [self.view addSubview:containerView];
    }
   
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setTyle:(NSInteger)tyle{
        _tyle = tyle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - WHC_ContainerViewDelegate -

- (NSArray *)whc_ContainerView:(WHC_ContainerView *)containerView updateContainerViewLayoutWithTitlesArr:(NSArray *)titlesArr{
    for (NSInteger i = 0; i < viewArr.count;) {
        oneView  * view = viewArr[i];
        [view removeFromSuperview];
        [viewArr removeObject:view];
        view = nil;
    }
    CGRect  containerViewRC = {0.0,64.0,self.view.width,self.view.height - 64.0};
    for (NSString * title in titlesArr) {
        oneView  * view = [[oneView alloc]initWithFrame:containerViewRC title:title];
        [viewArr addObject:view];
    }
    return viewArr;
}

- (void)whc_ContainerView:(WHC_ContainerView *)containerView loadContentForCurrentView:(UIView *)currentView currentIndex:(NSInteger)index{
    //切换pageView的时候这里会调用来更新currentview 的内容
//    NSLog(@"title = %@",[((oneView *)currentView) getTitle]);
    [((oneView*)currentView) reloadView];
}

@end
