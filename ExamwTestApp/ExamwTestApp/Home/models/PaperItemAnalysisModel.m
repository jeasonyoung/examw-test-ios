//
//  PaperItemAnalysisModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemAnalysisModel.h"

#import "PaperItemModel.h"
//试题答案解析数据模型实现
@implementation PaperItemAnalysisModel

#pragma mark 重载初始化
-(instancetype)initWithItemModel:(PaperItemModel *)itemModel{
    if((self = [super initWithItemModel:itemModel]) && itemModel){
        self.content = itemModel.itemAnalysis;
        self.images = itemModel.itemAnalysisImgUrls;
    }
    return self;
}

@end
