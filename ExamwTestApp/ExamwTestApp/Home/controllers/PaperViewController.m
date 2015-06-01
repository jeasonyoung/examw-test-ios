//
//  PaperViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperViewController.h"

#import "PaperModel.h"
#import "PaperStructureModel.h"
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

#define __kPaperViewController_tag_btnPrev 0x01//上一题
#define __kPaperViewController_tag_btnNext 0x02//下一题
#define __kPaperViewController_tag_btnFavorite 0x03//收藏
#define __kPaperViewController_tag_btnSubmit 0x04//交卷

//试卷控制器成员变量
@interface PaperViewController ()<DMLazyScrollViewDelegate,PaperExitAlertViewDelegate,PaperSubmitAlertViewDelegate,PaperItemViewControllerDelegate>{
    NSString *_paperId,*_paperRecordId,*_itemIndex;
    PaperModel *_paperModel;
    //
    NSUInteger _itemOrder;
    //
    BOOL _displayAnswer,_isLoaded;
    UIImage *_imgFavoriteNormal,*_imgFavoriteHighlight;
    //
    DMLazyScrollView *_lazyScrollView;
    NSMutableArray *_itemsArrays;
    NSMutableDictionary *_controllers;
    //
    PaperExitAlertView *_exitAlert;
    PaperSubmitAlertView *_submitAlert;
    MBProgressHUD *_waitHud;
}
@end
//试卷控制器实现
@implementation PaperViewController

#pragma makr 初始化
-(instancetype)initWithPaperId:(NSString *)paperId andPaperRecordId:(NSString *)recordId andDisplayAnswer:(BOOL)display{
    if(self = [super init]){
        NSLog(@"初始化试卷控制器[paperId=%@,paperRecordId=%@,displayAnswer=%d]...", paperId, recordId, display);
        _paperId = paperId;
        _paperRecordId = recordId;
        _displayAnswer = display;
        
        _itemOrder = 0;
        
        //初始化收藏图片
        _imgFavoriteNormal = [UIImage imageNamed:@"btnFavoriteNormal.png"];
        _imgFavoriteHighlight = [UIImage imageNamed:@"btnFavoriteHighlight.png"];
    }
    return self;
}

#pragma mark 初始化
-(instancetype)initWithPaperId:(NSString *)paperId andPaperRecordId:(NSString *)recordId{
    return [self initWithPaperId:paperId andPaperRecordId:recordId andDisplayAnswer:NO];
}

//试卷服务
-(PaperService *)paperService{
    static PaperService *_paperService;
    if(!_paperService){
        //初始化试卷服务
        NSLog(@"初始化试卷服务...");
        _paperService = [[PaperService alloc] init];
    }
    return _paperService;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置未未加载
    _isLoaded = NO;
    //加载试题滚动视图
    [self setupLazyScrollViews];
    //加载顶部工具栏
    [self setupTopBars];
    //加载底部工具栏
    [self setupBottomBars];
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
    _waitHud = [MBProgressHUD showHUDAddedTo:_lazyScrollView animated:YES];
    _waitHud.color = [UIColor colorWithHex:0xD3D3D3];
    //异步线程处理交卷数据处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"开始异步线程处理交卷数据处理...");
        [[self paperService] submitWithPaperRecordId:_paperRecordId];
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //关闭等待动画
            if(_waitHud){
                [_waitHud hide:YES];
            }
            //控制器跳转
            PaperResultViewController *resultController = [[PaperResultViewController alloc] initWithPaperId:_paperId andPaperRecordId:_paperRecordId];
            [self.navigationController pushViewController:resultController animated:YES];
        });
    });
}

//右边按钮点击事件
-(void)btnBarRightClick:(UIBarButtonItem *)sender{
    NSLog(@"右边按钮点击:%@...",sender);
    AnswerCardViewController *answerCardController = [[AnswerCardViewController alloc] initWithPaperId:_paperId
                                                                                      andPaperRecordId:_paperRecordId andDisplayAnswer:_displayAnswer];
    answerCardController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:answerCardController animated:YES];
}

//加载底部工具栏
-(void)setupBottomBars{
    //上一题
    UIBarButtonItem *btnPrev = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btnPrev.png"]
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(btnBarPrevClick:)];
    btnPrev.tag = __kPaperViewController_tag_btnPrev;
    btnPrev.enabled = NO;
    //下一题
    UIBarButtonItem *btnNext = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btnNext.png"]
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(btnBarNextClick:)];
    btnNext.tag = __kPaperViewController_tag_btnNext;
    //收藏
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:_imgFavoriteNormal forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnBarFavoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnFavorite = [[UIBarButtonItem alloc] initWithCustomView:btn];
    btnFavorite.tag = __kPaperViewController_tag_btnFavorite;
    
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
    if(_lazyScrollView){
        UINavigationController *navController = (UINavigationController *)[_lazyScrollView visibleViewController];
        if(!navController){
            NSLog(@"获取当前控制器失败!");
            return;
        }
        PaperItemViewController *itemController = (PaperItemViewController *)navController.visibleViewController;
        if(!itemController){
            NSLog(@"获取当前试题视图控制器失败!");
            return;
        }
        [itemController favoriteItem:^(BOOL result) {
            NSLog(@"收藏结果:%d", result);
            dispatch_async(dispatch_get_main_queue(), ^{
                //sender.image = (result ? _imgFavoriteHighlight : _imgFavoriteNormal);
                [sender setImage:(result ? _imgFavoriteHighlight : _imgFavoriteNormal) forState:UIControlStateNormal];
                //NSLog(@"1.current-image:%@,h:%@,n:%@",sender.image, _imgFavoriteHighlight, _imgFavoriteNormal);
            });
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
        _paperModel = [[self paperService] loadPaperModelWithPaperId:_paperId];
        if(_paperModel && _paperModel.total > 0 && _paperModel.structures){
            //初始化试题
            _itemsArrays = [NSMutableArray arrayWithCapacity:_paperModel.total];
            //填充数据
            for(PaperStructureModel *structure in _paperModel.structures){
                if(!structure || !structure.items) continue;
                for(PaperItemModel *item in structure.items){
                    if(!item || !item.itemId || item.itemId.length == 0) continue;
                    //所属试卷结构ID
                    item.structureId = structure.code;
                    //所属试卷结构名称
                    item.structureTitle = structure.title;
                    //每题得分
                    item.structureScore = structure.score;
                    //最小得分
                    item.structureMin = structure.min;
                    //循环试题
                    for(NSUInteger index = 0; index < item.count; index++){
                        //试题索引
                        item.index = index;
                        if(_itemIndex && _itemIndex.length > 0){
                            //试题索引
                            NSString *itemOrderIndex = [NSString stringWithFormat:@"%@$%d", item.itemId, (int)index];
                            if([_itemIndex isEqualToString:itemOrderIndex]){
                                _itemOrder = _itemsArrays.count;
                            }
                        }
                        //添加试题数据
                        [_itemsArrays addObject:item];
                    }
                }
            }
        }
        //UpdateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //初始化滚动视图
            _lazyScrollView = [[DMLazyScrollView alloc] initWithFrame:self.view.bounds];
            _lazyScrollView.controlDelegate = self;
            _lazyScrollView.backgroundColor = [UIColor blueColor];
            [self.view addSubview:_lazyScrollView];
            [_lazyScrollView setEnableCircularScroll:NO];
            [_lazyScrollView setAutoPlay:NO];
            //设置加载试题数据
            __weak __typeof(&*self)weakSelf = self;
            _lazyScrollView.dataSource = ^(NSUInteger index){
                NSLog(@"加载[%d]试题...", (int)index);
                return [weakSelf loadItemsControllersWithIndex:index];
            };
            //设置加载完成
            _isLoaded = YES;
            //设置试题总数
            _lazyScrollView.numberOfPages = _itemsArrays.count;
            //设置到指定的题序
            if(_itemOrder > 0){
                [_lazyScrollView setPage:_itemOrder animated:NO];
            }
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

#pragma mark 根据做题记录继续
-(void)loadRecordContinue{
    if(!_paperRecordId || _paperRecordId.length == 0)return;
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"根据做题记录继续...");
        _itemIndex = [[self paperService] loadNewsItemIndexWithPaperRecordId:_paperRecordId];
    });
}

//加载试题数据
-(UIViewController *)loadItemsControllersWithIndex:(NSUInteger)index{
    if(_itemsArrays && index < _itemsArrays.count){
        NSLog(@"加载试题控制器[%d]...", (int)index);
        //控制器
        UIViewController *controller = nil;
        if(!_controllers){
            //初始化Controllers缓存
            _controllers = [NSMutableDictionary dictionary];
        }else{
            controller = [_controllers objectForKey:[NSNumber numberWithInteger:index]];
        }
        if(!controller){
            NSLog(@"创建试题控制器[%d]...", (int)index);
            PaperItemModel *itemModel = [_itemsArrays objectAtIndex:index];
            if(!itemModel)return nil;
            PaperItemViewController *itemController = [[PaperItemViewController alloc] initWithPaperItem:itemModel
                                                                                                andOrder:index
                                                                                        andDisplayAnswer:_displayAnswer];
            itemController.PaperRecordId = _paperRecordId;
            itemController.delegate = self;
            controller = [[UINavigationController alloc]initWithRootViewController:itemController];
            //添加到缓存
            [_controllers setObject:controller forKey:[NSNumber numberWithInteger:index]];
        }
        return controller;
    }
    return nil;
}

#pragma mark DMLazyScrollViewDelegate
-(void)lazyScrollView:(DMLazyScrollView *)pagingView currentPageChanged:(NSInteger)currentPageIndex{
    //异步线程更新标题
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程更新试题[%d]标题...", (int)currentPageIndex);
        if(currentPageIndex >= 0 && currentPageIndex < _itemsArrays.count){
            //获取当前试题数据
            PaperItemModel *itemModel = [_itemsArrays objectAtIndex:currentPageIndex];
            if(!itemModel || !itemModel.structureTitle || itemModel.structureTitle.length == 0)return;
            //获取当前视图控制器
            PaperItemViewController *itemController = (PaperItemViewController *)((UINavigationController *)pagingView.visibleViewController).visibleViewController;
            if(itemController){
                [itemController start];
            }
            //查询是否收藏
            BOOL isFavorite = [[self paperService] exitFavoriteWithItemId:itemModel.itemId];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = itemModel.structureTitle;
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
                                //NSLog(@"0.current-image:%@,h:%@,n:%@",bar.image, _imgFavoriteHighlight, _imgFavoriteNormal);
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
    [self btnBarNextClick:nil];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_controllers && _controllers.count > 0){
        [_controllers removeAllObjects];
    }
}
@end
