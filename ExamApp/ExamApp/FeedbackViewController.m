//
//  FeedbackViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UIViewController+VisibleView.h"
#import "NSString+Size.h"
#import "ETextView.h"

#define __k_feedback_marign_top 15//顶部间距
#define __k_feedback_margin_left 12//左边间距
#define __k_feedback_margin_right 12//右边间距
#define __k_feedback_margin_bottom 15//底部间距
#define __k_feedback_margin_inner 10//内部各空间间距
#define __k_feedback_btn_height 46//提交按钮高度
#define __k_feedback_btn_title @"提交"//
#define __k_feedback_content_total 1000//内容长度
#define __k_feedback_count_format @"已输入%d/%d"//字数统计字符串
#define __k_feedback_placehoder @"请写入您的意见或者建议"//占位字符串
#define __k_feedback_alter_title @"提示"//
#define __k_feedback_alter_message @"字符个数不能大于%d"//
#define __k_feedback_alter_cancal @"确定"//

//意见反馈控制器成员变量
@interface FeedbackViewController ()<UITextViewDelegate>{
    //容器
    UIView *_containerView;
    //意见反馈内容控件
    ETextView *_contentView;
    //字符统计Label
    UILabel *_lbTotal;
    //提交按钮
    UIButton *_btn;
}
@end
//意见反馈控制器实现类
@implementation FeedbackViewController
#pragma mark 入口函数
- (void)viewDidLoad {
    [super viewDidLoad];
    //兼容继承于UIScrollView的控件在navigationbar容器中出现顶部空白的问题
    if([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //创建容器
    _containerView = [[UIView alloc] initWithFrame:[self loadVisibleViewFrame]];
    //添加提交按钮
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btn setTitle:__k_feedback_btn_title forState:UIControlStateNormal];
    [_btn setBackgroundImage:[UIImage imageNamed:@"feedback_post_normal.png"] forState:UIControlStateNormal];
    [_btn setBackgroundImage:[UIImage imageNamed:@"feedback_post_selected.png"] forState:UIControlStateHighlighted];
    [_btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_btn];
    
    //添加字符统计
    NSString *text = [self formatContentCharatersTotal:0];
    UIFont *font =[UIFont systemFontOfSize:13.0];
    CGSize textSize = [text sizeWithFont:font];
    _lbTotal = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
    _lbTotal.font = font;
    _lbTotal.textAlignment = NSTextAlignmentLeft;
    _lbTotal.textColor = [UIColor brownColor];
    _lbTotal.text = text;
    [_containerView addSubview:_lbTotal];
    
    //添加输入框
    _contentView = [[ETextView alloc] init];
    _contentView.placehoder = __k_feedback_placehoder;
    _contentView.delegate = self;
    [_containerView addSubview:_contentView];
    
    //布局容器下的子视图的Frames
    [self layoutContainerSubViewFrames];
    //添加视图
    [self.view addSubview:_containerView];
    
    //监听键盘
    //键盘即将弹出，就会发出UIKeyboardWillShowNotification通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboradWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘即将隐藏，就会发出UIKeyboardWillHideNotification通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark 布局容器下的子视图的Frames
-(void)layoutContainerSubViewFrames{
    CGRect tempFrame = _containerView.frame;
    tempFrame.origin.x = __k_feedback_margin_left;
    tempFrame.origin.y = tempFrame.size.height - __k_feedback_margin_bottom - __k_feedback_btn_height;
    tempFrame.size.width -= (__k_feedback_margin_left + __k_feedback_margin_right);
    tempFrame.size.height = __k_feedback_btn_height;
    //设置提交按钮frame
    _btn.frame = tempFrame;
    //设置字符统计
    tempFrame.size.height = _lbTotal.bounds.size.height;
    tempFrame.origin.y = tempFrame.origin.y -= (__k_feedback_margin_inner + tempFrame.size.height);
    _lbTotal.frame = tempFrame;
    //设置输入框frame
    tempFrame.size.height = tempFrame.origin.y - (__k_feedback_marign_top + __k_feedback_margin_inner);
    tempFrame.origin.y = __k_feedback_marign_top;
    _contentView.frame = tempFrame;
}
#pragma mark 按钮点击事件
-(void)btnClick:(id)btn{
    [self.view endEditing:YES];
    ///TODO:提交数据到服务器
    NSLog(@"btnClick:%@", btn);
}
#pragma mark 格式化内容字符串统计
-(NSString *)formatContentCharatersTotal:(int)count{
   return [NSString stringWithFormat:__k_feedback_count_format,count,__k_feedback_content_total];
}
#pragma mark 键盘即将弹出
-(void)keyboradWillShow:(NSNotification *)note{
    //1.键盘弹出需要时间
    CGFloat duration = [note.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //2.动画
    //取出键盘高度尺寸
    CGRect keyboardSize = [note.userInfo [UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect tempFrame = _containerView.frame;
    tempFrame.size.height -= keyboardSize.size.height;
    [UIView animateWithDuration:duration animations:^{
        _containerView.frame = tempFrame;
        [self layoutContainerSubViewFrames];
    }];
}
#pragma mark 关闭键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];//关闭键盘
    [super touchesBegan:touches withEvent:event];
}
#pragma mark 键盘即将隐藏
-(void)keyboardWillHide:(NSNotification *)note{
    //1.键盘弹出需要时间
    CGFloat duration = [note.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //2.动画
    //取出键盘高度尺寸
    CGRect keyboardSize = [note.userInfo [UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect tempFrame = _containerView.frame;
    tempFrame.size.height += keyboardSize.size.height;
    [UIView animateWithDuration:duration animations:^{
        _containerView.frame = tempFrame;
        [self layoutContainerSubViewFrames];
    }];
}

#pragma mark UITextViewDelegate
#pragma mark 字符限制
-(void)textViewDidChange:(UITextView *)textView{
    NSInteger count = textView.text.length;
    if(count > __k_feedback_content_total){
        NSString *msg = [NSString stringWithFormat:__k_feedback_alter_message,__k_feedback_content_total];
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:__k_feedback_alter_title
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:__k_feedback_alter_cancal
                                                  otherButtonTitles:nil, nil];
        [alterView show];
        textView.text = [textView.text substringToIndex:__k_feedback_content_total];
        count = textView.text.length;
    }
    _lbTotal.text = [self formatContentCharatersTotal:(int)count];
}

#pragma mark view显示完毕的时候再弹出键盘，避免显示控制器view的时候卡住
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //成为第一响应者（呼叫键盘）
    //[_contentView becomeFirstResponder];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 移除消息监听
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
