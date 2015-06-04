//
//  AnswerCardViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardViewController.h"

#import "AnswerCardSectionModel.h"
#import "AnswerCardSectionModelCellFrame.h"

#import "AnswerCardModel.h"
#import "AnswerCardModelCellFrame.h"

#import "AnswerCardCollectionViewCell.h"
#import "AnswerCardSectionCollectionReusableView.h"

#import "UIColor+Hex.h"
#import "MBProgressHUD.h"

#import "PaperViewController.h"

#define __kAnswerCardViewController_title @"答题卡"

#define __kAnswerCardViewController_cellIdentifier @"_cell"//
#define __kAnswerCardViewController_sectionIdentifier @"_cellSection"//
//答题卡试图控制器成员变量
@interface AnswerCardViewController ()<UICollectionViewDelegateFlowLayout,AnswerCardCollectionViewCellDelegate>{
    //分组数据源
    NSMutableArray *_sectionSource;
    //数据源
    NSMutableDictionary *_dataSource;
    //等待动画
    MBProgressHUD *_waitHud;
}

@end

//答题卡试图控制器实现
@implementation AnswerCardViewController

#pragma mark 初始化
-(instancetype)initWithDisplayAnswer:(BOOL)display{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    if(self = [super initWithCollectionViewLayout:flowLayout]){
        _displayAnswer = display;
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
    //开启等待动画
    _waitHud = [MBProgressHUD showHUDAddedTo:self.collectionView animated:YES];
    _waitHud.color = [UIColor colorWithHex:0xD3D3D3];
    //设置标题
    self.title = __kAnswerCardViewController_title;
    //设置背景色
    self.collectionView.backgroundColor = [UIColor colorWithHex:0xFFFAF0];
    
    //注册数据Cell
    [self.collectionView registerClass:[AnswerCardCollectionViewCell class]
            forCellWithReuseIdentifier:__kAnswerCardViewController_cellIdentifier];
    //分组面板
    [self.collectionView registerClass:[AnswerCardSectionCollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:__kAnswerCardViewController_sectionIdentifier];
    //加载数据
    [self loadData];
}

#pragma mark 重载View呈现
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}
#pragma mark重载View不可见
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.toolbarHidden = NO;
    [super viewWillDisappear:animated];
}

//加载异步数据
-(void)loadData{
    //异步加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(){
        NSLog(@"异步线程加载答题卡数据...");
        if(_answerCardDataSource && [_answerCardDataSource respondsToSelector:@selector(loadAnswerCardDataWithSection:andAllData:)]){
            NSArray *sectionArrays;
            NSDictionary *allDataDicts;
            [_answerCardDataSource loadAnswerCardDataWithSection:&sectionArrays andAllData:&allDataDicts];
            if(sectionArrays && sectionArrays.count > 0){
                _sectionSource = [NSMutableArray arrayWithCapacity:sectionArrays.count];
                NSLog(@"开始答题卡分组数据模型Frame转换...");
                for(AnswerCardSectionModel *sectionModel in sectionArrays){
                    if(!sectionModel)continue;
                    AnswerCardSectionModelCellFrame *cellFrame = [[AnswerCardSectionModelCellFrame alloc] init];
                    cellFrame.model = sectionModel;
                    [_sectionSource addObject:cellFrame];
                }
                NSLog(@"加载答题卡分组数据完毕...");
            }
            if(allDataDicts && allDataDicts.count > 0){
                _dataSource = [NSMutableDictionary dictionaryWithCapacity:allDataDicts.count];
                NSLog(@"开始答题卡数据模型Frame转换...");
                NSArray *keys = allDataDicts.allKeys;
                for(NSNumber *key in keys){
                    if(!key)continue;
                    NSArray *arrays = [allDataDicts objectForKey:key];
                    if(arrays){
                        NSMutableArray *dataArrays = [NSMutableArray arrayWithCapacity:arrays.count];
                        for(AnswerCardModel *model in arrays){
                            if(!model)continue;
                            AnswerCardModelCellFrame *frame = [[AnswerCardModelCellFrame alloc] init];
                            model.displayAnswer = _displayAnswer;
                            frame.model = model;
                            [dataArrays addObject:frame];
                        }
                        [_dataSource setObject:[dataArrays copy] forKey:key];
                    }
                }
                NSLog(@"加载答题卡全部数据完毕...");
            }
        }
        //update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新数据
            [self.collectionView reloadData];
            //关闭动画
            if(_waitHud){
                [_waitHud hide:YES];
            }
        });
    });
}

#pragma mark 设置是否显示答案
-(void)setDisplayAnswer:(BOOL)displayAnswer{
    if(_displayAnswer != displayAnswer){
        _displayAnswer = displayAnswer;
        //异步线程修改数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"异步线程修改是否显示答案[%d]的属性...",_displayAnswer);
            if(_dataSource && _dataSource.count > 0){
                NSArray *keys = _dataSource.allKeys;
                for(NSNumber *key in keys){
                    NSArray *arrays = [_dataSource objectForKey:key];
                    if(arrays && arrays.count > 0){
                        for(AnswerCardModelCellFrame *frame in arrays){
                            if(frame && frame.model){
                                AnswerCardModel *model = frame.model;
                                model.displayAnswer = _displayAnswer;
                                frame.model = model;
                            }
                        }
                    }
                }
                //updateUI
                dispatch_async(dispatch_get_main_queue(), ^{
                    //刷新数据
                    [self.collectionView reloadData];
                });
            }
        });
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //分组数据
    if(_sectionSource && _sectionSource.count > 0){
        [_sectionSource removeAllObjects];
    }
    //全部数据
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}

#pragma mark <AnswerCardCollectionViewCellDelegate>
//Cell点击
-(void)answerCardCell:(AnswerCardCollectionViewCell *)cell clickOrder:(NSUInteger)order{
    NSLog(@"Cell 点击: %d....", (int)order);
    //试题控制器
    PaperViewController *targetController;
    if(!targetController){
        NSArray *controllers = self.navigationController.viewControllers;
        if(controllers && controllers.count > 0){
            for(UIViewController *controller in controllers){
                if(controller && [controller isKindOfClass:[PaperViewController class]]){
                    targetController = (PaperViewController *)controller;
                    break;
                }
            }
        }
    }
    if(!targetController){
        NSLog(@"未找到试卷考试控制器!");
        return;
    }
    //加载到指定的题序
    [targetController loadItemOrder:order];
    //控制器跳转
    [self.navigationController popToViewController:targetController animated:YES];
}

#pragma mark <UICollectionViewDataSource>
//分组数据
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//每组数据
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_dataSource && _dataSource.count > 0){
        NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:section]];
        if(arrays){
            return arrays.count;
        }
    }
    return 0;
}
//每组数据显示
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AnswerCardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:__kAnswerCardViewController_cellIdentifier forIndexPath:indexPath];
    if(cell){
        cell.delegate = self;
        //cell.backgroundColor = [UIColor blueColor];
        NSLog(@"开始异步线程加载数据模型Frame[%@]...", indexPath);
        if(_dataSource && _dataSource.count > 0){
            NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:indexPath.section]];
            if(arrays && arrays.count > indexPath.item){
                //加载数据模型Frame
                [cell loadModelCellFrame:[arrays objectAtIndex:indexPath.item]];
            }
        }
    }
    return cell;
}
//分组数据显示
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if(kind && [kind isEqualToString:UICollectionElementKindSectionHeader]){
        AnswerCardSectionCollectionReusableView *sectionView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:__kAnswerCardViewController_sectionIdentifier forIndexPath:indexPath];
        if(sectionView && _sectionSource && indexPath.section < _sectionSource.count){
            NSLog(@"加载分组数据模型Frame[%@]...", indexPath);
            [sectionView loadModelCellFrame:[_sectionSource objectAtIndex:indexPath.section]];
        }
        return sectionView;
    }
    
    return nil;
}

#pragma mark <UICollectionViewDelegateFlowLayout>
//cell尺寸
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"加载cell尺寸[%@]", indexPath);
    
    return [AnswerCardModelCellFrame cellSize];
}
//分组尺寸
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    NSLog(@"加载section尺寸[%d]...", (int)section);
    if(_sectionSource && _sectionSource.count > section){
        AnswerCardSectionModelCellFrame *sectionFrame = [_sectionSource objectAtIndex:section];
        return sectionFrame.cellSize;
    }
    return CGSizeMake(320, 40);;
}
//边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 15, 5, 15);
}
@end
