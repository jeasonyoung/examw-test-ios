//
//  RegisterData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "RegisterData.h"

#define __k_register_data_parameters_account @"account"//用户名
#define __k_register_data_parameters_password @"password"//密码
#define __k_register_data_parameters_username @"username"//真实姓名
#define __k_register_data_parameters_email @"email"//电子邮箱
#define __k_register_data_parameters_phone @"phone"//手机号
#define __k_register_data_parameters_channel @"channel"//频道
//注册数据成员变量
@interface RegisterData(){
    NSArray *_fieldKeys;
}
@end
//注册数据实现类
@implementation RegisterData
#pragma mark 重载初始化
- (instancetype)init{
    if(self = [super init]){
        _fieldKeys = @[@"account",@"password",@"repassword",@"username",@"email",@"phone"];
    }
    return self;
}
#pragma mark 根据Tag值设置值
-(void)setValue:(NSString *)value forTag:(NSInteger)tag{
    if(tag <= _fieldKeys.count && tag > 0){
        if([value isEqual:[NSNull null]])return;
        [self setValue:value forKey:[_fieldKeys objectAtIndex:(tag - 1)]];
    }
}
#pragma mark 重载序列化
-(NSDictionary *)serializeJSON{
    NSDictionary *local_dict = @{__k_register_data_parameters_account:self.account,
                                 __k_register_data_parameters_password:self.password,
                                 __k_register_data_parameters_username:self.username,
                                 __k_register_data_parameters_email:self.email,
                                 __k_register_data_parameters_phone:self.phone,
                                 __k_register_data_parameters_channel:_kAppClientChannel};
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super serializeJSON]];
    [dict addEntriesFromDictionary:local_dict];
    return [dict copy];
}
@end