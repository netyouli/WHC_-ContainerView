//
//  WHC_BadgeView.m
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

#import "WHC_BadgeView.h"
#import "UIView+WHC_ViewProperty.h"

#define KWHC_BadgeFontSize                     (14.0) // 标记字体大小
#define KWHC_DefaultMaxCircleDistanceMultiple  (11.0) // 最大圆心距离倍数

@interface WHC_BadgeView ()<UIGestureRecognizerDelegate>{
    UILabel                         *    _badgeLabel;              //标记标签
    UIView                          *    _backView;                //背景视图
    UIPanGestureRecognizer          *    _badgePanGesture;         //标记拖拽手势
    CGFloat                              _radius;                  //标记标签的半径
    BOOL                                 _enableDragBadgeLabel;    //是否可以拖拽标签
    CGPoint                              _startCenterPoint;        //开始中心点
    CGPoint                              _originPoint;             //原坐标点
    CGPoint                              _position;                //实际位子
    CGFloat                              _validAttachDistance;     //有效吸附距离
    CGFloat                              _maxCircleDistance;       //最大圆心距离
    CGFloat                              _breakRadius;             //断开半径
    BOOL                                 _isBreak;                 //是否已经断开
    BOOL                                 _isEndDrag;               //是否结束拖拽
}

@end

@implementation WHC_BadgeView

- (instancetype)initWithSuperView:(UIView *)superView position:(CGPoint)position radius:(CGFloat)radius{
    UIView * backView = nil;
    UIViewController  * rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    backView = rootVC.view;
    NSParameterAssert(backView);
    CGRect   frame = [superView convertRect:backView.bounds fromView:backView];
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        _backView = backView;
        _radius = radius;
        _position = position;
        _originPoint = [superView convertPoint:position toView:_backView];
        CGRect  badgeLabelRc = {_originPoint , {radius * 2.0 ,radius * 2.0}};
        _badgeLabel = [[UILabel alloc]initWithFrame:badgeLabelRc];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.text = @"0";
        _badgeLabel.userInteractionEnabled = YES;
        _badgeLabel.font = [UIFont systemFontOfSize:KWHC_BadgeFontSize];
        [self initShape:_badgeLabel];
        [self addSubview:_badgeLabel];
        [self initData];
        [superView addSubview:self];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.frame = [self.superview convertRect:_backView.bounds fromView:_backView];
    _originPoint = [self.superview convertPoint:_position toView:_backView];
    _badgeLabel.xy = _originPoint;
    _startCenterPoint = _badgeLabel.center;
}

- (void)initData{
    _isEndDrag = YES;
    _breakRadius = _radius / 3.0;
    _validAttachDistance = _radius * 2.0;
    _maxCircleDistance = _radius * KWHC_DefaultMaxCircleDistanceMultiple;
    _badgePanGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleBadgeLabelPanGesture:)];
    _badgePanGesture.delegate = self;
    [self addGestureRecognizer:_badgePanGesture];
}

- (void)initShape:(UIView *)view{
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = _radius;
    view.layer.masksToBounds = YES;
}

- (NSInteger)setBadgeNumber:(NSInteger)number{
    NSInteger    frontBadgeNumber = number;
    _badgeLabel.text = @(number).stringValue;
    return frontBadgeNumber;
}

- (void)setValidAttachDistance:(CGFloat)validAttachDistance{
    _validAttachDistance = validAttachDistance;
}

- (void)setMaxCircleDistance:(CGFloat)maxCircleDistance{
    _maxCircleDistance = maxCircleDistance;
}

- (CGFloat)twoPointDistancePoint1:(CGPoint)point1 point2:(CGPoint)point2{
    CGFloat  offsetX = fabs(point2.x - point1.x);
    CGFloat  offsetY = fabs(point2.y - point1.y);
    return sqrt(offsetX * offsetX + offsetY * offsetY);
}

- (void)removeSelf{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        if(_delegate && [_delegate respondsToSelector:@selector(whc_BadgeViewDidRemoveFromSuperViewWithIndex:)]){
            [_delegate whc_BadgeViewDidRemoveFromSuperViewWithIndex:_index];
        }
        [self removeFromSuperview];
    }];
}

- (void)drawRect:(CGRect)rect{
    if(_isBreak){
        return;
    }
    UIBezierPath  * bezierPath = [UIBezierPath bezierPath];
    CGPoint  centerPoint = _badgeLabel.center;
    CGFloat  radius = 0.0;
    CGFloat  startAngle = 0.0;
    CGFloat  endAngle = 0.0;
    CGFloat  circleDistance = [self twoPointDistancePoint1:_startCenterPoint point2:centerPoint];
    radius = _radius - (circleDistance / _maxCircleDistance) * _radius;
    if(radius < 0){
        radius = 0.0;
    }
    //要计算四个点坐标以及两个贝塞尔曲线控制点
    CGPoint  aPoint   = CGPointZero,
             bPoint   = CGPointZero,
             cPoint   = CGPointZero,
             dPoint   = CGPointZero,
           ctl1Point  = CGPointZero,
           ctl2Point  = CGPointZero;
    
    CGFloat  sinAngle = (centerPoint.x - _startCenterPoint.x) / circleDistance;
    CGFloat  cosAngle = (centerPoint.y - _startCenterPoint.y) / circleDistance;
    if(circleDistance == 0.0){
        sinAngle = 0.0;
        cosAngle = 1.0;
    }
    if(_breakRadius < radius){
        aPoint = CGPointMake(_startCenterPoint.x - radius * cosAngle, _startCenterPoint.y + radius * sinAngle);
        bPoint = CGPointMake(_startCenterPoint.x + radius * cosAngle, _startCenterPoint.y - radius * sinAngle);
        cPoint = CGPointMake(centerPoint.x + _radius * cosAngle, centerPoint.y - _radius * sinAngle);
        dPoint = CGPointMake(centerPoint.x - _radius * cosAngle, centerPoint.y + _radius * sinAngle);
        ctl1Point = CGPointMake(aPoint.x + (circleDistance / 2.0) * sinAngle, aPoint.y + (circleDistance / 2.0) * cosAngle);
        ctl2Point = CGPointMake(bPoint.x + (circleDistance / 2.0) * sinAngle, bPoint.y + (circleDistance / 2.0) * cosAngle);
    }else{
        _isBreak = YES;
        radius = 0.0;
    }
    if(_isEndDrag){
        radius = 0.0;
        aPoint   = CGPointZero,
        bPoint   = CGPointZero,
        cPoint   = CGPointZero,
        dPoint   = CGPointZero,
        ctl1Point  = CGPointZero,
        ctl2Point  = CGPointZero;
    }
    startAngle = asin(sinAngle) / M_PI * 180.0;
    endAngle = M_PI - startAngle;
    if(startAngle > 0){
        endAngle = M_PI + startAngle;
    }
    
    [bezierPath moveToPoint:aPoint];
    [bezierPath addQuadCurveToPoint:dPoint controlPoint:ctl1Point];
    [bezierPath addLineToPoint:cPoint];
    [bezierPath addQuadCurveToPoint:bPoint controlPoint:ctl2Point];
    [bezierPath moveToPoint:aPoint];
    [bezierPath closePath];
    
    CGContextRef    context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 0.1);
    CGContextAddArc(context, _startCenterPoint.x, _startCenterPoint.y, radius, 0, M_PI * 2.0, NO);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextDrawPath(context, kCGPathFillStroke);
    UIGraphicsEndImageContext();
    
    
}

- (void)handleEndDragAnimation:(CGFloat)circleDistance{
    //可重新被吸附震动动画效果
    if([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setNeedsDisplay];
            _badgeLabel.center = _startCenterPoint;
        } completion:nil];
        return;
    }
    
    CGPoint  centerPoint = _badgeLabel.center;
    CGFloat  sinAngle = (centerPoint.x - _startCenterPoint.x) / circleDistance;
    CGFloat  cosAngle = (centerPoint.y - _startCenterPoint.y) / circleDistance;
    if(circleDistance == 0.0){
        sinAngle = 0.0;
        cosAngle = 1.0;
    }
    CGFloat  shockDistance = _radius * circleDistance / _maxCircleDistance;
    CGPoint  shockPoint1 = CGPointMake(_startCenterPoint.x - shockDistance * sinAngle,
                                       _startCenterPoint.y - shockDistance * cosAngle);
    CGPoint  shockPoint2 = CGPointMake(shockPoint1.x + shockDistance * sinAngle * 2.0,
                                       shockPoint1.y + shockDistance * cosAngle * 2.0);
    CGFloat  during = 0.5 / 4.0;
    [UIView animateWithDuration:during delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setNeedsDisplay];
        if([self twoPointDistancePoint1:_badgeLabel.center point2:shockPoint1] >
           [self twoPointDistancePoint1:_badgeLabel.center point2:shockPoint2]){
            _badgeLabel.center = shockPoint1;
        }else{
            _badgeLabel.center = shockPoint2;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:during delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if(_badgeLabel.centerX == shockPoint1.x){
                _badgeLabel.center = shockPoint2;
            }else{
                _badgeLabel.center = shockPoint1;
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:during delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _badgeLabel.center = _startCenterPoint;
            } completion:nil];
        }];
    }];
    
}

#pragma mark - handleLongGesture -
- (void)handleBadgeLabelPanGesture:(UIPanGestureRecognizer *)panGesture{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            _isEndDrag = NO;
            CGPoint point = [panGesture locationInView:panGesture.view];
            _enableDragBadgeLabel =  CGRectContainsPoint(_badgeLabel.frame, point);
            if(_enableDragBadgeLabel){
                _isBreak = NO;
                [self.superview.superview bringSubviewToFront:self.superview];
                if(_delegate && [_delegate respondsToSelector:@selector(whc_BadgeViewWillStartDrag)]){
                    [_delegate whc_BadgeViewWillStartDrag];
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if(_enableDragBadgeLabel){
                _badgeLabel.center = [panGesture locationInView:panGesture.view];
                [self setNeedsDisplay];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            _isEndDrag = YES;
            if(_enableDragBadgeLabel){
                CGFloat  circleDistance = [self twoPointDistancePoint1:_startCenterPoint point2:_badgeLabel.center];
                if(_isBreak){
                    if(_validAttachDistance >= circleDistance){
                        [self handleEndDragAnimation:circleDistance];
                    }else{
                        //销毁标签
                        [self removeSelf];
                    }
                }else{
                    [self handleEndDragAnimation:circleDistance];
                }
                if(_delegate && [_delegate respondsToSelector:@selector(whc_BadgeViewDidEndDrag)]){
                    [_delegate whc_BadgeViewDidEndDrag];
                }
            }
        }
        default:
            break;
    }
    
}

#pragma mark - UIGestureRecognizerDelegate -
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    BOOL  result = YES;
    if([gestureRecognizer isEqual:_badgePanGesture]){
        result = CGRectContainsPoint(_badgeLabel.frame, [gestureRecognizer locationInView:gestureRecognizer.view]);
    }
    return result;
}
@end
