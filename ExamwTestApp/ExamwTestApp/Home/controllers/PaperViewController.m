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
#import "MBProgressHUD.h"
#import "UIColor+Hex.h"

#import "PaperItemViewController.h"
//试卷控制器成员变量
@interface PaperViewController ()<DMLazyScrollViewDelegate>{
    NSString *_paperId,*_paperRecordId;
    PaperService *_service;
    PaperModel *_paperModel;
    
    BOOL _displayAnswer;
    
    DMLazyScrollView *_lazyScrollView;
    MBProgressHUD *_waitHud;
    NSMutableArray *_itemsArrays, *_structuresArrays;
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
    }
    return self;
}

#pragma mark 初始化
-(instancetype)initWithPaperId:(NSString *)paperId andPaperRecordId:(NSString *)recordId{
    return [self initWithPaperId:paperId andPaperRecordId:recordId andDisplayAnswer:NO];
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化等待
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:0xD3D3D3];
    
    //初始化试卷服务
    _service = [[PaperService alloc] init];
    //加载顶部工具栏
    [self setupTopBars];
    //加载底部工具栏
    [self setupBottomBars];
    //加载试题滚动视图
    [self setupLazyScrollViews];
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
}
//右边按钮点击事件
-(void)btnBarRightClick:(UIBarButtonItem *)sender{
    NSLog(@"右边按钮点击:%@...",sender);
}

//加载底部工具栏
-(void)setupBottomBars{
    //上一题
    UIBarButtonItem *btnPrev = [[UIBarButtonItem alloc] initWithTitle:@"<上一题" style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(btnBarPrevClick:)];
    //下一题
    UIBarButtonItem *btnNext = [[UIBarButtonItem alloc] initWithTitle:@"下一题>" style:UIBarButtonItemStyleBordered
                                                               target:self action:@selector(btnBarNextClick:)];
    //收藏
    UIBarButtonItem *btnFavorite =[[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(btnBarFavoriteClick:)];
    //分隔平均填充
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil action:nil];
    
    //添加到底部工具栏
    self.navigationController.toolbarHidden = NO;
    [self setToolbarItems:@[btnPrev,space,btnFavorite,space,btnNext] animated:YES];
}

//上一题
-(void)btnBarPrevClick:(UIBarButtonItem *)sender{
    NSLog(@"上一题:%@...",sender);
    if(_lazyScrollView){
        NSUInteger index =  _lazyScrollView.currentPage;
        if(index > 0){
            [_lazyScrollView setPage:(index - 1) animated:YES];
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
-(void)btnBarFavoriteClick:(UIBarButtonItem *)sender{
    NSLog(@"收藏:%@...",sender);
    sender.title = (arc4random() % 2 == 0 ? @"取消收藏" : @"收藏");
}

//加载试题滚动视图
-(void)setupLazyScrollViews{
    //初始化滚动视图
    _lazyScrollView = [[DMLazyScrollView alloc] initWithFrame:self.view.bounds];
    //设置加载试题数据
    __weak __typeof(&*self)weakSelf = self;
    _lazyScrollView.dataSource = ^(NSUInteger index){
        NSLog(@"加载[%d]试题...", (int)index);
        return [weakSelf loadItemsControllersWithIndex:index];
    };
    [self.view addSubview:_lazyScrollView];
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //加载试卷
        _paperModel = [_service loadPaperModelWithPaperId:_paperId];
        NSLog(@"加载试卷数据:%@...",_paperModel);
        if(_paperModel && _paperModel.total > 0 && _paperModel.structures){
            //初始化试题
            _itemsArrays = [NSMutableArray arrayWithCapacity:_paperModel.total];
            //初始化试卷结构名称
            _structuresArrays = [NSMutableArray arrayWithCapacity:_paperModel.total];
            //填充数据
            for(PaperStructureModel *structure in _paperModel.structures){
                if(!structure || !structure.items) continue;
                for(PaperItemModel *item in structure.items){
                    if(!item || !item.itemId || item.itemId.length == 0) continue;
                    //添加试题数据
                    [_itemsArrays addObject:item];
                    //添加试卷结构名称
                    [_structuresArrays addObject:structure.title];
                }
            }
            //设置试题总数
            _lazyScrollView.numberOfPages = _itemsArrays.count;
        }
        //UpdateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置标题
            [self loadStructuresTitleWithIndex:0];
            //加载数据源
            if(_lazyScrollView){
                [_lazyScrollView reloadData];
            }
            //关闭等待动画
            [_waitHud hide:YES];
        });
    });
}
//加载试卷结构标题
-(void)loadStructuresTitleWithIndex:(NSUInteger)index{
    //异步加载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_structuresArrays && index < _structuresArrays.count){
            NSString *title = [_structuresArrays objectAtIndex:index];
            if(title && title.length > 0){
                NSLog(@"试题[%d]所属结构[%@]...", (int)index, title);
                //UpdateUI
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.title = title;
                });
            }
        }
    });
}
//加载试题数据
-(UIViewController *)loadItemsControllersWithIndex:(NSUInteger)index{
    if(_itemsArrays && index < _itemsArrays.count){
        //设置试卷结构标题
        [self loadStructuresTitleWithIndex:index];
        //初始化试题视图控制器
        return [[PaperItemViewController alloc] initWithPaperItem:[_itemsArrays objectAtIndex:index]
                                                 andDisplayAnswer:_displayAnswer];
    }
    return nil;
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
