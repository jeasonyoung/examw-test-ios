//
//  ItemViewExitAlert.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//试题视图退出对话框委托
@protocol ItemViewExitAlertDelegate <NSObject>
//退出事件处理
-(void)alertExitWithTag:(NSInteger)tag;
@end

#define __kItemViewExitAlertCancel 0//取消
#define __kItemViewExitAlertSubmit 1//交卷
#define __kItemViewExitAlertConfirm 2//下次再做
//试题视图退出对话框
@interface ItemViewExitAlert : NSObject
@property(nonatomic,assign)id<ItemViewExitAlertDelegate> delegate;
//显示对话框
-(void)showAlert;
@end
