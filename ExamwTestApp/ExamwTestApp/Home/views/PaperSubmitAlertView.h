//
//  PaperSubmitAlertView.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//交卷确认提示框代理
@class PaperSubmitAlertView;
@protocol PaperSubmitAlertViewDelegate <NSObject>
@required
//提交试卷处理
-(void)submitPaperHandler;
@end

//交卷确认提示框
@interface PaperSubmitAlertView : NSObject
//提交代理
@property(nonatomic,assign)id<PaperSubmitAlertViewDelegate> delegate;
//显示提示框
-(void)showAlert;
@end
