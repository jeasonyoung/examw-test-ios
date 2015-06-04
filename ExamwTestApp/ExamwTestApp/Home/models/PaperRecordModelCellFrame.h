//
//  PaperRecordModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

@class PaperRecordModel;
//试卷做题记录数据模型CellFrame
@interface PaperRecordModelCellFrame : NSObject<DataModelCellFrame>

//图片
@property(nonatomic,readonly)UIImage *img;
//图片Frame
@property(nonatomic,assign,readonly)CGRect imgFrame;

//试卷名称
@property(nonatomic,copy,readonly)NSString *paperName;
//试卷名称字体
@property(nonatomic,readonly)UIFont *paperNameFont;
//试卷名称
@property(nonatomic,assign,readonly)CGRect paperNameFrame;

//状态
@property(nonatomic,copy,readonly)NSString *status;
//状态字体
@property(nonatomic,readonly)UIFont *statusFont;
//状态Frame
@property(nonatomic,assign,readonly)CGRect statusFrame;

//得分
@property(nonatomic,copy,readonly)NSString *score;
//得分字体
@property(nonatomic,readonly)UIFont *scoreFont;
//得分Frame
@property(nonatomic,assign,readonly)CGRect scoreFrame;

//正确
@property(nonatomic,copy,readonly)NSString *rights;
//正确字体
@property(nonatomic,readonly)UIFont *rightsFont;
//正确Frame
@property(nonatomic,assign,readonly)CGRect rightsFrame;

//用时
@property(nonatomic,copy,readonly)NSString *useTimes;
//用时字体
@property(nonatomic,readonly)UIFont *useTimesFont;
//用时Frame
@property(nonatomic,assign,readonly)CGRect useTimesFrame;

//时间
@property(nonatomic,copy,readonly)NSString *time;
//时间字体
@property(nonatomic,readonly)UIFont *timeFont;
//时间
@property(nonatomic,assign,readonly)CGRect timeFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//数据模型
@property(nonatomic,copy)PaperRecordModel *model;
@end
