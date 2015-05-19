//
//  ModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//数据模型Cell Frame
@protocol DataModelCellFrame <NSObject>
//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;
@end
