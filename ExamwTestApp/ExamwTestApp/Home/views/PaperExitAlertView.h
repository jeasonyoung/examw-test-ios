//
//  PaperExitAlertView.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/31.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//试卷退出AlertView代理
@class PaperExitAlertView;
@protocol PaperExitAlertViewDelegate <NSObject>
//交卷
-(void)submitAlertView:(PaperExitAlertView *)alertView;
//下次再做
-(void)nextAlertView:(PaperExitAlertView *)alertView;
@end
//试卷退出AlertView
@interface PaperExitAlertView : NSObject
//设置代理
@property(nonatomic,assign)id<PaperExitAlertViewDelegate> delegate;
//显示Alert
-(void)showAlert;
@end
