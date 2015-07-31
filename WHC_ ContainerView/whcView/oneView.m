//
//  oneView.m
//  WHC_ ContainerView
//
//  Created by 吴海超 on 15/5/18.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */

#import "oneView.h"
#import "WHC_BadgeView.h"
#import "UIView+WHC_ViewProperty.h"
@interface oneView ()<UITableViewDataSource , UITableViewDelegate>{
    UITableView  * _tv;
    NSString     * _title;
}

@end

@implementation oneView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString*)title{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
//        UILabel  * labTitle = [[UILabel alloc]initWithFrame:self.bounds];
//        labTitle.text = title;
//        labTitle.font = [UIFont boldSystemFontOfSize:40.0];
//        labTitle.textColor = [UIColor redColor];
//        labTitle.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:labTitle];
        _title = title;
        _tv = [[UITableView alloc]initWithFrame:self.bounds];
        [self addSubview:_tv];
        _tv.delegate = self;
        _tv.dataSource = self;
        [_tv reloadData];
    }
    return self;
}

- (NSString *)getTitle{
    return _title;
}

- (void)reloadView{
    [_tv reloadData];
}
#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString  * strCell = @"strCell";
    UITableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:strCell];
    WHC_BadgeView  * badgeView = nil;
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
        
    }
    for (NSInteger i = 0; i < cell.subviews.count; i++) {
        UIView * view = cell.subviews[i];
        if([view isKindOfClass:[WHC_BadgeView class]]){
            [view removeFromSuperview];
            view = nil;
        }
    }
    if([_title isEqualToString:@"ios"]){
        cell.width = [UIScreen mainScreen].bounds.size.width;
        CGRect  cellFrame = cell.frame;
        badgeView = [[WHC_BadgeView alloc]initWithSuperView:cell position:CGPointMake(cellFrame.size.width - 50.0, 15.0) radius:10.0];
        [badgeView setBadgeNumber:indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _title;
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

@end
