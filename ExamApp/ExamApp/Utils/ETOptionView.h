//
//  ETOptionView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/10.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperReview.h"
//选项类型
typedef NS_ENUM(NSInteger, ETOptionViewType){
    //单选
    ETOptionViewTypeOfSingle = 0,
    //多选
    ETOptionViewTypeOfMulty,
    //单选答对
    ETOptionViewTypeOfSingleRight,
    //单选答错
    ETOptionViewTypeOfSingleError,
    //多选答对
    ETOptionViewTypeOfMultyRight,
    //多选答错
    ETOptionViewTypeOfMultyError
};
//选项组件
@interface ETOptionView : UIControl<NSCoding>
//选项值
@property(nonatomic,copy)NSString *optCode;
//选项显示内容
@property(nonatomic,copy)NSString *optText;
//选项类型
@property(nonatomic,assign)ETOptionViewType type;
//选项是否选中
@property(nonatomic,assign,getter=isOptSelected)BOOL optSelected;
//初始化
-(instancetype)initWithFrame:(CGRect)frame Type:(ETOptionViewType)type OptionCode:(NSString *)code OptionText:(NSString *)text;
@end

//选项组合委托
@protocol ETOptionGroupDelegate <NSObject>
//选项选中事件
-(void)optionSelected:(ETOptionView *)sender;
@end
//选项组合
@interface ETOptionGroupView : UIView
//委托
@property(nonatomic,assign)id<ETOptionGroupDelegate> delegate;
//初始化
-(instancetype)initWithFrame:(CGRect)frame PaperItem:(PaperItem *)item;
@end

