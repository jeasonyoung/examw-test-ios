//
//  BottomMenuModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "BottomMenuModel.h"

#define __kBottomMenuModel_keys_name @"name"//菜单名称
#define __kBottomMenuModel_keys_controller @"controller"//控制器名称
#define __kBottomMenuModel_keys_imgNormalName @"imgNormalName"//图片名称
#define __kBottomMenuModel_keys_imgHighlightName @"imgHighlightName"//高亮图片名称
#define __kBottomMenuModel_keys_status @"status"//状态
#define __kBottomMenuModel_keys_order @"order"//排序号

#define __kBottomMenuModel_menuFileName @"mainBottomMenus"//主界面底部菜单文件名
#define __kBottomMenuModel_menuFileTypeName @"plist"//文件类型
//底部菜单数据模型实现
@implementation BottomMenuModel

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSArray *keys = dict.allKeys;
        //菜单名称
        if([keys containsObject:__kBottomMenuModel_keys_name]){
            id value = [dict objectForKey:__kBottomMenuModel_keys_name];
            _name = (value == [NSNull null]) ? @"" : value;
        }
        //控制器名称
        if([keys containsObject:__kBottomMenuModel_keys_controller]){
            id value = [dict objectForKey:__kBottomMenuModel_keys_controller];
            _controller = (value == [NSNull null]) ? @"" : value;
        }
        //图片名称
        if([keys containsObject:__kBottomMenuModel_keys_imgNormalName]){
            id value = [dict objectForKey:__kBottomMenuModel_keys_imgNormalName];
            _imgNormalName = (value == [NSNull null]) ? @"" : value;
        }
        //高亮图片名称
        if([keys containsObject:__kBottomMenuModel_keys_imgHighlightName]){
            id value = [dict objectForKey:__kBottomMenuModel_keys_imgHighlightName];
            _imgHighlightName = (value == [NSNull null]) ? @"" : value;
        }
        //状态
        if([keys containsObject:__kBottomMenuModel_keys_status]){
            id value = [dict objectForKey:__kBottomMenuModel_keys_status];
            _status = (value == [NSNull null]) ? 0 : [(NSNumber *)value boolValue];
        }
        //排序号
        if([keys containsObject:__kBottomMenuModel_keys_order]){
            id value = [dict objectForKey:__kBottomMenuModel_keys_order];
            _order = (value == [NSNull null]) ? 0 : [(NSNumber *)value integerValue];
        }
    }
    return self;
}

#pragma mark 生成视图控制器
-(UIViewController *)buildViewController{
    NSLog(@"准备生成视图控制器[%@]...",[self serialize]);
    if(!_name || _name.length == 0)return nil;
    if(!_controller || _controller.length == 0)return nil;
    @try {
        UIViewController *controller = [[NSClassFromString(_controller) alloc] init];
        if(!controller){
            NSLog(@"反射控制器[%@]失败!", _controller);
            return nil;
        }
        UIImage *imgNormal, *imgHighlight;
        //普通图片
        if(_imgNormalName && _imgNormalName.length > 0){
            @try {
                imgNormal = [UIImage imageNamed:_imgNormalName];
            }
            @catch (NSException *exception) {
                NSLog(@"加载图片[%@]发生异常:%@", _imgNormalName, exception);
            }
        }
        //高亮图片
        if(_imgHighlightName && _imgHighlightName.length > 0){
            @try {
                imgHighlight = [UIImage imageNamed:_imgHighlightName];
            }
            @catch (NSException *exception) {
                NSLog(@"加载图片[%@]发生异常:%@", _imgHighlightName, exception);
            }
        }
        //向导控制器
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:controller];
        //设置标题
        controller.title = _name;
        //设置TabBar图标
        //controller.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:_order];
        if(imgNormal && imgHighlight){
            controller.tabBarItem = [[UITabBarItem alloc]initWithTitle:_name image:imgNormal selectedImage:imgHighlight];
        }
        //NSString *title = (imgNormal || imgHighlight) ? nil : _name;
        
        return navController;
    }
    @catch (NSException *exception) {
        NSLog(@"初始化底部菜单发生异常:%@", exception);
    }
    return nil;
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    return @{__kBottomMenuModel_keys_name:(_name ? _name : @""),
             __kBottomMenuModel_keys_controller:(_controller ? _controller : @""),
             __kBottomMenuModel_keys_imgNormalName:(_imgNormalName ? _imgNormalName : @""),
             __kBottomMenuModel_keys_imgHighlightName:(_imgHighlightName ? _imgHighlightName : @""),
             __kBottomMenuModel_keys_status:[NSNumber numberWithBool:_status],
             __kBottomMenuModel_keys_order:[NSNumber numberWithInteger:_order]};
}

#pragma mark 从本地中加载菜单
+(NSArray *)menusFromLocal{
    NSString *path = [[NSBundle mainBundle] pathForResource:__kBottomMenuModel_menuFileName
                                                     ofType:__kBottomMenuModel_menuFileTypeName];
    NSLog(@"将本地资源[%@]加载底部菜单定义文件...", path);
    NSArray *menuArrays = [NSArray arrayWithContentsOfFile:path];
    if(!menuArrays || menuArrays.count == 0){
        NSLog(@"没有读取到NSArray数据...");
        return nil;
    }
    //底部菜单数组
    NSMutableArray *menus = [NSMutableArray arrayWithCapacity:menuArrays.count];
    for(NSDictionary *dict in menuArrays){
        if(!dict || dict.count == 0) continue;
        BottomMenuModel *menuModel = [[BottomMenuModel alloc]initWithDict: dict];
        if(!menuModel || !menuModel.status) continue;
        [menus addObject:menuModel];
    }
    //排序
    if(menus.count > 1){
        NSLog(@"开始[%d]排序...", (int)menus.count);
        [menus sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BottomMenuModel *menuModel1 = obj1;
            BottomMenuModel *menuModel2 = obj2;
            if(menuModel1 && menuModel2){
                return menuModel1.order - menuModel2.order;
            }
            return 0;
        }];
    }
    //
    return (menus.count > 0) ? [menus copy] : nil;
}
@end
