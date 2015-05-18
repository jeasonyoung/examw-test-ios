//
//  Category.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/15.
//  Copyright (c) 2015年 All rights reserved.
//

#import "CategoryModel.h"
#import "ExamModel.h"

#define __kCategoryModel_keys_id @"id"//分类ID
#define __kCategoryModel_keys_code @"code"//分类代码
#define __kCategoryModel_keys_name @"name"//分类名称
#define __kCategoryModel_keys_abbr @"abbr"//分类EN简称
#define __kCategoryModel_keys_exams @"exams"//考试集合

#define __kCategoryModel_localFileName @"CategoriesLocalData.plist"//本地保存文件名
//考试分类模型实现
@implementation CategoryModel
#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && (dict.count > 0)){
        NSArray *keys = dict.allKeys;
        //分类ID
        if([keys containsObject:__kCategoryModel_keys_id]){
            _Id = [dict objectForKey:__kCategoryModel_keys_id];
        }
        //分类代码
        if([keys containsObject:__kCategoryModel_keys_code]){
            _code = [dict objectForKey:__kCategoryModel_keys_code];
        }
        //分类名称
        if([keys containsObject:__kCategoryModel_keys_name]){
            _name = [dict objectForKey:__kCategoryModel_keys_name];
        }
        //分类EN简称
        if([keys containsObject:__kCategoryModel_keys_abbr]){
            _abbr = [dict objectForKey:__kCategoryModel_keys_abbr];
        }
        //考试集合
        if([keys containsObject:__kCategoryModel_keys_exams]){
            NSArray *arrays = [dict objectForKey:__kCategoryModel_keys_exams];
            if(arrays && arrays.count > 0){
                NSMutableArray *examsArrays = [NSMutableArray arrayWithCapacity:arrays.count];
                for(NSDictionary *dict in arrays){
                    if(dict && dict.count > 0){
                        ExamModel *em = [[ExamModel alloc]initWithDict:dict];
                        if(em){
                            [examsArrays addObject:em];
                        }
                    }
                }
                if(examsArrays && examsArrays.count > 0){
                    _exams = examsArrays;
                }
            }
        }
        NSLog(@"完成反序列化考试分类:%@",_name);
    }
    return self;
}
#pragma mark 序列化
-(NSDictionary *)serialize{
    NSLog(@"序列化考试类别:%@",_name);
    return  @{
              __kCategoryModel_keys_id:_Id,
              __kCategoryModel_keys_code:_code,
              __kCategoryModel_keys_name:_name,
              __kCategoryModel_keys_abbr:_abbr,
              __kCategoryModel_keys_exams:_exams
              };
}
#pragma mark 从本地文件中加载数据
+(NSArray *)categoriesFromLocal{
    //本地存储根路径
    NSString *root = [[NSBundle mainBundle] resourcePath];
    NSString *path = [root stringByAppendingPathComponent:__kCategoryModel_localFileName];
    //文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if([fileMgr fileExistsAtPath:path]){
        NSData *data = [NSData dataWithContentsOfFile:path];
        if(!data){
            NSLog(@"加载文件[%@]失败!",path);
        }else{
            //JSON处理
            NSError *err;
            NSArray *arrays = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            if(err){
                NSLog(@"考试分类反序列化失败:%@",err);
            }else if(arrays && arrays.count > 0){
                NSLog(@"本地考试分类数据加载路径:%@", path);
                NSMutableArray *categoryArrays = [NSMutableArray arrayWithCapacity:arrays.count];
                for(NSDictionary *dict in arrays){
                    if(dict && dict.count > 0){
                        CategoryModel *cm = [[CategoryModel alloc]initWithDict:dict];
                        if(cm){
                            [categoryArrays addObject:cm];
                        }
                    }
                }
                return categoryArrays;
            }
        }
    }
    return nil;
}
#pragma mark 保存到本地文件
+(BOOL)saveLocalWithArrays:(NSArray *)categories{
    BOOL result = NO;
    if(categories && categories.count > 0){
        NSError *err;
        NSData *data = [NSJSONSerialization dataWithJSONObject:categories options:NSJSONWritingPrettyPrinted error:&err];
        if(err){
            NSLog(@"序列化考试分类时异常 %@",err);
        }else{
            //本地存储根路径
            NSString *root = [[NSBundle mainBundle] resourcePath];
            NSString *path = [root stringByAppendingPathComponent:__kCategoryModel_localFileName];
            result = [data writeToFile:path atomically:YES];
            NSLog(@"保存到本地[status:%d]路径:%@",result,path);
        }
    }
    return result;
}
@end
