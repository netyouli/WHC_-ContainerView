//
//  WHC_BadgeView.h
//  WHC_ ContainerView
//
//  Created by 吴海超 on 15/6/9.
//  Copyright (c) 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */

#import <UIKit/UIKit.h>

@class WHC_BadgeView;
@protocol  WHC_BadgeViewDelegate<NSObject>

- (void)whc_BadgeViewDidRemoveFromSuperViewWithIndex:(NSInteger)index;

@optional
- (void)whc_BadgeViewWillStartDrag;

- (void)whc_BadgeViewDidEndDrag;
@end

@interface WHC_BadgeView : UIView
@property (nonatomic , assign)NSInteger    index;
@property (nonatomic , assign)id<WHC_BadgeViewDelegate> delegate;

- (instancetype)initWithSuperView:(UIView *)superView position:(CGPoint)position radius:(CGFloat)radius;

//设置标签数字
- (NSInteger)setBadgeNumber:(NSInteger)number;

//设置有效吸附距离
- (void)setValidAttachDistance:(CGFloat)validAttachDistance;

//设置最大圆心距离(拖拽断开距离默认半径11陪)
- (void)setMaxCircleDistance:(CGFloat)maxCircleDistance;

//手动销毁自己
- (void)removeSelf;
@end
