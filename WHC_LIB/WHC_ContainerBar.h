//
//  WHC_ContainerBar.h
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
#import "WHC_ContainerBarItem.h"

#define KWHC_DropBtn_Width (50.0)     //下拉按钮的宽度
#define KWHC_ContainerConfigurationKey  (@"ContainerConfiguration")
#define KWHC_ContainerTitlesArrKey      (@"ContainerTitlesArr")
#define KWHC_ContainerLaterTitlesArrKey (@"ContainerLaterTitlesArr")

@interface WHC_ContainerBarParam : NSObject

@property (nonatomic , assign) BOOL             visableCursor;     //游标是否可见

@property (nonatomic , assign) BOOL             isHeaderLine;     //头部是否有横线

@property (nonatomic , assign) BOOL             isFootLine;       //底部是否有横线

@property (nonatomic , assign) BOOL             isSegmentLine;    //是否有分隔线

@property (nonatomic , assign) NSInteger        defaultFocusItem;  //默认选中项

@property (nonatomic , assign) NSInteger        mustSaveItemCount;  //必须保留的项数

@property (nonatomic , assign) CGFloat          focusFontSize;     //聚焦标题字体大小

@property (nonatomic , assign) CGFloat          fontSize;          //标题字体大小

@property (nonatomic , assign) CGFloat          cursorHeight;      //游标高度

@property (nonatomic , assign) CGFloat          segmentLineMargin; //分隔线与头部或者底部间距

@property (nonatomic , assign) CGFloat          lineWidth;         //线宽

@property (nonatomic , assign) CGFloat          cursorMargin;      //游标边距

@property (nonatomic , strong) UIColor        * itemBarNBackgroudColor;//选项正常背景颜色

@property (nonatomic , strong) UIColor        * itemBarSBackgroudColor;//选项选中背景颜色

@property (nonatomic , strong) UIColor        * cursorColor;       //游标颜色

@property (nonatomic , strong) UIColor        * headerLineColor;   //头部线颜色

@property (nonatomic , strong) UIColor        * segmentLineColor;  //分隔线颜色

@property (nonatomic , strong) UIColor        * footLineColor;     //底部线颜色

@property (nonatomic , strong) UIColor        * fontColor;         //字体颜色

@property (nonatomic , strong) UIColor        * focusFontColor;    //聚焦字体颜色

@property (nonatomic , strong) NSMutableArray * titlesArr;         //标题数组

@property (nonatomic , strong) NSMutableArray * laterTitlesArr;    //将添加的标题数组

@property (nonatomic , strong) NSMutableArray * viewArr;           //视图数组

+ (WHC_ContainerBarParam *)getWHC_ContainerViewParamWithTitles:(NSMutableArray*)titlesArr laterTitlesArr:(NSMutableArray *)laterTitlesArr;

@end

@class WHC_ContainerBar;
@protocol  WHC_ContainerBarDelegate<NSObject>

@required
- (void)whc_ContainerBar:(WHC_ContainerBar *)whcContainerBar clickIndex:(NSInteger)index animated:(BOOL)animated;
@optional
- (void)whc_ContainerBar:(WHC_ContainerBar *)whcContainerBar clickDrop:(UIButton*)sender;
@end

@interface WHC_ContainerBar : UIView

@property (nonatomic , assign)id<WHC_ContainerBarDelegate>  delegate;

- (instancetype)initWithFrame:(CGRect)frame param:(WHC_ContainerBarParam*)param;

- (void)beginDynamicChangeStateOffsetX:(CGFloat)offsetX pageIndex:(NSInteger)pageIndex oriX:(CGFloat)oriX;

- (void)dynamicChangeStateOffsetX:(CGFloat)offsetX oriX:(CGFloat)oriX;

- (void)endDynamicChangeStateOffsetX:(CGFloat)offsetX currentPageIndex:(NSInteger)currentPageIndex;

- (void)rotateDropBtnDuring:(CGFloat)during;

- (UIImage *)getDropImage;

- (void)updateContainer;

- (void)updateContainerClickIndex:(NSInteger)index;

+ (void)saveContainerBarTitlesArr:(NSArray *)titlesArr laterTitlesArr:(NSArray *)laterTitlesArr;
@end
