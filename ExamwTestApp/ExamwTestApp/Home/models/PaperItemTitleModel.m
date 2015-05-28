//
//  PaperItemTitleModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemTitleModel.h"
#import "PaperItemModel.h"

//试题标题数据模型实现
@implementation PaperItemTitleModel

#pragma mark 初始化
-(instancetype)initWithItemModel:(PaperItemModel *)itemModel{
    if((self = [super init]) && itemModel){
        _Id = itemModel.itemId;
        _itemType = itemModel.itemType;
        _order = itemModel.order;
        _content = itemModel.itemContent;
    }
    return self;
}

@end