//
//  AccountData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "UserAccountData.h"
#import "AESCrypt.h"
#import "NSString+Hex.h"
#define __k_account_current_user_key @"current_user"//首选项存储当前用户信息主键
//账号数据私有成员变量
@interface UserAccountData(){
    NSString *_save_defaults_key;
    NSMutableDictionary *_validation_cache;
}
@end
//账号数据实现类
@implementation UserAccountData
//初始化
-(instancetype)initWithAccount:(NSString *)account{
    if(self = [super init]){
        _save_defaults_key = account;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];//初始化用户存储
        NSData *json_data = [defaults dataForKey:_save_defaults_key];//加载账号下的数据
        if(json_data == nil)return nil;
        NSError *err = nil;
        //反JSON处理
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json_data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&err];
        if(err){//JSON异常
            NSLog(@"currentUser—json-err:%@",err);
            return nil;
        }
        if(dict.count == 0)return nil;
        //KVC数据插入
        for(NSString *key in dict.allKeys){
            [self setValue:[dict objectForKey:key] forKey:[NSString stringWithFormat:@"_%@",key]];
        }
        //验证数据存储的完整性
         NSString *new_verify_code = [self createVerifyCodeWithKey:_save_defaults_key];
        //数据完整性验证通过才能进行AES解密
        if([new_verify_code isEqualToString:self.verifyCode]){
            //密码解密
            if(self.password != nil && self.password.length > 0){
                self.password = [self decrypt:self.password Key:self.account];
            }
            //解密注册码
            if(self.registerCode != nil && self.registerCode.length > 0){
                self.registerCode = [self decrypt:self.registerCode Key:self.account];
            }
        }
    }
    return self;
}
#pragma mark 初始化用户
+(instancetype)userWithAcount:(NSString *)account{
    if(account == nil || account.length == 0) return nil;
    return [[self alloc] initWithAccount:account];
}
#pragma mark 获取当前用户
//静态变量
static UserAccountData *_current_account;
+(instancetype)currentUser{
    if(!_current_account){//惰性加载
        _current_account = [[self alloc] initWithAccount:__k_account_current_user_key];
    }
    return _current_account;
}
#pragma mark 保存用户
-(void)save{
    [self saveForAccount:_save_defaults_key];
}
#pragma mark 保存为当前用户
-(void)saveForCurrent{
    [self saveForAccount:__k_account_current_user_key];
}
//保存用户
-(void)saveForAccount:(NSString *)account{
    if(self.account == nil || self.account.length == 0 || account == nil || account.length == 0) return;
    //重新生成校验码(数据为明文时生成校验码)
    NSString *new_check_code = [self createCheckCode];
    //校验码不一致才保存数据
    if(![new_check_code isEqualToString:self.checkCode]){
        //如果密码不为空，对称加密密码
        if(self.password != nil && self.password.length > 0){
            self.password = [self encrypt:self.password Key:self.account];
        }
        //如果注册码不为空，对称加密注册码
        if(self.registerCode != nil && self.registerCode.length > 0){
            self.registerCode = [self encrypt:self.registerCode Key:self.account];
        }
        //更新数据校验码
        _checkCode = new_check_code;
        //创建存储数据完整性校验码
        _verifyCode = [self createVerifyCodeWithKey:account];
        //创建JSON数据字典
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
        //初始化数据持久化
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //设置数据
        [defaults setObject:json_Data forKey:account];
        //更新数据
        [defaults synchronize];
        //保存当前用户成功后必须将静态变量重置，否则加密数据会出问题
        if([account isEqualToString:__k_account_current_user_key]){
            _current_account = nil;
        }
        //清空验证缓存
        [self cleanValidationCache];
        NSLog(@"account json : %@",[[NSString alloc] initWithData:json_Data encoding:NSUTF8StringEncoding]);
    }
}
//创建
-(NSDictionary *)createJsonDict{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithFloat:self.version] forKey:@"version"];
    [dict setObject:self.account forKey:@"account"];
    if(self.name)[dict setObject:self.name forKey:@"name"];
    if(self.accountId)[dict setObject:self.accountId forKey:@"accountId"];
    if(self.password)[dict setObject:self.password forKey:@"password"];
    if(self.registerCode)[dict setObject:self.registerCode forKey:@"registerCode"];
    if(self.checkCode)[dict setObject:self.checkCode forKey:@"checkCode"];
    if(self.verifyCode)[dict setObject:self.verifyCode forKey:@"verifyCode"];
    return dict;
}
#pragma mark 验证数据合法性
-(BOOL)validation{
    if(self.account == nil || self.account.length == 0)return NO;
    if(!_validation_cache){
        _validation_cache = [NSMutableDictionary dictionary];
    }
    NSString *new_check_code = [_validation_cache objectForKey:self.account];
    if(!new_check_code){
        //重新生成校验码
        new_check_code = [self createCheckCode];
        [_validation_cache setObject:new_check_code forKey:self.account];
    }
    //NSLog(@"validation:%@ == %@ ",self.checkCode, new_check_code);
    return [new_check_code isEqualToString:self.checkCode];
}
//加密数据
-(NSString *)encrypt:(NSString *)data Key:(NSString *)key{
    if(data == nil || data.length == 0 || key == nil || key.length == 0) return nil;
    return [AESCrypt encryptFromString:data password:key];
}
//解密数据
-(NSString *)decrypt:(NSString *)hex Key:(NSString *)key{
    if(hex == nil || hex.length == 0 || key == nil || key.length == 0) return nil;
    return [AESCrypt decryptFromString:hex password:key];
}
//拼接字符串
-(NSString *)joinPropertyToString{
    return [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",
                    [NSNumber numberWithFloat:self.version],
                    self.accountId,
                    self.account,
                    self.name,
                    self.password,
                    self.registerCode];
}
//创建校验码
//md5(account +":"+ md5(accountId+account+password+registerCode))
-(NSString *)createCheckCode{
    if(_account == nil || _account.length == 0)return nil;
    NSString *sources = [self joinPropertyToString];
    NSString *hd = [AESCrypt md5SumFromString:[sources reversed]];
    return [AESCrypt md5SumFromString:[NSString stringWithFormat:@"%@:%@",self.account,hd]];
}
//创建数据完整性校验码
-(NSString *)createVerifyCodeWithKey:(NSString *)key{
    NSString *checkCode = [self createCheckCode];
    if(checkCode == nil || checkCode.length == 0) return nil;
    NSString *sources = [NSString stringWithFormat:@"%@%@%@",[self joinPropertyToString],checkCode,key];
    return [AESCrypt md5SumFromString:[sources reversed]];
}
#pragma mark 清账号数据
-(void)clean{
    //清空验证缓存
    [self cleanValidationCache];
    //加载持久化数据
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //如果清空当前用户，则将当前用户以账号另存
    if([_save_defaults_key isEqualToString:__k_account_current_user_key]){
        //将当前用户以用户账号为主键存储
        NSData *json_data = [defaults dataForKey:_save_defaults_key];
        if(json_data != nil){
            [defaults setObject:json_data forKey:self.account];
        }
        //将当前用户重置
        _current_account = nil;
    }
    //清空用户
    [defaults removeObjectForKey:_save_defaults_key];
    //更新数据
    [defaults synchronize];
}
//清空验证缓存
-(void)cleanValidationCache{
    if(_validation_cache){
        [_validation_cache removeObjectForKey:self.account];
    }
}
#pragma mark 重置输出
-(NSString *)description{
    if(_account == nil || _account.length == 0){
        return [super description];
    }
    return [[self createJsonDict] description];
}
@end
