//
//  AnswerCardSectionCollectionReusableView.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AnswerCardSectionModelCellFrame;
//答题卡Header
@interface AnswerCardSectionCollectionReusableView : UICollectionReusableView

//加载Cell Frame
-(void)loadModelCellFrame:(AnswerCardSectionModelCellFrame *)cellFrame;
@end
