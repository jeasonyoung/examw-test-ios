//
//  PaperItemModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemModel.h"
#import "AppConstants.h"
#import "SDWebImageManager.h"

#define __kPaperItemModel_keys_id @"id"//试题ID
#define __kPaperItemModel_keys_type @"type"//试题类型
#define __kPaperItemModel_keys_content @"content"//试题内容
#define __kPaperItemModel_keys_answer @"answer"//试题答案
#define __kPaperItemModel_keys_analysis @"analysis"//试题解析
#define __kPaperItemModel_keys_level @"level"//试题难度值
#define __kPaperItemModel_keys_order @"orderNo"//试题排序号
#define __kPaperItemModel_keys_count @"count"//包含试题总数
#define __kPaperItemModel_keys_children @"children"//子试题集合

#define __kPaperItemModel_itemTypes @[@"单选",@"多选",@"不定向选择",@"判断题",@"问答题",@"共享题干题",@"共享答案题"]//试题类型
#define __kPaperItemModel_judgeAnswers @[@"错误",@"正确"]//判断题答案名称

//试题数据模型实现
@implementation PaperItemModel

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        _index = 0;
        NSLog(@"试题反序列化初始化...");
        NSArray *keys = dict.allKeys;
        //试题ID
        if([keys containsObject:__kPaperItemModel_keys_id]){
            id value = [dict objectForKey:__kPaperItemModel_keys_id];
            _itemId = (value == [NSNull null] ? @"" : value);
        }
        //试题类型
        if([keys containsObject:__kPaperItemModel_keys_type]){
            id value = [dict objectForKey:__kPaperItemModel_keys_type];
            _itemType = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //试题内容
        if([keys containsObject:__kPaperItemModel_keys_content]){
            id value = [dict objectForKey:__kPaperItemModel_keys_content];
            NSString *content = (value == [NSNull null] ? @"" : value);
            //图片处理
            NSMutableArray *imgUrlArrays = [NSMutableArray array];
            _itemContent = [self findAndReplaceImgPathsWithText:content imgUrlHandler:^(NSString *imgUrl) {
                [imgUrlArrays addObject:imgUrl];
            }];
            _itemContentImgUrls = (imgUrlArrays.count > 0 ? [imgUrlArrays copy] : nil);
            //html标签处理
            _itemContent = [self findReplaceHtmlWithContent:_itemContent];
        }
        //试题答案
        if([keys containsObject:__kPaperItemModel_keys_answer]){
            id value = [dict objectForKey:__kPaperItemModel_keys_answer];
            _itemAnswer = (value == [NSNull null] ? @"" : value);
        }
        //试题解析
        if([keys containsObject:__kPaperItemModel_keys_analysis]){
            id value = [dict objectForKey:__kPaperItemModel_keys_analysis];
            NSString *analysis = (value == [NSNull null] ? @"" : value);
            //图片处理
            NSMutableArray *imgUrlArrays = [NSMutableArray array];
            _itemAnalysis = [self findAndReplaceImgPathsWithText:analysis imgUrlHandler:^(NSString *imgUrl) {
                [imgUrlArrays addObject:imgUrl];
            }];
            _itemAnalysisImgUrls = (imgUrlArrays.count > 0 ? [imgUrlArrays copy] : nil);
            //html标签处理
            _itemAnalysis = [self findReplaceHtmlWithContent:_itemAnalysis];
        }
        //试题难度值
        if([keys containsObject:__kPaperItemModel_keys_level]){
            id value = [dict objectForKey:__kPaperItemModel_keys_level];
            _itemLevel = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //试题排序号
        if([keys containsObject:__kPaperItemModel_keys_order]){
            id value = [dict objectForKey:__kPaperItemModel_keys_order];
            _order = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //包含试题总数
        if([keys containsObject:__kPaperItemModel_keys_count]){
            id value = [dict objectForKey:__kPaperItemModel_keys_count];
            _count = (value == [NSNull null] ? 0 : [(NSNumber *)value integerValue]);
        }
        //子试题集合
        if([keys containsObject:__kPaperItemModel_keys_children]){
            id value = [dict objectForKey:__kPaperItemModel_keys_children];
            if((value != [NSNull null]) && [value isKindOfClass:[NSArray class]]){
                _children = [self deserializeWithJSONArrays:((NSArray *)value)];
            }
        }
    }
    return self;
}

#pragma mark 将JSON反序列化处理
-(instancetype)initWithJSON:(NSString *)json{
    NSLog(@"将JSON反序列化=>%@",json);
    if(json && json.length > 0){
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
        if(data && data.length > 0){
            //JSON处理
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            if(err){
                NSLog(@"试题数据模型JSON反序列化配置错误: %@",err);
            }else{
                return [self initWithDict:dict];
            }
        }
    }
    return nil;
}

//查找替换HTML
-(NSString *)findReplaceHtmlWithContent:(NSString *)content{
    if(!content || content.length == 0)return content;
    //HTMl替换
    content = [self findReplaceWithContent:content andHtmlTagRegex:@"<[^>]*>" replace:@""];
    //&nbsp;替换为空格
    content = [self findReplaceWithContent:content andHtmlTagRegex:@"&nbsp;" replace:@" "];
    return content;
}

-(NSString *)findReplaceWithContent:(NSString *)content andHtmlTagRegex:(NSString *)tagRegex replace:(NSString *)replace{
    if(!content || content.length == 0)return content;
    NSMutableString *resultText = [NSMutableString stringWithString:content];
    NSRange range = [resultText rangeOfString:tagRegex options:NSRegularExpressionSearch];
    if(range.location == NSNotFound){
        return resultText;
    }
    //HTMl替换
    NSLog(@"替换[%@]=>[%@]", [resultText substringWithRange:range], replace);
    [resultText replaceCharactersInRange:range withString:replace];
    //递归替换
    return [self findReplaceHtmlWithContent:resultText];
}


//查找并替换图片路径
-(NSString *)findAndReplaceImgPathsWithText:(NSString *)text imgUrlHandler:(void(^)(NSString *))handler{
    if(text && text.length > 0){
        NSRegularExpression *imgRegexExpression = [[NSRegularExpression alloc] initWithPattern:@"(<[img|IMG].+?[/]?>)"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
        NSArray *imgResults = [imgRegexExpression matchesInString:text options:NSMatchingWithTransparentBounds range:NSMakeRange(0, text.length)];
        if(imgResults && imgResults.count > 0){
            NSLog(@"匹配的ImgUrl结果:%@", imgResults);
            NSMutableString *resultText = [NSMutableString stringWithString:text];
            for(NSTextCheckingResult * result in imgResults){
                NSRange range = result.range;
                if(range.location == NSNotFound) continue;
                //img标签数据
                NSString *imgContent = [text substringWithRange:range];
                if(imgContent && imgContent.length > 0){
                    NSRange srcRange = [imgContent rangeOfString:@"[src|SRC]=\"(.+?)\"" options:NSRegularExpressionSearch];
                    if(srcRange.location == NSNotFound) continue;
                    NSString *imgUrl = [imgContent substringWithRange:srcRange];
                    NSRange r = [imgUrl rangeOfString:@"="];
                    if(r.location != NSNotFound){
                        imgUrl = [imgUrl substringFromIndex:(r.location + 2)];
                    }else{
                        imgUrl = [imgUrl substringFromIndex:5];
                    }
                    imgUrl = [imgUrl substringToIndex:(imgUrl.length - 1)];
                    if([imgUrl hasPrefix:@"/"]){
                        imgUrl = [_kAPP_API_HOST stringByAppendingString:imgUrl];
                    }
                    //下载图片
                    [self downloadImgWithUrl:imgUrl];
                    //替换为空
                    [resultText replaceCharactersInRange:range withString:@""];
                    //block处理
                    if(handler){
                        handler(imgUrl);
                    }
                }
            }
            return resultText;
        }
    }
    return text;
}

//下载图片
-(void)downloadImgWithUrl:(NSString *)url{
    if(!url || url.length == 0)return;
    //异步线程下载图片
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSURL *imgURL = [NSURL URLWithString:url];
            //图片管理
            SDWebImageManager *imgMgr = [SDWebImageManager sharedManager];
            //检查是否下载过有缓存
            BOOL exists = [imgMgr cachedImageExistsForURL:imgURL];
            if(exists){
                NSLog(@"图片[%@]已下载过有缓存，无须下载...", url);
                return;
            }
            //准备图片下载
            NSLog(@"开始图片[%@]下载...", url);
            //下载完成处理块
            void(^downloadCompleted)(UIImage *, NSError *, SDImageCacheType, BOOL, NSURL *) = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                if(finished && image){
                    //异步线程保存图片
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSLog(@"完成图片[%@]下载并缓存...",imageURL);
                        [imgMgr saveImageToCache:image forURL:imgURL];
                    });
                }
            };
            //开始下载图片
            [imgMgr downloadImageWithURL:imgURL options:0 progress:nil completed:downloadCompleted];
        }
        @catch (NSException *exception) {
            NSLog(@"下载图片[%@]发生异常:%@", url, exception);
        }
    });
}

#pragma mark 从JSON的Arrays的反序列化为对象数组
-(NSArray *)deserializeWithJSONArrays:(NSArray *)arrays{
    if(arrays && arrays.count > 0){
        NSLog(@"试题从JSONArrays的反序列化为对象数组...");
        NSMutableArray *itemArrays = [NSMutableArray arrayWithCapacity:arrays.count];
        for(NSDictionary *dict in arrays){
            if(!dict || dict.count == 0) continue;
            PaperItemModel *model = [[PaperItemModel alloc]initWithDict:dict];
            if(model){
                [itemArrays addObject:model];
            }
        }
        return (itemArrays.count == 0) ? nil : [itemArrays copy];
    }
    return nil;
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    NSLog(@"试题序列化...");
    NSMutableArray *childArrays = nil;
    if(_children && _children.count > 0){
        childArrays = [NSMutableArray arrayWithCapacity:_children.count];
        for(PaperItemModel *model in _children){
            if(!model)continue;
            NSDictionary *dict = [model serialize];
            if(dict && dict.count > 0){
                [childArrays addObject:dict];
            }
        }
    }
    //序列化
    return @{__kPaperItemModel_keys_id : (_itemId ? _itemId : @""),
             __kPaperItemModel_keys_type : [NSNumber numberWithInteger:_itemType],
             __kPaperItemModel_keys_content : (_itemContent ? _itemContent : @""),
             __kPaperItemModel_keys_answer : (_itemAnswer ? _itemAnswer : @""),
             __kPaperItemModel_keys_analysis : (_itemAnalysis ? _itemAnalysis : @""),
             __kPaperItemModel_keys_level : [NSNumber numberWithInteger:_itemLevel],
             __kPaperItemModel_keys_order : [NSNumber numberWithInteger:_order],
             __kPaperItemModel_keys_count : [NSNumber numberWithInteger:_count],
             __kPaperItemModel_keys_children : (childArrays ? [childArrays copy] : @[])};
}

#pragma mark 序列化为JSON字符串
-(NSString *)serializeJSON{
    NSLog(@"准备将试题序列化为JSON字符串...");
    NSDictionary *dict = [self serialize];
    if(dict && [NSJSONSerialization isValidJSONObject:dict]){
        NSError *err;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
        if(err){
            NSLog(@"试题转为JSON错误=>%@",err);
            return nil;
        }
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark 题型名称
+(NSString *)nameWithItemType:(NSUInteger)itemType{
    if(itemType > 0 && itemType <= __kPaperItemModel_itemTypes.count){
        NSString *name = [__kPaperItemModel_itemTypes objectAtIndex:(itemType - 1)];
        NSLog(@"加载题型[%d]的名称[%@]...", (int)itemType, name);
        return name;
    }
    return nil;
}

#pragma mark 判断题答案名称
+(NSString *)nameWithItemJudgeAnswer:(NSUInteger)itemJudgeAnswer{
    if(itemJudgeAnswer < __kPaperItemModel_judgeAnswers.count){
        NSString *name = [__kPaperItemModel_judgeAnswers objectAtIndex:itemJudgeAnswer];
        NSLog(@"加载判断题答案[%d]的名称[%@]...", (int)itemJudgeAnswer, name);
        return name;
    }
    return nil;
}
@end
