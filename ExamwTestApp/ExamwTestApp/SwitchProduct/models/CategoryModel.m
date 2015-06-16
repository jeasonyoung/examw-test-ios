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

#define __kCategoryModel_localFileName @"CategoriesLocalData_%@.plist"//本地保存文件名
//考试分类模型实现
@interface CategoryModel (){
}
@end
//考试分类模型实现
@implementation CategoryModel
#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && (dict.count > 0)){
        NSArray *keys = dict.allKeys;
        //分类ID
        if([keys containsObject:__kCategoryModel_keys_id]){
            id value = [dict objectForKey:__kCategoryModel_keys_id];
            _Id = (value == [NSNull null] ? @"" : value);
        }
        //分类代码
        if([keys containsObject:__kCategoryModel_keys_code]){
            id value = [dict objectForKey:__kCategoryModel_keys_code];
            _code = (value == [NSNull null] ? @"" : value);
        }
        //分类名称
        if([keys containsObject:__kCategoryModel_keys_name]){
            id value = [dict objectForKey:__kCategoryModel_keys_name];
            _name = (value == [NSNull null] ? @"" : value);
        }
        //分类EN简称
        if([keys containsObject:__kCategoryModel_keys_abbr]){
            id value = [dict objectForKey:__kCategoryModel_keys_abbr];
            _abbr = (value == [NSNull null] ? @"" : value);
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
    NSMutableArray *examArrays = [NSMutableArray arrayWithCapacity:(_exams ? _exams.count : 0)];
    if(_exams && _exams.count > 0){
        for(ExamModel *exam in _exams){
            if(!exam) continue;
            NSDictionary *dict = [exam serialize];
            if(!dict || dict.count == 0) continue;
            [examArrays addObject:dict];
        }
    }
    //
    return  @{
              __kCategoryModel_keys_id:(_Id ? _Id : @""),
              __kCategoryModel_keys_code:(_code ? _code : @0),
              __kCategoryModel_keys_name:(_name ? _name : @""),
              __kCategoryModel_keys_abbr:(_abbr ? _abbr : @""),
              __kCategoryModel_keys_exams:examArrays
              };
}

#pragma mark 从本地文件中加载数据
+(NSArray *)categoriesFromLocal{
    NSString *path = [self loadLocalPath];
    NSLog(@"将从文件中加载离线数据:%@",path);
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
                return [self categoriesFromJSON:arrays];
            }
        }
    }
    return nil;
}

//获取本地存储路径
+(NSString *)loadLocalPath{
    //初始化日期格式化
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dtCurrent = [dateFormat stringFromDate:[NSDate date]];
    //文件名
    NSString *fileName = [NSString stringWithFormat:__kCategoryModel_localFileName,dtCurrent];
    //根路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //存储路径
    return [doc stringByAppendingPathComponent:fileName];
}

#pragma mark 将JSON数组转化为考试分类数据模型数组
+(NSArray *)categoriesFromJSON:(NSArray *)arrays{
    NSLog(@"将JSON数组转化为考试分类数据模型数组...");
    if(!arrays || arrays.count == 0)return nil;
    NSMutableArray *categoriesArrays = [NSMutableArray arrayWithCapacity:arrays.count];
    for(NSDictionary *dict in arrays){
        if(dict && dict.count > 0){
            CategoryModel *cm = [[CategoryModel alloc]initWithDict:dict];
            if(cm && cm.exams && cm.exams.count > 0){
                [categoriesArrays addObject:cm];
            }
        }
    }
    return categoriesArrays;
}
#pragma mark 保存到本地文件
+(BOOL)saveLocalWithArrays:(NSArray *)categories{
    NSLog(@"开始序列化后保存到本地...");
    BOOL result = NO;
    if(categories && categories.count > 0){
        //序列化
        NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:categories.count];
        for(CategoryModel *cm in categories){
            if(!cm)continue;
            NSDictionary *dict = [cm serialize];
            if(!dict || dict.count == 0) continue;
            [arrays addObject:dict];
        }
        //检测是否能序列化
        if(![NSJSONSerialization isValidJSONObject:arrays]){
            NSLog(@"不能被序列化!>>>%@",arrays);
            return result;
        }
        NSError *err;
        NSData *data = [NSJSONSerialization dataWithJSONObject:arrays options:NSJSONWritingPrettyPrinted error:&err];
        if(err){
            NSLog(@"序列化考试分类时异常 %@",err);
        }else{
            //本地存储根路径
            NSString *path = [self loadLocalPath];
            result = [data writeToFile:path atomically:YES];
            NSLog(@"保存到本地[status:%d]路径:%@",result,path);
        }
    }
    return result;
}
@end
