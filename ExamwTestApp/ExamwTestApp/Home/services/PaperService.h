//
//  PaperService.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//试卷服务接口
@interface PaperService : NSObject

//分页数据
@property(nonatomic,assign,readonly)NSUInteger pageOfRows;

//按试卷类型分页查找试卷信息数据
-(NSArray *)findPapersInfoWithPaperType:(NSUInteger)paperType andPageIndex:(NSUInteger)pageIndex;
@end
