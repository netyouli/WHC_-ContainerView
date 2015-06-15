//
//  WHC_ContainerView.h
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

#import <UIKit/UIKit.h>
#import "WHC_ContainerBar.h"

@class WHC_ContainerView;

@protocol  WHC_ContainerViewDelegate<NSObject>

@required

- (NSArray *)whc_ContainerView:(WHC_ContainerView *)containerView updateContainerViewLayoutWithTitlesArr:(NSArray *)titlesArr;

- (void)whc_ContainerView:(WHC_ContainerView *)containerView loadContentForCurrentView:(UIView *)currentView currentIndex:(NSInteger)index;

@end

@interface WHC_ContainerView : UIView

@property (nonatomic , assign) id<WHC_ContainerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame param:(WHC_ContainerBarParam*)param;

+ (void)saveContainerBarTitlesArr:(NSArray *)titlesArr laterTitlesArr:(NSArray *)laterTitlesArr;

// mark:读取缓存中要显示的标题组
+ (NSArray *)readContainerBarTitlesArr;
// mark:读取缓存中待显示的标题组
+ (NSArray *)readContainerBarLaterTitlesArr;
@end
