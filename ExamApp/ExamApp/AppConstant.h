//
//  AppConstant.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
//应用常量

//客户端唯一标示
#define _kAppClientID @"357070005327186"
//客户端名称，版本
#define _kAppClientName @"焚题库 ios v1.0"
//软件版本
#define _kAppClientVersion 1.0//2015版北京会计从业资格考试通（基础+财经法规）
//客户端类型代码
#define _kAppClientTypeCode 7
//产品ID
#define _kAppClientProductId @"c4a7b24f-0c0b-47bf-a1e4-1b85e31a9eaa"//

//频道(固定值 根据考试来填写)
#define _kAppClientChannel @"jzs1"

//访问用户名
#define _kAppClientUserName @"admin"
//访问密码
#define _kAppClientPassword @"123456"

//服务器地址前缀
#define _kAppHostUrlPrefix @"http://localhost:8080/examw-test"

//注册提交URL
#define _kAppClientUserRegisterUrl [NSString stringWithFormat:@"%@%@",_kAppHostUrlPrefix,@"/api/m/user/register"]
//登录URL
#define _kAppClientUserLoginUrl [NSString stringWithFormat:@"%@%@",_kAppHostUrlPrefix,@"/api/m/user/login"]
//注册码验证URL
#define _kAppClientRegisterCodeUrl [NSString stringWithFormat:@"%@%@",_kAppHostUrlPrefix,@"/api/m/app/register"]
//同步产品下的考试科目
#define _kAppClientSyncExamsUrl [NSString stringWithFormat:@"%@%@",_kAppHostUrlPrefix,@"/api/m/sync/exams"]