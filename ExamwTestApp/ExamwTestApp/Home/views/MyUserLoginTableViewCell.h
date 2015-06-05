//
//  MyUserLoginTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//代理处理
@class MyUserLoginTableViewCell;
@protocol MyUserLoginTableViewCellDelegate <NSObject>

//登录按钮点击事件
-(void)userLoginCell:(MyUserLoginTableViewCell *)cell loginClick:(UIButton *)sender account:(NSString *)account password:(NSString *)pwd;

//注册按钮点击事件
-(void)userLoginCell:(MyUserLoginTableViewCell *)cell registerClick:(UIButton *)sender;

@end
//用户登录Cell
@interface MyUserLoginTableViewCell : UITableViewCell

//代理
@property(nonatomic,assign)id<MyUserLoginTableViewCellDelegate> delegate;

//行高
+(CGFloat)cellHeight;

//加载账号名称
-(void)loadAccount:(NSString *)account;
@end
