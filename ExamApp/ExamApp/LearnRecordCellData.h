//
//  LearnRecordCellData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LearnRecord;
//学习记录数据列表模型
@interface LearnRecordCellData : NSObject
//图标坐标
@property(nonatomic,assign,readonly)CGRect imgFrame;

//标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;
//标题
@property(nonatomic,copy,readonly)NSString *title;
//标题字体
@property(nonatomic,copy,readonly)UIFont *titleFont;

//用时Frame
@property(nonatomic,assign,readonly)CGRect useTimeFrame;
//用时
@property(nonatomic,copy,readonly)NSString *useTime;
//用时字体
@property(nonatomic,copy,readonly)UIFont *useTimeFont;

//得分Frame
@property(nonatomic,assign,readonly)CGRect scoreFrame;
//得分
@property(nonatomic,copy,readonly)NSString *score;
//得分字体
@property(nonatomic,copy,readonly)UIFont *scoreFont;

//最后时间Frame
@property(nonatomic,assign,readonly)CGRect lastTimeFrame;
//最后时间
@property(nonatomic,copy,readonly)NSString *lastTime;
//最后时间字体
@property(nonatomic,copy,readonly)UIFont *lastTimeFont;

//行高
@property(nonatomic,assign,readonly)CGFloat rowHeight;

//学习记录数据
@property(nonatomic,copy)LearnRecord *record;
@end
