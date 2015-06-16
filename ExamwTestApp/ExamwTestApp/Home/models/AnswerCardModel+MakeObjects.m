//
//  AnswerCardModel+MakeObjects.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardModel+MakeObjects.h"

#import "PaperService.h"
#import "PaperItemModel.h"

//答题卡数据模型扩展实现
@implementation AnswerCardModel (MakeObjects)
#pragma mark 加载试题状态
-(void)loadItemStatusWithObjs:(NSArray *)objs{
    PaperService *paperService = [objs objectAtIndex:0];
    NSString *paperRecordId = [objs objectAtIndex:1];
    NSArray *itemsArrays = [objs objectAtIndex:2];
    
    if(paperService && paperRecordId && itemsArrays && itemsArrays.count > self.order){
        PaperItemModel *itemModel = [itemsArrays objectAtIndex:self.order];
        if(!itemModel)return;
        NSLog(@"加载试题[(%d)%@$%d]做题状态...", (int)(self.order + 1),itemModel.itemId, (int)itemModel.index);
        self.status = [paperService exitRecordWithPaperRecordId:paperRecordId itemModel:itemModel];
    }
}
@end
