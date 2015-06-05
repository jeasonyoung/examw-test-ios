//
//  UserAccount.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UserAccount.h"
#import "SecureUtils.h"

#import "NSString+Reversed.h"

#define __kUserAccount_keys_userId @"userId"//用户ID
#define __kUserAccount_keys_username @"username"//用户账号
#define __kUserAccount_keys_password @"password"//用户密码
#define __kUserAccount_keys_regCode @"regCode"//注册码
#define __kUserAccount_keys_checkCode @"checkCode"//校验码

#define __kUserAccount_currentUser @"current_user"//当前用户
#define __kUserAccount_user @"user_%@"//当前用户
//用户账号信息成员变量
@interface UserAccount (){
    //密码
    NSString *_password;
    //是否为脏数据
    BOOL _isDirty;
}
@end
//用户账号信息实现
@implementation UserAccount

#pragma mark 初始化
-(instancetype)initWithUserId:(NSString *)userId withUsername:(NSString *)username{
    if(self = [super init]){
        NSLog(@"更新用户名:[%@,%@]", userId, username);
        _userId = userId;
        _username = username;
        _password = @"";
        _regCode = @"";
        _isDirty = YES;
    }
    return self;
}

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSArray *keys = dict.allKeys;
        //用户ID
        if([keys containsObject:__kUserAccount_keys_userId]){
            id value = [dict objectForKey:__kUserAccount_keys_userId];
            _userId = (value == [NSNull null] ? @"" : value);
        }
        //用户账号
        if([keys containsObject:__kUserAccount_keys_username]){
            id value = [dict objectForKey:__kUserAccount_keys_username];
            _username = (value == [NSNull null] ? @"" : value);
        }
        //用户密码
        if([keys containsObject:__kUserAccount_keys_password]){
            id value = [dict objectForKey:__kUserAccount_keys_password];
            _password = (value == [NSNull null] ? @"" : value);
        }
        //注册码
        if([keys containsObject:__kUserAccount_keys_regCode]){
            id value = [dict objectForKey:__kUserAccount_keys_regCode];
            _regCode = (value == [NSNull null] ? @"" : value);
        }
    }
    return self;
}

#pragma mark 根据用户账号加载账号数据
+(instancetype)accountWithUsername:(NSString *)username{
    NSLog(@"加载用户账号[%@]数据...", username);
    if(username && username.length > 0){
        NSString *key = [NSString stringWithFormat:__kUserAccount_user,[SecureUtils hexMD5WithText:username]];
        return [self loadUserAccountFromDefaultWithKey:key];
    }
    return nil;
}

#pragma mark 当前用户
+(instancetype)current{
    NSLog(@"加载当前用户数据...");
    return [self loadUserAccountFromDefaultWithKey:__kUserAccount_currentUser];
}

//从UserDefault加载用户数据
+(instancetype)loadUserAccountFromDefaultWithKey:(NSString *)key{
    NSLog(@"从UserDefault加载用户[key=%@]数据...",key);
    if(key && key.length > 0){
        @try {
            //初始化账号存储
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSData *data = [defaults dataForKey:key];
            if(data && data.length > 0){
                NSError *err;
                //反序列化处理
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
                if(err){
                    NSLog(@"反序列化失败:%@", err);
                    return nil;
                }
                //获取JSON字段
                NSString *userId = [dict objectForKey:__kUserAccount_keys_userId],
                *username = [dict objectForKey:__kUserAccount_keys_username],
                *regCode  = [dict objectForKey:__kUserAccount_keys_regCode],
                *checkCode = [dict objectForKey:__kUserAccount_keys_checkCode],
                *pwd = [dict objectForKey:__kUserAccount_keys_password];
                //验证数据完整性
                NSString *newCheckCode = [SecureUtils hexMD5WithText:[[NSString stringWithFormat:@"%@-%@-%@-%@",
                                                                       userId,username,pwd,regCode] reversed]];
                NSLog(@"验证数据完整性=>%@/%@",checkCode,newCheckCode);
                if(checkCode && [newCheckCode isEqualToString:checkCode]){
                    //解密密码
                    NSString *password = @"";
                    if(pwd && pwd.length > 0){//密文密码不能为空
                        password = [SecureUtils decryptFromHex:pwd withPassword:username];
                    }
                    //创建对象
                    return [[self alloc]initWithDict:@{__kUserAccount_keys_userId:userId,
                                                       __kUserAccount_keys_username:username,
                                                       __kUserAccount_keys_password:password,
                                                       __kUserAccount_keys_regCode:regCode}];
                }
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"加载用户数据异常:%@", exception);
        }
    }
    return nil;
}


#pragma mark 验证密码
-(BOOL)validateWithPassword:(NSString *)password{
    NSLog(@"验证密码...");
    if(password && password.length > 0 && _password){
        return [password isEqualToString:_password];
    }
    return NO;
}

#pragma mark 更新密码
-(void)updatePassword:(NSString *)password{
    if(password && ![_password isEqualToString:password]){
        NSLog(@"更新密码:%@",password);
        _password = password;
        _isDirty = YES;
    }
}

#pragma mark 更新注册码
-(void)updateRegCode:(NSString *)regCode{
    if(regCode && regCode.length > 0){
        NSLog(@"更新注册码:%@",regCode);
        _regCode = regCode;
        _isDirty = YES;
    }
}

#pragma mark 保存数据
-(BOOL)save{
    NSLog(@"保存用户[%@]数据...",_username);
    if(!_isDirty) return YES;
    if(_username && _username.length > 0){
        NSString *key = [NSString stringWithFormat:__kUserAccount_user,[SecureUtils hexMD5WithText:_username]];
        if([self saveUserAccountWithKey:key]){
            _isDirty = NO;
        }else{
            return NO;
        }
    }
    return YES;
}

#pragma mark 保存为当前用户
-(BOOL)saveForCurrent{
    NSLog(@"将用户[%@]保存为当前用户...",_username);
    //1.先保存到本地
    if ([self save]) {
        //2.再将用户保存为当前用户
        return [self saveUserAccountWithKey:__kUserAccount_currentUser];
    }
    return NO;
}

//保存到本地存储
-(BOOL)saveUserAccountWithKey:(NSString *)key{
    NSLog(@"保存到本地键:%@", key);
    if(key && key.length > 0){
        //1.将密码加密
        NSString *pwd = @"";
        if(_password && _password.length > 0){
            NSData *data = [_password dataUsingEncoding:NSUTF8StringEncoding];
            pwd = [SecureUtils hexEncyptFromData:data withPassword:_username];
        }
        //2.计算校验码
        NSString *checkCode = [SecureUtils hexMD5WithText:[[NSString stringWithFormat:@"%@-%@-%@-%@",
                                                               _userId,_username,pwd,_regCode] reversed]];
        //3.拼装并JSON化
        NSDictionary *dict = @{__kUserAccount_keys_userId : (_userId ? _userId : @""),
                               __kUserAccount_keys_username : (_username ? _username : @""),
                               __kUserAccount_keys_password : pwd,
                               __kUserAccount_keys_regCode : (_regCode ? _regCode : @""),
                               __kUserAccount_keys_checkCode : checkCode };
        //4.JSON序列化
        if([NSJSONSerialization isValidJSONObject:dict]){
            NSError *err;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
            if(err){
                NSLog(@"数据JSON序列化时错误:%@", err);
                return NO;
            }
            //5.保存到本地键中
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data forKey:key];
            [defaults synchronize];
            return YES;
        }else{
            NSLog(@"不符合JSON化格式:%@", dict);
        }
    }
    return NO;
}

#pragma mark 清除账号数据
-(void)clean{
    NSLog(@"清除账号[%@]数据...",_username);
    if(_username && _username.length > 0){
        NSString *key = [NSString stringWithFormat:__kUserAccount_user,[SecureUtils hexMD5WithText:_username]];
        NSLog(@"用户账号存储键>>%@", key);
        //初始化账号存储
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //移除存储键
        [defaults removeObjectForKey:key];
        //更新
        [defaults synchronize];
    }
}
@end
