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
typedef NS_ENUM(NSInteger, ItemOptionViewType){
    //单选
    ItemOptionViewTypeSingle = 0,
    //多选
    ItemOptionViewTypeMulty,
    //单选答对
    ItemOptionViewTypeSingleRight,
    //单选答错
    ItemOptionViewTypeSingleError,
    //多选答对
    ItemOptionViewTypeMultyRight,
    //多选答错
    ItemOptionViewTypeMultyError
};
//选项组件
@interface ItemOptionView : UIControl<NSCoding>
//选项值
@property(nonatomic,copy)NSString *optCode;
//选项显示内容
@property(nonatomic,copy)NSString *optText;
//选项类型
@property(nonatomic,assign)ItemOptionViewType type;
//选项是否选中
@property(nonatomic,assign,getter=isOptSelected)BOOL optSelected;
//初始化
-(instancetype)initWithFrame:(CGRect)frame;
//加载数据
-(void)loadDataWithType:(ItemOptionViewType)type OptionCode:(NSString *)code OptionText:(NSString *)text;
//加载数据
-(void)loadData;
@end

//选项组合委托
@protocol ItemOptionGroupDelegate <NSObject>
//选项选中事件
-(void)optionSelected:(ItemOptionView *)sender;
@end
//选项组合
@interface ItemOptionGroupView : UIView
//委托
@property(nonatomic,assign)id<ItemOptionGroupDelegate> delegate;
//初始化
-(instancetype)initWithFrame:(CGRect)frame;
//加载数据
-(void)loadDataWithType:(ItemOptionViewType)type andOptions:(NSArray *)options;
//清空
-(void)clean;
@end

