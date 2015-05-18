//
//  CategoryService.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//产品切换数据服务
@interface SwitchService : NSObject

//加载考试分类数据
-(NSArray *)loadCategoriesWithPageIndex:(NSUInteger)pageIndex;


@end
