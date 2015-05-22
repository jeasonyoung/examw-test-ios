//
//  BottomMenuModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "JSONSerialize.h"
//底部菜单数据模型
@interface BottomMenuModel : NSObject<JSONSerialize>
//名称
@property(nonatomic,copy)NSString *name;
//控制器
@property(nonatomic,copy)NSString *controller;
//普通图片名称
@property(nonatomic,copy)NSString *imgNormalName;
//高亮图片名称
@property(nonatomic,copy)NSString *imgHighlightName;
//状态(0-停用,1-启用)
@property(nonatomic,assign)BOOL status;
//排序号
@property(nonatomic,assign)NSInteger order;

//生成视图控制器
-(UIViewController *)buildViewController;

//从本地中加载菜单
+(NSArray *)menusFromLocal;
@end
