//
//  WHC_ContainerBarItem.h
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
#import "UIView+WHC_ViewProperty.h"

typedef enum _WHCBarItemStyle{
    TITLE_SHOW,               //首页展示类型
    EDIT_SHOW,                //编辑展示类型
    ADD_SHOW                  //编辑添加展示类型
}WHCBarItemStyle;

@class WHC_ContainerBarItem;
@protocol WHC_ContainerBarItemDelegate <NSObject>

@optional
- (void)whcContainerBarItem:(WHC_ContainerBarItem*)barItem clickIndex:(NSInteger)index animated:(BOOL)animated;

- (void)whcContainerBarItem:(WHC_ContainerBarItem *)barItem clickDeleteBtn:(UIButton*)sender index:(NSInteger)index;
@end

@interface WHC_ContainerBarItem : UIView

@property (nonatomic , assign)   id<WHC_ContainerBarItemDelegate>delegate;

@property (nonatomic , strong)   NSString  * title;                 //标题
@property (nonatomic , assign)   NSInteger   index;                 //下标
@property (nonatomic , assign)   CGFloat     normalFontSize;        //正常字体大小
@property (nonatomic , assign)   CGFloat     selectedFontSize;      //选择时字体大小
@property (nonatomic , strong)   UIColor   * normalTitleColor;      //正常标题颜色
@property (nonatomic , strong)   UIColor   * selectedTitleColor;    //选择标题颜色
@property (nonatomic , strong)   UIColor   * normalBackgroundColor; //正常背景颜色
@property (nonatomic , strong)   UIColor   * selectedBackgroundColor;//选择背景颜色

@property (nonatomic , assign)   BOOL        selected;

- (instancetype)initWithFrame:(CGRect)frame Style:(WHCBarItemStyle)style;

- (void)addBadgeViewWithPosition:(CGPoint)position radius:(CGFloat)radius withBadgeNumber:(NSInteger)badgeNumber; 

- (void)removeBadgeView;

- (void)dynamicChangeBackgroudColor:(UIColor *)color;

- (void)dynamicChangeTextColor:(UIColor *)color;

- (void)dynamicChangeTextSize:(UIFont *)font;

- (void)setItemStyle:(WHCBarItemStyle)style;

- (void)startEdit;

- (void)stopEdit;
@end
