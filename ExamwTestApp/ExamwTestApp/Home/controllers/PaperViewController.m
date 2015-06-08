//
//  PaperViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperViewController.h"

#import "AppConstants.h"

#import "PaperItemModel.h"

#import "PaperService.h"

#import "DMLazyScrollView.h"

#import "PaperExitAlertView.h"
#import "PaperSubmitAlertView.h"

#import "PaperItemViewController.h"
#import "AnswerCardViewController.h"
#import "PaperResultViewController.h"

#import "MBProgressHUD.h"
#import "UIColor+Hex.h"

#import "UIViewController+VisibleView.h"

#define __kPaperViewController_tag_btnPrev 0x01//上一题
#define __kPaperViewController_tag_btnNext 0x02//下一题
#define __kPaperViewController_tag_btnFavorite 0x03//收藏
#define __kPaperViewController_tag_btnSubmit 0x04//交卷

//试卷控制器成员变量
@interface PaperViewController ()<DMLazyScrollViewDelegate,PaperExitAlertViewDelegate,PaperSubmitAlertViewDelegate,PaperItemViewControllerDelegate,AnswerCardViewControllerDataSource>{
    //
    PaperService *_paperService;
    //
    NSUInteger _itemOrder;
    BOOL _isLoaded;
    //
    NSArray *_itemsArrays;
    //
    UIImage *_imgFavoriteNormal,*_imgFavoriteHighlight;
    //
    DMLazyScrollView *_lazyScrollView;
    //
    NSMutableArray *_viewControllerArrays;
    //
    PaperExitAlertView *_exitAlert;
    PaperSubmitAlertView *_submitAlert;
    MBProgressHUD *_waitHud;
}
@end
//试卷控制器实现
@implementation PaperViewController

#pragma mark 初始化
-(instancetype)initWithDisplayAnswer:(BOOL)display{
    if(self = [super init]){
        _displayAnswer = display;
        _itemOrder = 0;
        //初始化收藏图片
        _imgFavoriteNormal = [UIImage imageNamed:@"btnFavoriteNormal.png"];
        _imgFavoriteHighlight = [UIImage imageNamed:@"btnFavoriteHighlight.png"];
    }
    return self;
}

#pragma mark 重载初始化
-(instancetype)init{
    return [self initWithDisplayAnswer:NO];
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //添加背景色
    self.view.backgroundColor = [UIColor whiteColor];
    //设置未未加载
    _isLoaded = NO;
    //加载试题滚动视图
    [self setupLazyScrollViews];
    //加载顶部工具栏
    [self setupTopBars];
    
    //加载底部工具栏
    [self setupBottomBars];
}

#pragma mark 设置是否显示答案
-(void)setDisplayAnswer:(BOOL)displayAnswer{
    if(_displayAnswer != displayAnswer){
        _displayAnswer = displayAnswer;
        //重置底部按钮
        [self setupBottomBars];
    }
}

//加载顶部工具栏
-(void)setupTopBars{
    //左边按钮
    UIBarButtonItem *btnBarLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(btnBarLeftClick:)];
    self.navigationItem.leftBarButtonItem = btnBarLeft;
    //右边按钮
    UIBarButtonItem *btnBarRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(btnBarRightClick:)];
    self.navigationItem.rightBarButtonItem = btnBarRight;
}

//左边按钮点击事件
-(void)btnBarLeftClick:(UIBarButtonItem *)sender{
    NSLog(@"左边按钮点击:%@...",sender);
    if(!_displayAnswer){
        _exitAlert = [[PaperExitAlertView alloc] init];
        _exitAlert.delegate = self;
        [_exitAlert showAlert];
    }else{
        //返回上级控制器
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark PaperExitAlertViewDelegate
//交卷
-(void)submitAlertView:(PaperExitAlertView *)alertView{
    NSLog(@"提交试卷...");
    _submitAlert = [[PaperSubmitAlertView alloc] init];
    _submitAlert.delegate = self;
    [_submitAlert showAlert];
}

//下次再做
-(void)nextAlertView:(PaperExitAlertView *)alertView{
    NSLog(@"下次再做...");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark PaperSubmitAlertViewDelegate
//提交试卷处理
-(void)submitPaperHandler{
    if(_delegate && [_delegate respondsToSelector:@selector(submitPaper:)]){
        _waitHud = [MBProgressHUD showHUDAddedTo:_lazyScrollView animated:YES];
        _waitHud.color = [UIColor colorWithHex:WAIT_HUD_COLOR];
        //异步线程处理交卷数据处理
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"开始异步线程处理交卷数据处理...");
            [_delegate submitPaper:^(NSString *paperRecordId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //关闭等待动画
                    if(_waitHud){
                        [_waitHud hide:YES];
                    }
                    //控制器跳转
                    if(paperRecordId && paperRecordId.length > 0){
                        PaperResultViewController *resultController = [[PaperResultViewController alloc] initWithPaperRecordId:paperRecordId];
                        resultController.paperViewControllerDelegate = _delegate;
                        [self.navigationController pushViewController:resultController animated:YES];
                    }
                });
            }];
        });
    }
}

//右边按钮点击事件
-(void)btnBarRightClick:(UIBarButtonItem *)sender{
    NSLog(@"右边按钮点击:%@...",sender);
    AnswerCardViewController *targetController = nil;
    NSArray *arrays = self.navigationController.viewControllers;
    if(arrays && arrays.count > 0){
        for(UIViewController *vc in arrays){
            if(vc && [vc isKindOfClass:[AnswerCardViewController class]]){
                targetController = (AnswerCardViewController *)vc;
                targetController.displayAnswer = _displayAnswer;
                break;
            }
        }
    }
    if(!targetController){
        targetController = [[AnswerCardViewController alloc] initWithDisplayAnswer:_displayAnswer];
    }
    
    targetController.answerCardDataSource = self;
    targetController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:targetController animated:YES];
}

//加载底部工具栏
-(void)setupBottomBars{
    //
    UIColor *barColor = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
    
    //上一题
    UIBarButtonItem *btnPrev = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btnPrev.png"]
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(btnBarPrevClick:)];
    btnPrev.tag = __kPaperViewController_tag_btnPrev;
    btnPrev.enabled = NO;
    btnPrev.tintColor = barColor;
    //下一题
    UIBarButtonItem *btnNext = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btnNext.png"]
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(btnBarNextClick:)];
    btnNext.tag = __kPaperViewController_tag_btnNext;
    btnNext.tintColor = barColor;
    //收藏
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:_imgFavoriteNormal forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnBarFavoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnFavorite = [[UIBarButtonItem alloc] initWithCustomView:btn];
    btnFavorite.tag = __kPaperViewController_tag_btnFavorite;
    btnFavorite.tintColor = barColor;
    
    //分隔平均填充
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil action:nil];
    //工具栏按钮
    NSArray *toolbars;
    if(_displayAnswer){//显示答案
        toolbars = @[btnPrev,space,btnFavorite,space,btnNext];
    }else{//不显示答案
        //交卷
        UIBarButtonItem *btnSubmit = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btnSubmit.png"]
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(btnBarSubmitClick:)];
        btnSubmit.tag = __kPaperViewController_tag_btnSubmit;
        btnSubmit.tintColor = barColor;
        toolbars = @[btnPrev,space,btnFavorite,space,btnSubmit,space,btnNext];
    }
    
    //添加到底部工具栏
    self.navigationController.toolbarHidden = NO;
    [self setToolbarItems:toolbars animated:YES];
}

//上一题
-(void)btnBarPrevClick:(UIBarButtonItem *)sender{
    NSLog(@"上一题:%@...",sender);
    if(_lazyScrollView){
        NSUInteger index =  _lazyScrollView.currentPage;
        if(index > 0){
            [_lazyScrollView setPage:(index - 1) transition:DMLazyScrollViewTransitionBackward animated:YES];
        }
    }
}
//下一题
-(void)btnBarNextClick:(UIBarButtonItem *)sender{
    NSLog(@"下一题:%@...",sender);
    if(_lazyScrollView && _itemsArrays){
        NSUInteger index =  _lazyScrollView.currentPage;
        if(index < _itemsArrays.count - 1){
            [_lazyScrollView setPage:(index + 1) animated:YES];
        }
    }
}
//收藏
-(void)btnBarFavoriteClick:(UIButton *)sender{
    NSLog(@"收藏:%@...",sender);
    if(_lazyScrollView && _viewControllerArrays){
        PaperItemViewController *itemController = (PaperItemViewController *)[_viewControllerArrays objectAtIndex:_lazyScrollView.currentPage];
        if(!itemController){
            NSLog(@"获取当前试题视图控制器失败!");
            return;
        }
        [itemController favoriteItem:^(BOOL result) {
            NSLog(@"收藏结果:%d", result);
            [sender setImage:(result ? _imgFavoriteHighlight : _imgFavoriteNormal) forState:UIControlStateNormal];
        }];
    }
}
//交卷
-(void)btnBarSubmitClick:(UIBarButtonItem *)sender{
    NSLog(@"交卷:%@", sender);
    _submitAlert = [[PaperSubmitAlertView alloc] init];
    _submitAlert.delegate = self;
    [_submitAlert showAlert];
}
//加载试题滚动视图
-(void)setupLazyScrollViews{
    NSLog(@"试卷试题UpdateUI....");
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程加载试卷数据...");
        //初始化服务
        _paperService = [[PaperService alloc] init];
        //加载数据
        if(_delegate && [_delegate respondsToSelector:@selector(dataSourceOfPaperViewController:)]){
            _itemsArrays = [_delegate dataSourceOfPaperViewController:self];
        }
        //初始化控制器缓存
        NSUInteger numberOfPages = _itemsArrays.count;
        _viewControllerArrays = [NSMutableArray arrayWithCapacity:numberOfPages];
        for(NSUInteger i = 0; i < numberOfPages; i++){
            [_viewControllerArrays addObject:[NSNull null]];
        }
        //当前题号
        if(_delegate && [_delegate respondsToSelector:@selector(currentOrderOfPaperViewController:)]){
            _itemOrder = [_delegate currentOrderOfPaperViewController:self];
            if(_itemOrder > 0 && _itemsArrays && _itemOrder >= _itemsArrays.count){
                _itemOrder = _itemsArrays.count - 1;
            }
        }
        //UpdateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect rect = [self loadVisibleViewFrame];
            UIView *panelView = [[UIView alloc] initWithFrame:rect];
            //初始化滚动视图
            _lazyScrollView = [[DMLazyScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
            _lazyScrollView.controlDelegate = self;
            //_lazyScrollView.backgroundColor = [UIColor blueColor];
            [_lazyScrollView setEnableCircularScroll:NO];
            [_lazyScrollView setAutoPlay:NO];
            //设置加载试题数据
            __weak __typeof(&*self)weakSelf = self;
            _lazyScrollView.dataSource = ^(NSUInteger index){
                NSLog(@"加载[%d]试题...", (int)index);
                return [weakSelf loadItemsControllersWithIndex:index];
            };
            //设置试题总数
            _lazyScrollView.numberOfPages = numberOfPages;
            //设置加载完成
            _isLoaded = YES;
            //设置到指定的题序
            if(_itemOrder > 0){
                [_lazyScrollView setPage:_itemOrder animated:YES];
            }
            //添加到容器
            [panelView addSubview:_lazyScrollView];
            [self.view addSubview:panelView];
        });
    });
}

#pragma mark 加载到指定题序的试题
-(void)loadItemOrder:(NSUInteger)order{
    _itemOrder = order;
    NSLog(@"加载到指定的试题[%d]", (int)_itemOrder);
    if(_isLoaded && _lazyScrollView && _itemsArrays && _itemsArrays.count > _itemOrder){
        NSUInteger current = _lazyScrollView.currentPage;
        if(current > _itemOrder){
            [_lazyScrollView setPage:_itemOrder transition:DMLazyScrollViewTransitionBackward animated:YES];
        }else{
            [_lazyScrollView setPage:_itemOrder animated:YES];
        }
    }
}

//加载试题数据
-(UIViewController *)loadItemsControllersWithIndex:(NSInteger)index{
    if(index > _viewControllerArrays.count || index < 0) return nil;
    id res = [_viewControllerArrays objectAtIndex:index];
    if(res == [NSNull null]){
         NSLog(@"创建试题控制器[%d]...", (int)index);
        PaperItemViewController *itemController = [[PaperItemViewController alloc] initWithPaperItem:[_itemsArrays objectAtIndex:index]
                                                                                            andOrder:index
                                                                                    andDisplayAnswer:_displayAnswer];
        itemController.delegate = self;
        [_viewControllerArrays replaceObjectAtIndex:index withObject:itemController];
        return itemController;
    }
    return res;
}

#pragma mark DMLazyScrollViewDelegate
-(void)lazyScrollView:(DMLazyScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex{
    //异步线程更新标题
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程更新试题[%d]标题...", (int)currentPageIndex);
        if(currentPageIndex >= 0 && currentPageIndex < _viewControllerArrays.count){
            //获取当前视图控制器
            id res = [_viewControllerArrays objectAtIndex:currentPageIndex];
            if(res == [NSNull null])return;
            //获取视图控制器
            PaperItemViewController *ivc = (PaperItemViewController *)res;
            if(!ivc) return;
            //重新设置是否显示答案
            ivc.displayAnswer = _displayAnswer;
            //做题记时器开始
            [ivc start];
            //获取当前试题数据
            PaperItemModel *itemModel = [_itemsArrays objectAtIndex:currentPageIndex];
            if(!itemModel)return;
            //查询是否收藏
            BOOL isFavorite = NO;
            if(_paperService){
                isFavorite = [_paperService exitFavoriteWithModel:itemModel];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(itemModel.structureTitle && itemModel.structureTitle.length > 0){
                    self.title = itemModel.structureTitle;
                }
                NSArray *toolbars = self.toolbarItems;
                if(toolbars && toolbars.count > 0){
                    for(UIBarButtonItem *bar in toolbars){
                        if(!bar)continue;
                        switch (bar.tag) {
                            case __kPaperViewController_tag_btnPrev:{//上一题
                                //按钮是否可用
                                bar.enabled = (currentPageIndex > 0);
                                break;
                            }
                            case __kPaperViewController_tag_btnNext:{//下一题
                                //按钮是否可用
                                bar.enabled = (currentPageIndex < _itemsArrays.count - 1);
                                break;
                            }
                            case __kPaperViewController_tag_btnFavorite:{//收藏
                                UIButton *btn = (UIButton *)bar.customView;
                                if(btn){
                                    [btn setImage:(isFavorite ? _imgFavoriteHighlight : _imgFavoriteNormal)
                                         forState:UIControlStateNormal];
                                }
                                break;
                            }
                        }
                    }
                }
                
            });
        }
    });
}

#pragma mark PaperItemViewControllerDelegate
//单选点击
-(void)itemViewController:(PaperItemViewController *)controller singleClickOrder:(NSUInteger)order{
    NSLog(@"下一题...");
    dispatch_time_t offer = dispatch_time(DISPATCH_TIME_NOW, NEXT_ITEM_SEC * NSEC_PER_SEC);
    dispatch_after(offer, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       //等待2秒后下一题
        dispatch_async(dispatch_get_main_queue(), ^{
           [self btnBarNextClick:nil];
        });
    });
}
//加载当前试题答案
-(NSString *)itemViewController:(PaperItemViewController *)controller loadMyAnswerWithModel:(PaperItemModel *)itemModel{
    NSLog(@"加载试题答案...");
    if(_delegate && [_delegate respondsToSelector:@selector(loadMyAnswerWithModel:)]){
        return [_delegate loadMyAnswerWithModel:itemModel];
    }
    return nil;
}
//更新做题记录
-(void)updateRecordAnswerWithModel:(PaperItemModel *)itemModel myAnswers:(NSString *)myAnswers useTimes:(NSUInteger)times{
    NSLog(@"更新做题记录...");
    if(_delegate && [_delegate respondsToSelector:@selector(updateRecordAnswerWithModel:myAnswers:useTimes:)]){
        [_delegate updateRecordAnswerWithModel:itemModel myAnswers:myAnswers useTimes:times];
    }
}
//更新收藏记录
-(BOOL)updateFavoriteWithModel:(PaperItemModel *)itemModel{
    NSLog(@"更新收藏记录...");
    if(_delegate && [_delegate respondsToSelector:@selector(updateFavoriteWithModel:)]){
        return [_delegate updateFavoriteWithModel:itemModel];
    }
    return NO;
}
#pragma mark AnswerCardViewControllerDataSource
//加载答题卡数据源
-(void)loadAnswerCardDataWithSection:(NSArray *__autoreleasing *)sections andAllData:(NSDictionary *__autoreleasing *)dict{
    NSLog(@"加载答题卡数据...");
    if(_delegate && [_delegate respondsToSelector:@selector(loadAnswerCardDataWithSection:andAllData:)]){
        [_delegate loadAnswerCardDataWithSection:sections andAllData:dict];
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
