//
//  oneView.h
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

#import <UIKit/UIKit.h>

@interface oneView : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString*)title;

- (NSString *)getTitle;

- (void)reloadView;
@end
