//
//  AccountData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "AccountData.h"
#import "AESCrypt.h"
#import "NSString+Hex.h"

#define __k_account_defaults_key @"current_user"//首选项存储当前用户信息主键
//账号数据私有成员变量
@interface AccountData()

@end
//账号数据实现类
@implementation AccountData
//静态变量
static AccountData *_accountData;
#pragma mark 获取当前用户
+(instancetype)currentUser{
    NSLog(@"currentUser 0-> %@", _accountData);
    //惰性加载
    if(_accountData)return _accountData;
    NSLog(@"currentUser 1-> %@", _accountData);
    //加载持久化数据
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *json_data = [defaults dataForKey:__k_account_defaults_key];
    if(json_data == nil)return nil;
    NSError *err = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json_data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&err];
    if(err){
        NSLog(@"currentUser—json:%@",err);
        return nil;
    }
    if(dict.count == 0)return nil;
    _accountData = [[AccountData alloc] init];
    for(NSString *key in dict.allKeys){
        [_accountData setValue:[dict objectForKey:key] forKey:[NSString stringWithFormat:@"_%@",key]];
    }
    //密码解密
    if(_accountData.password != nil && _accountData.password.length > 0){
        _accountData.password = [AccountData decrypt:_accountData.password Key:_accountData.account];
    }
    //解密注册码
    if(_accountData.registerCode != nil && _accountData.registerCode.length > 0){
        _accountData.registerCode = [AccountData decrypt:_accountData.registerCode Key:_accountData.account];
    }
    NSLog(@"currentUser 2-> %@", _accountData);
    return _accountData;
}
#pragma mark 数据更新
-(void)save{
    if(_account == nil || _account.length == 0)return;
    //重新生成校验码(数据为明文时生成校验码)
    NSString *new_check_code = [self createCheckCode];
    //如果密码不为空，对称加密密码
    if(_password != nil && _password.length > 0){
        _password = [AccountData encrypt:_password Key:_account];
    }
    //如果注册码不为空，对称加密注册码
    if(_registerCode != nil && _registerCode.length > 0){
        _registerCode = [AccountData encrypt:_registerCode Key:_account];
    }
    
    //校验码不一致才保存数据
    if(![new_check_code isEqualToString:_checkCode]){
        _checkCode = new_check_code;//更新校验码
        NSDictionary *dict = [self createJsonDict];
        NSError *err = nil;
        //将对象JSON化处理
        NSData *json_Data = [NSJSONSerialization dataWithJSONObject:dict
                                                            options:NSJSONWritingPrettyPrinted
                                                                error:&err];
        if(err){
            NSLog(@"create_json_error:%@", err);
            return;
        }
        //数据持久化
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:json_Data forKey:__k_account_defaults_key];
        [defaults synchronize];
        //保存成功后必须将静态变量重置，否则加密数据会出问题
        _accountData = nil;
        NSLog(@"account json : %@",[[NSString alloc] initWithData:json_Data encoding:NSUTF8StringEncoding]);
    }
}
//创建
-(NSDictionary *)createJsonDict{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithFloat:_version] forKey:@"version"];
    [dict setObject:_account forKey:@"account"];
    if(_accountId)[dict setObject:_accountId forKey:@"accountId"];
    if(_password)[dict setObject:_password forKey:@"password"];
    if(_registerCode)[dict setObject:_registerCode forKey:@"registerCode"];
    [dict setObject:_checkCode forKey:@"checkCode"];
    return dict;
}
#pragma mark 验证数据合法性
-(BOOL)validation{
    if(_account == nil || _account.length == 0)return NO;
    //重新生成校验码
    NSString *new_check_code = [self createCheckCode];
    NSLog(@"validation:%@ == %@ ",self.checkCode, new_check_code);
    return [new_check_code isEqualToString:self.checkCode];
}
//加密数据
+(NSString *)encrypt:(NSString *)data Key:(NSString *)key{
    if(data == nil || data.length == 0 || key == nil || key.length == 0) return nil;
    return [AESCrypt encryptFromString:data password:key];
}
//解密数据
+(NSString *)decrypt:(NSString *)hex Key:(NSString *)key{
    if(hex == nil || hex.length == 0 || key == nil || key.length == 0) return nil;
    return [AESCrypt decryptFromString:hex password:key];
}
//创建校验码
//md5(account +":"+ md5(accountId+account+password+registerCode))
-(NSString *)createCheckCode{
    if(_account == nil || _account.length == 0)return nil;
     NSString *sources = [NSString stringWithFormat:@"%@:%@:%@:%@:%@",
                          [NSNumber numberWithFloat:_version],
                          _accountId,
                          _account,
                          _password,
                          _registerCode];
    if(sources.length == 0) return nil;
    NSLog(@"sources => %@", sources);
    NSString *hd = [AESCrypt md5SumFromString:[sources reversed]];
    return [AESCrypt md5SumFromString:[NSString stringWithFormat:@"%@:%@",self.account,hd]];
}
#pragma mark 重置输出
-(NSString *)description{
    if(_account == nil || _account.length == 0){
        return [super description];
    }
    return [[self createJsonDict] description];
}
@end
