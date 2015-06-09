//
//  AppConstants.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#ifndef ExamwTestApp_AppConstants_h
#define ExamwTestApp_AppConstants_h

//应用全局常量配置

//当前应用版本
#define __kAPP_VER 1.0
//客户端标示(用于考试网用户登陆验证)
#define __kAPP_ID @"357070005327186"
//客户端名称
#define __kAPP_NAME @"中华考试网题库客户端 iOS v%.1f"
//客户端类型代码
#define __kAPP_TYPECODE 7

//服务器认证用户名
#define __kAPP_API_USERNAME @"admin"
//服务器认证密码
#define __kAPP_API_PASSWORD @"123456"
//频道(用户登录/注册)
#define __kAPP_API_CHANNEL @"jzs1"

//服务器数据API
//注册API
#define _kAPP_API_REGISTER_URL @"http://localhost:8080/examw-test/api/m/user/register"
//登陆API
#define _kAPP_API_LOGIN_URL @"http://localhost:8080/examw-test/api/m/user/login"
//注册码校验API
#define _kAPP_API_REGCODECHECK_URL @"http://localhost:8080/examw-test/api/m/app/register"
//考试类别API
#define _kAPP_API_CATEGORY_URL @"http://localhost:8080/examw-test/api/m/download/categories"
//考试数据API
//#define _kAPP_API_EXAMS_URL @""
//科目数据API
#define _kAPP_API_SUBJECTS_URL @"http://localhost:8080/examw-test/api/m/sync/exams"
//产品数据API
//#define _kAPP_API_PRODUCTS_URL @""
//试卷数据API
#define _kAPP_API_PAPERS_URL @"http://localhost:8080/examw-test/api/m/sync/papers"


//默认分页数据
#define _kAPP_DEFAULT_PAGEROWS 10

//计算文字尺寸选项
#define STR_SIZE_OPTIONS (NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)//
//屏幕宽度
#define SCREEN_WIDTH CGRectGetWidth([[UIScreen mainScreen] bounds])//

//下一题等待的时间
#define NEXT_ITEM_SEC 0.6//下一题等待的时间(秒)
//红色值
#define GLOBAL_REDCOLOR_HEX 0xBA2121
//等待颜色
#define WAIT_HUD_COLOR 0xBA2121//0xD3D3D3
//全局字体
#define GLOBAL_FONT [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//应用静态常量
@interface AppConstants : NSObject
//全局列表一级字体
+(UIFont *)globalListFont;
//全局列表二级字体
+(UIFont *)globalListSubFont;
//全局列表三级字体
+(UIFont *)globalListThirdFont;
//试卷试题字体
+(UIFont *)globalPaperItemFont;

@end
