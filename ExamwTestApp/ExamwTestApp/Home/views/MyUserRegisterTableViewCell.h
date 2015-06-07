//
//  MyUserRegisterTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/7.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//用户注册Cell代理
@class UserRegisterModel;
@protocol MyUserRegisterTableViewCellDelegate <NSObject>

//用户注册按钮点击事件
-(void)userRegisterBtnClick:(UIButton *)sender registerModel:(UserRegisterModel *)model;

@end

//用户注册Cell
@interface MyUserRegisterTableViewCell : UITableViewCell

//代理
@property(nonatomic,assign)id<MyUserRegisterTableViewCellDelegate> delegate;

//行高
+(CGFloat)cellHeight;

@end
