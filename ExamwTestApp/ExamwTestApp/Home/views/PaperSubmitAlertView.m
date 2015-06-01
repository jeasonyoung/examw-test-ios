//
//  PaperSubmitAlertView.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperSubmitAlertView.h"

#define __kPaperSubmitAlertView_title @"确认"//
#define __kPaperSubmitAlertView_msg @"是否确认交卷?"
#define __kPaperSubmitAlertView_btnCancel @"否"
#define __kPaperSubmitAlertView_btnSubmit @"是"
//交卷确认提示框成员变量
@interface PaperSubmitAlertView ()<UIAlertViewDelegate>{
    UIAlertView *_alertView;
}
@end
//交卷确认提示框实现
@implementation PaperSubmitAlertView

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _alertView = [[UIAlertView alloc] initWithTitle:__kPaperSubmitAlertView_title
                                                message:__kPaperSubmitAlertView_msg
                                               delegate:self
                                      cancelButtonTitle:__kPaperSubmitAlertView_btnCancel
                                      otherButtonTitles:__kPaperSubmitAlertView_btnSubmit, nil];
    }
    return self;
}


#pragma mark 显示提示框
-(void)showAlert{
    [_alertView show];
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%@-click:%d",__kPaperSubmitAlertView_msg, (int)buttonIndex);
    switch (buttonIndex) {
        case 1:{//确认提交
            if(_delegate && [_delegate respondsToSelector:@selector(submitPaperHandler)]){
                [_delegate submitPaperHandler];
            }
            break;
        }
        default:
            break;
    }
}
@end
