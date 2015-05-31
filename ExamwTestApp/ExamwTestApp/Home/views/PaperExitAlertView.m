//
//  PaperExitAlertView.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/31.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperExitAlertView.h"

#define __kPaperExitAlertView_title @"退出"//
#define __kPaperExitAlertView_msg @"是否退出考试?"
#define __kPaperExitAlertView_btnCancel @"取消"
#define __kPaperExitAlertView_btnSubmit @"交卷"
#define __kPaperExitAlertView_btnConfirm @"下次再做"
//试卷退出AlertView成员变量
@interface PaperExitAlertView ()<UIAlertViewDelegate>{
    UIAlertView *_alertView;
}
@end
//试卷退出AlertView实现
@implementation PaperExitAlertView

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _alertView = [[UIAlertView alloc] initWithTitle:__kPaperExitAlertView_title
                                                message:__kPaperExitAlertView_msg
                                               delegate:self
                                      cancelButtonTitle:__kPaperExitAlertView_btnCancel
                                      otherButtonTitles:__kPaperExitAlertView_btnSubmit,__kPaperExitAlertView_btnConfirm, nil];
    }
    return self;
}

#pragma mark 显示处理
-(void)showAlert{
    [_alertView show];
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"试卷退出AlertView-click:%d", (int)buttonIndex);
    switch (buttonIndex) {
        case 1:{//交卷
            if(self.delegate && [self.delegate respondsToSelector:@selector(submitAlertView:)]){
                [self.delegate submitAlertView:self];
            }
            break;
        }
        case 2:{//下次再做
            if(self.delegate && [self.delegate respondsToSelector:@selector(nextAlertView:)]){
                [self.delegate nextAlertView:self];
            }
            break;
        }
    }
}
@end
