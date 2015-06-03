//
//  MyUserModelTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//用户信息Cell代理
@protocol MyUserModelCellDelegate <NSObject>
//注册点击
-(void)userRegisterClick:(id)sender;
//用户登录
-(void)userLoginClick:(id)sender;
//切换注册码
-(void)changeRegCode:(id)sender;
@end

@class MyUserModelCellFrame;
//用户信息Cell
@interface MyUserModelTableViewCell : UITableViewCell
//代理
@property(nonatomic,assign)id<MyUserModelCellDelegate> delegate;
//加载数据模型Cell Frame
-(void)loadModelCellFrame:(MyUserModelCellFrame *)cellFrame;
@end
