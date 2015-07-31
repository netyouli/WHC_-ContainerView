//
//  WHC_ContainerView.m
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

#import "WHC_ContainerView.h"

#define  KWHC_ContainerBarHeight     (40.0)                  //容器条高度
#define  KWHC_ButtonColumns          (4)                     //按钮列数
#define  KWHC_ButtonMargin            (20.0)                 //按钮边距
#define  KWHC_LableMargin            (20.0)                  //标签边距
#define  KWHC_LableFontSize          (20.0)                  //标签字体大小
#define  KWHC_EditButtonWidth        (80.0)                  //编辑按钮宽度
#define  KWHC_EditButtonHeight       (30.0)                  //编辑按钮高度
#define  KWHC_EditButtonTag          (100)                   //编辑按钮id
#define  KWHC_DropButtonTag          (101)                   //下拉按钮id
#define  KWHC_ShowAnimationDuring    (0.25)                  //编辑视图显示动画周期
#define  KWHC_ShowAlertMsg           (@"WHC:必须保留4项")      //保留项的限制提示

@interface WHC_ContainerView ()<UIScrollViewDelegate , WHC_ContainerBarDelegate , WHC_ContainerBarItemDelegate>{
    UIScrollView                       * _containerView;     //容器滚动器
    UIScrollView                       * _addScrollView;     //待添加滚动背部视图
    WHC_ContainerBar                   * _containerBar;      //顶部容器条
    WHC_ContainerBarParam              * _containerBarParam; //容器创建参数
    UIView                             * _editView;          //编辑菜单视图
    UIView                             * _addItemView;       //增加栏目视图
    UIView                             * _labView;           //标签
    UIButton                           * _dropBtn;           //下拉按钮
    UIButton                           * _editButton;        //编辑按钮
    UIImageView                        * _dropImageView;     //下拉图片
    NSInteger                            _currentPageIndex;  //当前页下标
    BOOL                                 _isClickSwitch;     //是否单击切换页
    BOOL                                 _isBigSwitch;       //是否进行大切换
    BOOL                                 _isAnimationMoving; //正在动画移动中
    BOOL                                 _canMoveBarItem;    //可移动项
    BOOL                                 _isTouchEnd;        //是否触摸结束
    BOOL                                 _isSelectedEditBtn; //是否選擇編輯按鈕
    BOOL                                 _isAddAnimation;    //正在执行添加动画
    BOOL                                 _isDeleteAnimation; //正在执行删除动画
    BOOL                                 _isClickDrop;       //是否点击下拉按钮
    CGPoint                              _startPoint;        //长按开始点
    NSInteger                            _moveBarItemIndex;  //可移动项的下标
    NSInteger                            _editRowCount;      //可编辑的行数
    NSInteger                            _clickItemBarIndex; //单击item下标
    WHC_ContainerBarItem               * _moveBarItem;       //可移动项
    
    NSMutableArray                     * _pointArr;          //编辑视图上Item坐标数组
    NSMutableArray                     * _addPointArr;       //增加视图上Item坐标数组
    NSMutableArray                     * _barItemArr;        //编辑视图上Item数组
    NSMutableArray                     * _addBarItemArr;     //增加视图上Item数组
}

@end

@implementation WHC_ContainerView

- (instancetype)initWithFrame:(CGRect)frame param:(WHC_ContainerBarParam*)param{
    NSParameterAssert(param);
    self = [super initWithFrame:frame];
    if(self){
        _containerBarParam = param;
        [self initUILayout];
    }
    return self;
}

- (void)setDelegate:(id<WHC_ContainerViewDelegate>)delegate{
    _delegate = delegate;
    [self addContentViewToContainerView];
}

- (void)initUILayout{
    _isClickDrop = YES;
    _pointArr = [NSMutableArray new];
    _barItemArr = [NSMutableArray new];
    _addBarItemArr = [NSMutableArray new];
    _addPointArr = [NSMutableArray new];
    CGRect    containerBarRC = self.bounds;
    containerBarRC.size.height = KWHC_ContainerBarHeight;
    _containerBar = [[WHC_ContainerBar alloc]initWithFrame:containerBarRC param:_containerBarParam];
    _containerBar.delegate = self;
    [self addSubview:_containerBar];
    
    _containerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0, KWHC_ContainerBarHeight, self.width, self.height - KWHC_ContainerBarHeight)];
    _containerView.showsHorizontalScrollIndicator = NO;
    _containerView.showsVerticalScrollIndicator = NO;
    _containerView.delegate = self;
    _containerView.pagingEnabled = YES;
    
    _editView = [self createEditView];
    [self addContentViewToContainerView];
    [self addSubview:_containerView];
    
}

- (UILabel *)createLable:(CGRect)frame txt:(NSString *)txt{
    UILabel  * lab = [[UILabel alloc]initWithFrame:CGRectMake(KWHC_LableMargin, 0.0, self.width / 2.0, KWHC_ContainerBarHeight)];
    lab.text = txt;
    lab.textColor = [UIColor blackColor];
    lab.font = [UIFont boldSystemFontOfSize:KWHC_LableFontSize];
    return lab;
}

- (UIButton *)createButton:(CGRect)frame txt:(NSString *)txt tag:(NSInteger)tag{
    UIButton  * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.tag = tag;
    btn.layer.cornerRadius = btn.height / 2.0;
    btn.layer.borderColor = [UIColor redColor].CGColor;
    btn.layer.borderWidth = 0.5;
    btn.layer.masksToBounds = YES;
    [btn setTitle:txt forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickEditViewButton:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIView *)createEditView{
    UIView  * editView = [[UIView alloc]initWithFrame:self.bounds];
    editView.backgroundColor = [UIColor whiteColor];
    
    UILongPressGestureRecognizer     * longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
    [editView addGestureRecognizer:longPressGesture];
    
    CGRect    rc = {KWHC_LableMargin, 0.0, self.width / 2.0, KWHC_ContainerBarHeight};
    [editView addSubview:[self createLable:rc txt:@"切换栏目"]];
    
    rc = CGRectMake(CGRectGetMaxX(rc), (KWHC_ContainerBarHeight - KWHC_EditButtonHeight) / 2.0, KWHC_EditButtonWidth, KWHC_EditButtonHeight);
    _editButton = [self createButton:rc txt:@"排序删除" tag:KWHC_EditButtonTag];
    [_editButton setTitle:@"完成" forState:UIControlStateSelected];
    [editView addSubview:_editButton];
    
    _dropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _dropBtn.selected = YES;
    _dropBtn.frame = CGRectMake(self.width - KWHC_DropBtn_Width, 0.0, KWHC_DropBtn_Width, KWHC_ContainerBarHeight);
    _dropBtn.tag = KWHC_DropButtonTag;
    _dropBtn.backgroundColor = [UIColor clearColor];
    [_dropBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_dropBtn addTarget:self action:@selector(clickEditViewButton:) forControlEvents:UIControlEventTouchUpInside];
    [editView addSubview:_dropBtn];
    
    _dropImageView = [[UIImageView alloc]initWithFrame:_dropBtn.bounds];
    _dropImageView.backgroundColor = [UIColor clearColor];
    _dropImageView.contentMode = UIViewContentModeCenter;
    _dropImageView.image = [_containerBar getDropImage];
    [_dropBtn addSubview:_dropImageView];
    
    _editRowCount = [self calcRowCount];
    CGFloat        addItemViewY = (_editRowCount + 1) * KWHC_ContainerBarHeight + (KWHC_ContainerBarHeight - KWHC_EditButtonHeight) / 2.0;
    CGRect         addItemViewRC = {0.0, addItemViewY, self.width, self.height - addItemViewY};
    _addItemView = [[UIView alloc]initWithFrame:addItemViewRC];
    _addItemView.backgroundColor = editView.backgroundColor;
    [editView addSubview:_addItemView];
    
    CGRect labViewRC = {KWHC_LableMargin, 0.0, self.width, KWHC_ContainerBarHeight};
    _labView = [[UIView alloc]initWithFrame:labViewRC];
    _labView.backgroundColor = [UIColor colorWithWhite:240.0 / 255.0 alpha:1.0];
    _labView.x = 0.0;
    [_addItemView addSubview:_labView];
    UILabel  * lab = [self createLable:rc txt:@"点击添加更多栏目"];
    [_labView addSubview:lab];
    
    CGRect    addScrollViewRC = {0.0, KWHC_ContainerBarHeight, self.width, _addItemView.height - KWHC_ContainerBarHeight};
    _addScrollView = [[UIScrollView alloc]initWithFrame:addScrollViewRC];
    _addScrollView.showsHorizontalScrollIndicator = NO;
    _addScrollView.showsVerticalScrollIndicator = YES;
    _addScrollView.contentSize = _addScrollView.size;
    [_addItemView addSubview:_addScrollView];
    return editView;
}

- (NSInteger)calcRowCount{
    NSInteger  count = _containerBarParam.titlesArr.count;
    NSInteger  rowCount = count / KWHC_ButtonColumns + ((count % KWHC_ButtonColumns) != 0 ? 1 : 0);
    return rowCount;
}

- (void)clearMemoryArr:(NSArray *)array{
    if(array){
        for (NSInteger i = 0; i < array.count; i++) {
            NSObject * object = array[i];
            if([object isKindOfClass:[UIView class]]){
                [((UIView *)object) removeFromSuperview];
            }
            object = nil;
        }
    }
}

- (void)addContentViewToContainerView{
    if(_delegate && [_delegate respondsToSelector:@selector(whc_ContainerView:updateContainerViewLayoutWithTitlesArr:)]){
        if(_containerBarParam.viewArr){
            for(NSInteger i = 0; i < _containerBarParam.viewArr.count; i++){
                UIView * contentView = _containerBarParam.viewArr[i];
                if([_containerView.subviews containsObject:contentView]){
                    [contentView removeFromSuperview];
                }
                contentView = nil;
            }
            [_containerBarParam.viewArr removeAllObjects];
        }
        _containerBarParam.viewArr = [[_delegate whc_ContainerView:self updateContainerViewLayoutWithTitlesArr:_containerBarParam.titlesArr] mutableCopy];
    }
    if(_containerBarParam.viewArr){
        NSInteger  viewCount = _containerBarParam.viewArr.count;
        for (NSInteger i = 0; i < viewCount; i++) {
            UIView * contentView = _containerBarParam.viewArr[i];
            contentView.tag = i + 1;
            contentView.xy = CGPointMake(i * self.width, 0.0);
            contentView.size = CGSizeMake(self.width, _containerView.height);
            [_containerView addSubview:contentView];
        }
        _containerView.contentSize = CGSizeMake(viewCount * self.width, 0.0);
        if(_currentPageIndex > _containerBarParam.viewArr.count - 1){
            _currentPageIndex = _containerBarParam.viewArr.count - 1;
        }
        [_containerView setContentOffset:CGPointMake(_currentPageIndex * self.width, 0.0) animated:NO];
    }
}

- (CGFloat)layoutBarItemToView:(UIView *)view titleArr:(NSArray *)titleArr barItemArr:(NSMutableArray *)barItemArr pointArr:(NSMutableArray *)pointArr yConst:(CGFloat)yConst style:(WHCBarItemStyle)style{
    CGFloat   btnWidth = (self.width - (KWHC_ButtonColumns + 1) * KWHC_ButtonMargin) / (CGFloat)KWHC_ButtonColumns;
    NSInteger count = titleArr.count;
    NSInteger rowCount = count / KWHC_ButtonColumns + ((count % KWHC_ButtonColumns) != 0 ? 1 : 0);
    for (NSInteger i = 0; i < rowCount; i++) {
        for (NSInteger j = 0; j < KWHC_ButtonColumns; j++) {
            CGRect  itemBtnRC = {KWHC_ButtonMargin * (j + 1) + btnWidth * j, KWHC_ContainerBarHeight * (i + 1) + yConst, btnWidth , KWHC_EditButtonHeight};
            NSInteger  index = i * KWHC_ButtonColumns + j;
            if(index < count){
                WHC_ContainerBarItem  * itemBtn = [[WHC_ContainerBarItem alloc]initWithFrame:itemBtnRC Style:style];
                itemBtn.delegate = self;
                itemBtn.title = titleArr[index];
                itemBtn.normalTitleColor = [UIColor blackColor];
                itemBtn.normalFontSize = _containerBarParam.fontSize;
                itemBtn.index = index;
                itemBtn.tag = index + 1;
                [view addSubview:itemBtn];
                [barItemArr addObject:itemBtn];
                [pointArr addObject:@[@(itemBtn.center.x),@(itemBtn.center.y)]];
            }
        }
    }
    return [[pointArr lastObject][1] floatValue] + KWHC_EditButtonHeight;
}

+ (void)saveContainerBarTitlesArr:(NSArray *)titlesArr laterTitlesArr:(NSArray *)laterTitlesArr{
    [WHC_ContainerBar saveContainerBarTitlesArr:titlesArr laterTitlesArr:laterTitlesArr];
}

+ (NSArray *)readContainerBarTitlesArr{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults]objectForKey:KWHC_ContainerConfigurationKey];
    NSArray      * titlesArr = nil;
    if(dict && dict.count > 0){
        titlesArr = dict[KWHC_ContainerTitlesArrKey];
    }
    return titlesArr;
}

+ (NSArray *)readContainerBarLaterTitlesArr{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults]objectForKey:KWHC_ContainerConfigurationKey];
    NSArray      * laterTitlesArr = nil;
    if(dict && dict.count > 0){
        laterTitlesArr = dict[KWHC_ContainerLaterTitlesArrKey];
    }
    return laterTitlesArr;
}

- (void)clickEditViewButton:(UIButton*)sender{
    sender.selected = !sender.selected;
    NSInteger  tag = sender.tag;
    if(tag == KWHC_DropButtonTag){
        if(!(sender.selected)){
            if(_isSelectedEditBtn){
                [self clickEditViewButton:_editButton];
            }
            [WHC_ContainerView saveContainerBarTitlesArr:_containerBarParam.titlesArr laterTitlesArr:_containerBarParam.laterTitlesArr];
        
            [self addContentViewToContainerView];
            [UIView animateWithDuration:KWHC_ShowAnimationDuring delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                _editView.height = 0.0;
                _dropImageView.transform = CGAffineTransformMakeRotation(0);
                [_editView removeFromSuperview];
                
            } completion:^(BOOL finished) {
                _editView.frame = self.bounds;
                if(_isClickDrop){
                    [_containerBar updateContainer];
                }else{
                    [_containerBar updateContainerClickIndex:_clickItemBarIndex];
                }
                [_containerBar rotateDropBtnDuring:KWHC_ShowAnimationDuring];
                _isClickDrop = YES;
            }];
        }
    }else if (tag == KWHC_EditButtonTag){
        _isSelectedEditBtn = sender.selected;
        if(_isSelectedEditBtn){
            for (WHC_ContainerBarItem * itemBar in _editView.subviews) {
                if([itemBar isKindOfClass:[WHC_ContainerBarItem class]]){
                    [itemBar startEdit];
                }
            }
        }else{
            for (WHC_ContainerBarItem * itemBar in _editView.subviews) {
                if([itemBar isKindOfClass:[WHC_ContainerBarItem class]]){
                    [itemBar stopEdit];
                }
            }
        }
    }else{
        
    }
}

- (NSInteger)longPressBarItemIndex:(CGPoint)point{
    int index = -1;
    for (WHC_ContainerBarItem * barItem in _editView.subviews) {
        if([barItem isKindOfClass:[WHC_ContainerBarItem class]] &&
           CGRectContainsPoint(barItem.frame, point)){
            index = (int)barItem.index;
            break;
        }
    }
    return index;
}

- (void)saveTitlesArrWithBarItemArr:(NSArray *)barItemArr{
    [_containerBarParam.titlesArr removeAllObjects];
    for (WHC_ContainerBarItem * barItem in barItemArr) {
        [_containerBarParam.titlesArr addObject:barItem.title];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture{

    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:{
            _isTouchEnd = NO;
            _canMoveBarItem = NO;
            CGPoint longPressPoint = [longPressGesture locationInView:longPressGesture.view];
            _moveBarItemIndex = [self longPressBarItemIndex:longPressPoint];
            if(_moveBarItemIndex > -1){
                _canMoveBarItem = YES;
                _moveBarItem = ((WHC_ContainerBarItem*)_barItemArr[_moveBarItemIndex]);
                [_editView bringSubviewToFront:_moveBarItem];
            }
            _addItemView.hidden = YES;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if(_canMoveBarItem){
                CGPoint  currentPoint = [longPressGesture locationInView:longPressGesture.view];
                _moveBarItem.center = currentPoint;
                if(_isAnimationMoving){
                    return;
                }
                NSInteger  currentBarItemIndex = [self longPressBarItemIndex:currentPoint];
                if(currentBarItemIndex > -1){
                    _isAnimationMoving = YES;
                    [UIView animateWithDuration:KWHC_ShowAnimationDuring delay:0.0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                         if(currentBarItemIndex > _moveBarItemIndex){
                             for (NSInteger i = currentBarItemIndex; i > _moveBarItemIndex; i--) {
                                 WHC_ContainerBarItem  * barItem = ((WHC_ContainerBarItem*)_barItemArr[i]);
                                 CGPoint  frontBarItemCenter = CGPointZero;
                                 NSArray * point = _pointArr[i - 1];
                                 frontBarItemCenter = CGPointMake([point[0] floatValue], [point[1] floatValue]);
                                 if(i == _moveBarItemIndex + 1){
                                     NSArray  * startPoint = _pointArr[_moveBarItemIndex];
                                     frontBarItemCenter = CGPointMake([startPoint[0] floatValue], [startPoint[1] floatValue]);
                                 }
                                 barItem.center = frontBarItemCenter;
                             }
                         }else if (currentBarItemIndex < _moveBarItemIndex){
                             for (NSInteger i = currentBarItemIndex; i < _moveBarItemIndex; i++) {
                                 WHC_ContainerBarItem  * barItem = ((WHC_ContainerBarItem*)_barItemArr[i]);
                                 CGPoint  nextBarItemCenter = CGPointZero;
                                 NSArray * point = _pointArr[i + 1];
                                 nextBarItemCenter = CGPointMake([point[0] floatValue], [point[1] floatValue]);
                                 if(i == _moveBarItemIndex - 1){
                                     NSArray  * startPoint = _pointArr[_moveBarItemIndex];
                                     nextBarItemCenter = CGPointMake([startPoint[0] floatValue], [startPoint[1] floatValue]);
                                 }
                                 barItem.center = nextBarItemCenter;
                             }
                        }
                         
                    } completion:^(BOOL finished) {
                
                        [_barItemArr exchangeObjectAtIndex:_moveBarItemIndex withObjectAtIndex:currentBarItemIndex];
                        if(currentBarItemIndex > _moveBarItemIndex){
                            for (NSInteger i = _moveBarItemIndex; i < currentBarItemIndex - 1; i++) {
                                [_barItemArr exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
                            }
                        }else if (currentBarItemIndex < _moveBarItemIndex){
                            for (NSInteger i = _moveBarItemIndex; i > currentBarItemIndex + 1; i--) {
                                [_barItemArr exchangeObjectAtIndex:i withObjectAtIndex:(i - 1 < 0 ? 0 : i - 1)];
                            }
                        }
                        for (NSInteger i = 0; i < _barItemArr.count; i++) {
                            WHC_ContainerBarItem  * barItem = ((WHC_ContainerBarItem*)_barItemArr[i]);
                            barItem.index = i;
                        }
                        NSArray  * currentPoint = _pointArr[currentBarItemIndex];
                        
                        _startPoint = CGPointMake([currentPoint[0] floatValue], [currentPoint[1] floatValue]);
                        if(_isTouchEnd && (_startPoint.x != _moveBarItem.center.x ||
                                           _startPoint.y != _moveBarItem.center.y)){
                            _moveBarItem.center = _startPoint;
                            [self saveTitlesArrWithBarItemArr:_barItemArr];
                        }
                        _moveBarItemIndex = currentBarItemIndex;
                        _isAnimationMoving = NO;
                    }];
                }
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            _moveBarItem.center = _startPoint;
            _addItemView.hidden = NO;
            _isTouchEnd = YES;
            [self saveTitlesArrWithBarItemArr:_barItemArr];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _isClickSwitch = NO;
    _currentPageIndex = floor((scrollView.contentOffset.x - scrollView.width / 2.0) / scrollView.width) + 1;
    CGPoint  ori = [scrollView.panGestureRecognizer velocityInView:scrollView];
    [_containerBar beginDynamicChangeStateOffsetX:scrollView.contentOffset.x pageIndex:_currentPageIndex oriX:ori.x];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!_isClickSwitch){
        CGPoint ori = [scrollView.panGestureRecognizer velocityInView:scrollView];
        [_containerBar dynamicChangeStateOffsetX:scrollView.contentOffset.x oriX:ori.x];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _isClickSwitch = NO;
    if(_isBigSwitch){
        for (NSInteger i = 0; i < _containerBarParam.viewArr.count; i++) {
            UIView  * view = _containerBarParam.viewArr[i];
            [view removeFromSuperview];
        }
        [self addContentViewToContainerView];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(whc_ContainerView:loadContentForCurrentView:currentIndex:)]){
        UIView  * contentView = _containerBarParam.viewArr[_currentPageIndex];
        [_containerView bringSubviewToFront:contentView];
        [_delegate whc_ContainerView:self loadContentForCurrentView:contentView currentIndex:_currentPageIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger currentPageIndex = floor((scrollView.contentOffset.x - scrollView.width / 2.0) / scrollView.width) + 1;
    if(currentPageIndex != _currentPageIndex){
        if(_delegate && [_delegate respondsToSelector:@selector(whc_ContainerView:loadContentForCurrentView:currentIndex:)]){
            UIView  * contentView = _containerBarParam.viewArr[currentPageIndex];
            [_containerView bringSubviewToFront:contentView];
            [_delegate whc_ContainerView:self loadContentForCurrentView:contentView currentIndex:currentPageIndex];
        }
    }
    _currentPageIndex = currentPageIndex;
    [_containerBar endDynamicChangeStateOffsetX:scrollView.contentOffset.x currentPageIndex:currentPageIndex];
}

#pragma mark - WHC_ContainerBarDelegate -
- (void)whc_ContainerBar:(WHC_ContainerBar *)whcContainerBar clickIndex:(NSInteger)index animated:(BOOL)animated{
    _isClickSwitch = YES;
    _isBigSwitch = YES;
    void (^replaceViewPosition)(NSInteger) = ^(NSInteger symbol){
        NSInteger    currentPageIndex = _currentPageIndex + symbol;
        UIView     * currentView = [_containerView viewWithTag:currentPageIndex + 1];
        UIView     * replaceView = [_containerView viewWithTag:index + 1];
        CGFloat      x = currentView.x;
        NSInteger    tag = currentView.tag;
        currentView.x = replaceView.x;
        replaceView.x = x;
        currentView.tag = replaceView.tag;
        replaceView.tag = tag;
        [_containerView setContentOffset:CGPointMake((_currentPageIndex + symbol) * whcContainerBar.width, 0.0) animated:animated];
    };
    
    if(index > _currentPageIndex && index > _currentPageIndex + 1){
        replaceViewPosition(1);
    }else if (index < _currentPageIndex && index < _currentPageIndex - 1){
        replaceViewPosition(-1);
    }else{
        _isBigSwitch = NO;
        [_containerView setContentOffset:CGPointMake(index * whcContainerBar.width, 0.0) animated:animated];
    }
    _currentPageIndex = index;
}

- (void)whc_ContainerBar:(WHC_ContainerBar *)whcContainerBar clickDrop:(UIButton*)sender{
    
    [self clearMemoryArr:_addBarItemArr];
    [self clearMemoryArr:_addPointArr];
    [self clearMemoryArr:_barItemArr];
    [self clearMemoryArr:_pointArr];
    [_addBarItemArr removeAllObjects];
    [_addPointArr removeAllObjects];
    [_barItemArr removeAllObjects];
    [_pointArr removeAllObjects];
    
    [self layoutBarItemToView:_editView titleArr:_containerBarParam.titlesArr barItemArr:_barItemArr pointArr:_pointArr yConst:(KWHC_ContainerBarHeight - KWHC_EditButtonHeight) / 2.0 style:EDIT_SHOW];
    CGFloat sumHeight = [self layoutBarItemToView:_addScrollView titleArr:_containerBarParam.laterTitlesArr barItemArr:_addBarItemArr pointArr:_addPointArr yConst:-KWHC_EditButtonHeight style:ADD_SHOW];
    if(sumHeight > _addScrollView.contentSize.height){
        _addScrollView.contentSize = CGSizeMake(_addScrollView.width, sumHeight);
    }
    _dropBtn.selected = sender.selected;
    [self addSubview:_editView];
    [_editView sendSubviewToBack:_addItemView];
    _editView.height = 0.0;
    __weak typeof(self) sf = self;
    [UIView animateWithDuration:KWHC_ShowAnimationDuring delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _editView.height = sf.height;
        _dropImageView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - WHC_ContainerBarItemDelegate -
- (void)whcContainerBarItem:(WHC_ContainerBarItem*)barItem clickIndex:(NSInteger)index animated:(BOOL)animated{
    if(_isAddAnimation){
        return;
    }
    if([_barItemArr containsObject:barItem]){
        _isClickDrop = NO;
        _clickItemBarIndex = index;
        [self addContentViewToContainerView];
        [self clickEditViewButton:_dropBtn];
    }else{
        _isAddAnimation = YES;
        [barItem removeFromSuperview];
        barItem.center = CGPointMake(barItem.center.x, barItem.center.y + _addItemView.y + KWHC_ContainerBarHeight + (KWHC_ContainerBarHeight - KWHC_EditButtonHeight) - _addScrollView.contentOffset.y);
        [_editView addSubview:barItem];
        BOOL       isAddRow = NO;
        BOOL       isDecRow = ((_addBarItemArr.count % KWHC_ButtonColumns) == 1 ? YES : NO);
        NSInteger  count = _barItemArr.count;
        _editRowCount = [self calcRowCount];
        CGPoint  centerPoint = CGPointZero;
        if(count < _editRowCount * KWHC_ButtonColumns){
            NSArray  * lastPoint = [_pointArr lastObject];
            centerPoint = CGPointMake([lastPoint[0] floatValue] + barItem.width + KWHC_ButtonMargin , [lastPoint[1] floatValue]);
        }else{
            isAddRow = YES;
            if(count > 0){
                NSArray  * lastPoint = _pointArr[count - KWHC_ButtonColumns];
                centerPoint = CGPointMake([lastPoint[0] floatValue] , [lastPoint[1] floatValue]  + barItem.height + KWHC_ButtonMargin / 2.0);
            }else{
                centerPoint = CGPointMake(KWHC_ButtonMargin + barItem.width / 2.0, KWHC_ContainerBarHeight + KWHC_ButtonMargin / 4.0 + barItem.height / 2.0);
            }
        }
        [UIView animateWithDuration:KWHC_ShowAnimationDuring animations:^{
            
            barItem.center = centerPoint;
            
        }completion:^(BOOL finished) {
            [barItem setItemStyle:EDIT_SHOW];
            if(_isSelectedEditBtn){
                [barItem startEdit];
            }
            barItem.index = _barItemArr.count;
            [_barItemArr addObject:barItem];
            [_pointArr addObject:@[@(barItem.center.x),@(barItem.center.y)]];
            CGFloat  incrementHeight = barItem.height + KWHC_ButtonMargin / 2.0;
            
            [UIView animateWithDuration:KWHC_ShowAnimationDuring animations:^{
                if(isAddRow){
                    _addItemView.center = CGPointMake(_addItemView.center.x, _addItemView.center.y + incrementHeight);
                    _addItemView.height -= incrementHeight;
                    _addScrollView.height -= incrementHeight;
                }
                for(NSInteger i = index; i < _addBarItemArr.count - 1; i++){
                    WHC_ContainerBarItem  * barItem = _addBarItemArr[i + 1];
                    NSArray    *   pointArr = _addPointArr[i];
                    if(isAddRow){
                        barItem.center = CGPointMake([pointArr[0] floatValue], [pointArr[1] floatValue]);
                    }else{
                        barItem.center = CGPointMake([pointArr[0] floatValue], [pointArr[1] floatValue]);
                    }
                }
                if(isAddRow){
                    for (NSInteger i = 0; i < index; i++) {
                        WHC_ContainerBarItem  * barItem = _addBarItemArr[i];
                        NSArray    *   pointArr = _addPointArr[i];
                        barItem.center = CGPointMake([pointArr[0] floatValue], [pointArr[1] floatValue]);
                    }
                }
            }completion:^(BOOL finished) {
                if(isDecRow){
                    _addScrollView.contentSize = CGSizeMake(_addScrollView.width, _addScrollView.contentSize.height - incrementHeight);
                }
                [_containerBarParam.titlesArr addObject:[NSString stringWithString:barItem.title]];
                [_containerBarParam.laterTitlesArr removeObjectAtIndex:index];
                [_addBarItemArr removeObjectAtIndex:index];
                [_addPointArr removeAllObjects];
                for (NSInteger i = 0; i < _addBarItemArr.count; i++) {
                    WHC_ContainerBarItem  * barItem = _addBarItemArr[i];
                    barItem.index = i;
                    [_addPointArr addObject:@[@(barItem.center.x),@(barItem.center.y)]];
                }
                _isAddAnimation = NO;
            }];
        }];
    }
}

- (void)whcContainerBarItem:(WHC_ContainerBarItem *)barItem clickDeleteBtn:(UIButton*)sender index:(NSInteger)index{
    if(_containerBarParam.mustSaveItemCount >= _barItemArr.count){
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:KWHC_ShowAlertMsg message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if(_isDeleteAnimation){
        return;
    }
    _isDeleteAnimation = YES;
    [_editView bringSubviewToFront:barItem];
    BOOL       isDecRow = ((_barItemArr.count % KWHC_ButtonColumns != 1) ? NO : YES);
    BOOL       isAddRow = ((_addBarItemArr.count % KWHC_ButtonColumns == 0) ? YES : NO);
    CGPoint    barItemCenter = CGPointMake(KWHC_ButtonMargin + barItem.width / 2.0, _addItemView.y + KWHC_ContainerBarHeight + KWHC_ContainerBarHeight - KWHC_EditButtonHeight  + KWHC_EditButtonHeight / 2.0);
    NSInteger  count = _addBarItemArr.count;
    NSInteger  remainder = count % KWHC_ButtonColumns;
    NSArray  * lastPoint = [_addPointArr lastObject];
    if(remainder != 0){
        [_addPointArr addObject:@[@([lastPoint[0] floatValue] + barItem.width + (KWHC_ContainerBarHeight - KWHC_EditButtonHeight) * 2.0), lastPoint[1]]];
    }else{
        [_addPointArr addObject:@[@(KWHC_ButtonMargin + barItem.width / 2.0), @([lastPoint[1] floatValue] + barItem.height + KWHC_ButtonMargin / 2.0)]];
    }
    CGFloat  incrementHeight = barItem.height + KWHC_ButtonMargin / 2.0;
    [UIView animateWithDuration:KWHC_ShowAnimationDuring animations:^{
        if(isDecRow){
            _addItemView.center = CGPointMake(_addItemView.center.x, _addItemView.center.y - incrementHeight);
            _addItemView.height += incrementHeight;
            _addScrollView.height += incrementHeight;
        }
        barItem.center = barItemCenter;
        for (NSInteger i = count - 1; i >= 0; i--) {
            WHC_ContainerBarItem  * tempBarItem = _addBarItemArr[i];
            NSArray  * tempBarItemPoint = _addPointArr[i + 1];
            tempBarItem.center = CGPointMake([tempBarItemPoint[0] floatValue], [tempBarItemPoint[1] floatValue]);
        }
        for (NSInteger i = index + 1; i < _barItemArr.count; i++) {
            WHC_ContainerBarItem  * tempBarItem = _barItemArr[i];
            NSArray  * tempBarItemPoint = _pointArr[i - 1];
            tempBarItem.center = CGPointMake([tempBarItemPoint[0] floatValue], [tempBarItemPoint[1] floatValue]);
        }
    }completion:^(BOOL finished) {
        if(isAddRow){
            _addScrollView.contentSize = CGSizeMake(_addScrollView.width, _addScrollView.contentSize.height + incrementHeight);
        }
        [barItem stopEdit];
        [barItem setItemStyle:ADD_SHOW];
        [barItem removeFromSuperview];
        [_pointArr removeAllObjects];
        [_barItemArr removeObjectAtIndex:index];
        [_containerBarParam.titlesArr removeObjectAtIndex:index];
        [_containerBarParam.laterTitlesArr insertObject:barItem.title atIndex:0];
        for (NSInteger i = 0; i < _barItemArr.count; i++) {
            WHC_ContainerBarItem  * tempBarItem = _barItemArr[i];
            tempBarItem.index = i;
            [_pointArr addObject:@[@(tempBarItem.center.x),@(tempBarItem.center.y)]];
        }
        barItem.center = CGPointMake(barItem.center.x, KWHC_ContainerBarHeight - KWHC_EditButtonHeight  + KWHC_EditButtonHeight / 2.0);
        [_addScrollView addSubview:barItem];
        [_addBarItemArr insertObject:barItem atIndex:0];
        for (NSInteger i = 0; i < _addBarItemArr.count; i++) {
            WHC_ContainerBarItem  * tempBarItem = _addBarItemArr[i];
            tempBarItem.index = i;
        }
        _isDeleteAnimation = NO;
    }];
}


@end
