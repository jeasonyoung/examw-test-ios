//
//  PaperItemTitleModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemTitleModel.h"
#import "PaperItemModel.h"
#import "AppConstants.h"
#import "SDWebImageManager.h"
//试题标题数据模型实现
@interface PaperItemTitleModel (){
    NSRegularExpression *_imgRegularExpression;
    NSMutableArray *_imgPathArrays;
}
@end
//试题标题数据模型实现
@implementation PaperItemTitleModel

#pragma mark 初始化
-(instancetype)initWithItemModel:(PaperItemModel *)itemModel{
    if((self = [super init]) && itemModel){
        _imgPathArrays = [NSMutableArray array];
        _Id = itemModel.itemId;
        _itemType = itemModel.itemType;
        _order = itemModel.order;
        self.content = itemModel.itemContent;
    }
    return self;
}

#pragma 设置内容
-(void)setContent:(NSString *)content{
    if(content && content.length > 0){
        _content = [self findAndReplaceImgPathWithContent:content];
    }else{
        _content = content;
    }
    _images = (_imgPathArrays ? [_imgPathArrays copy] : @[]);
}

//查找并替换Image路径
-(NSString *)findAndReplaceImgPathWithContent:(NSString *)content{
    NSLog(@"开始内容查找并替换img路径...");
    //初始化正则表达式
    if(!_imgRegularExpression){
        _imgRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(<img.+?/>)"
                                                                     options:NSRegularExpressionCaseInsensitive
                                                                       error:nil];
    }
    NSArray *imgResuts = [_imgRegularExpression matchesInString:content
                                                   options:NSMatchingWithTransparentBounds
                                                     range:NSMakeRange(0, content.length)];
    if(imgResuts && imgResuts.count > 0){
        NSMutableString *resultContent = [NSMutableString stringWithString:content];
        NSLog(@"匹配的img结果:%@",imgResuts);
        
        for(NSTextCheckingResult *result in imgResuts){
            NSRange range = result.range;
            NSString *imgContent = [content substringWithRange:range];
            imgContent = [self replaceImgUrlContent:imgContent];
            //替换
            [resultContent replaceCharactersInRange:range withString:imgContent];
        }
        return resultContent;
    }
    return content;
}

//用正则表达式替换
-(NSString *)replaceImgUrlContent:(NSString *)content{
    if(content && content.length > 0){
        NSRange range = [content rangeOfString:@"src=\"(.+?)\"" options:NSRegularExpressionSearch];
        if(range.location != NSNotFound){
            NSString *imgUrl = [content substringWithRange:range];
            imgUrl = [imgUrl substringFromIndex:5];
            imgUrl = [imgUrl substringToIndex:(imgUrl.length - 1)];
            if(![imgUrl hasPrefix:@"http"]){
                imgUrl = [_kAPP_API_HOST stringByAppendingString:imgUrl];
            }
            if(imgUrl && imgUrl.length > 0){
                //下载图片
                [self downloadImageWithUrl:imgUrl];
                //添加到集合
                [_imgPathArrays addObject:imgUrl];
            }
            return @"";
        }
    }
    return content;
}

//下载图片
-(void)downloadImageWithUrl:(NSString *)url{
    if(!url || url.length == 0)return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程下载图片:%@...", url);
        //图片管理
        SDWebImageManager *imgManager = [SDWebImageManager sharedManager];
        //下载完成处理
        void(^downloadCompleted)(UIImage *, NSError *, SDImageCacheType, BOOL, NSURL *) = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
            if(finished && image){
                NSLog(@"完成图片下载:%@",imageURL);
                [imgManager saveImageToCache:image forURL:imageURL];
            }
        };
        //开始下载图片
        [imgManager downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:nil completed:downloadCompleted];
    });
}
@end