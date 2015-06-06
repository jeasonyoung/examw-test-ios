//
//  MoreMenuModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MoreMenuModel.h"

#define __kMoreMenuModel_keys_name @"name"//名称
#define __kMoreMenuModel_keys_iconName @"iconName"//图标
#define __kMoreMenuModel_keys_controller @"controller"//控制器
#define __kMoreMenuModel_keys_status @"status"//状态
#define __kMoreMenuModel_keys_order @"order"//排序号

//更多菜单数据模型实现
@implementation MoreMenuModel

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSArray *keys = dict.allKeys;
        //名称
        if([keys containsObject:__kMoreMenuModel_keys_name]){
            id value = [dict objectForKey:__kMoreMenuModel_keys_name];
            _name = (value == [NSNull null] ? @"" : value);
        }
        //图标
        if([keys containsObject:__kMoreMenuModel_keys_iconName]){
            id value = [dict objectForKey:__kMoreMenuModel_keys_iconName];
            _iconName = (value == [NSNull null] ? @"" : value);
        }
        //控制器
        if([keys containsObject:__kMoreMenuModel_keys_controller]){
            id value = [dict objectForKey:__kMoreMenuModel_keys_controller];
            _controller = (value == [NSNull null] ? @"" : value);
        }
        //状态
        if([keys containsObject:__kMoreMenuModel_keys_status]){
            id value = [dict objectForKey:__kMoreMenuModel_keys_status];
            _status = (value == [NSNull null] ? NO : ((NSNumber *)value).boolValue);
        }
        //排序号
        if([keys containsObject:__kMoreMenuModel_keys_order]){
            id value = [dict objectForKey:__kMoreMenuModel_keys_order];
            _order = (value == [NSNull null] ? 0 : ((NSNumber *)value).integerValue);
        }
    }
    return self;
}

#pragma mark 反射生产视图控制器
-(UIViewController *)buildViewController{
    NSLog(@"准备生成视图控制器[%@]...",[self serialize]);
    if(!_controller || _controller.length == 0)return nil;
    @try {
        UIViewController *controller = [[NSClassFromString(_controller) alloc] init];
        if(!controller){
            NSLog(@"反射控制器[%@]失败!", _controller);
            return nil;
        }
        return controller;
    }
    @catch (NSException *exception) {
        NSLog(@"初始化更多菜单发生异常:%@", exception);
    }
    return nil;
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    return @{__kMoreMenuModel_keys_name : (_name ? _name : @""),
             __kMoreMenuModel_keys_iconName : (_iconName ? _iconName : @""),
             __kMoreMenuModel_keys_controller : (_controller ? _controller : @""),
             __kMoreMenuModel_keys_status : [NSNumber numberWithBool:_status],
             __kMoreMenuModel_keys_order : [NSNumber numberWithInteger:_order]};
}
@end
