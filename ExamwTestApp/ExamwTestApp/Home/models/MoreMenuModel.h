//
//  MoreMenuModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "JSONSerialize.h"
//更多菜单数据模型
@interface MoreMenuModel : NSObject<JSONSerialize>
//名称
@property(nonatomic,copy,readonly)NSString *name;
//图标
@property(nonatomic,copy,readonly)NSString *iconName;
//控制器
@property(nonatomic,copy,readonly)NSString *controller;
//状态(0-停用,1-启用)
@property(nonatomic,assign,readonly)BOOL status;
//排序号
@property(nonatomic,assign,readonly)NSInteger order;

//生成视图控制器
-(UIViewController *)buildViewController;
@end
