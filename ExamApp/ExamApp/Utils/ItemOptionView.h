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
typedef NS_ENUM(int, ItemOptionViewType){
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
//选项集合类型
typedef NS_ENUM(int, ItemOptionGroupType){
    //单选
    ItemOptionGroupTypeSingle = 0,
    //多选
    ItemOptionGroupTypeMulty
};

@class ItemOptionView;
//选项委托
@protocol ItemOptionViewDelegate <NSObject>
@required
-(void)itemOptionClick:(ItemOptionView *)sender;
@end

//选项组件
@interface ItemOptionView : UIControl<NSCoding>
//委托
@property(nonatomic,assign)id<ItemOptionViewDelegate> delegate;
//选项值
@property(nonatomic,copy,readonly)NSString *optCode;
//选项显示内容
@property(nonatomic,copy,readonly)NSString *optText;
//选项类型
@property(nonatomic,assign,readonly)ItemOptionViewType type;
//选项是否选中
@property(nonatomic,assign,getter=isOptSelected)BOOL optSelected;
//初始化
-(instancetype)initWithFrame:(CGRect)frame;
//加载数据
-(void)loadDataWithType:(ItemOptionViewType)type OptionCode:(NSString *)code OptionText:(NSString *)text;
//加载数据
-(void)loadData;
//改变选项类型
-(void)changeOptionType:(ItemOptionViewType)type;
//清空
-(void)clean;
@end

//选项组合委托
@protocol ItemOptionGroupDelegate <NSObject>
//选项选中事件
-(void)optionSelected:(ItemOptionView *)sender;
@end

//选项集合数据源
@interface ItemOptionGroupSource : NSObject
//是否显示答案
@property(nonatomic,assign,readonly,getter=IsDisplayAnswer)BOOL displayAnswer;
//选项集合类型
@property(nonatomic,assign,readonly)ItemOptionGroupType optGropType;
//选项数据(PaperItem对象数组)
@property(nonatomic,copy,readonly)NSArray *options;
//正确答案
@property(nonatomic,copy,readonly)NSString *answer;
//选中的选项值
@property(nonatomic,copy,readonly)NSString *selectedOptCode;
//初始化
-(void)loadOptions:(NSArray *)options
         GroupType:(ItemOptionGroupType)type
          Selected:(NSString *)optCode
     DisplayAnswer:(BOOL)displayAnswer
            Answer:(NSString *)answer;
//静态初始化
+(instancetype)sourceOptions:(NSArray *)options
                   GroupType:(ItemOptionGroupType)type
                    Selected:(NSString *)optCode
               DisplayAnswer:(BOOL)displayAnswer
                      Answer:(NSString *)answer;
@end

//选项组合
@interface ItemOptionGroupView : UIView
//委托
@property(nonatomic,assign)id<ItemOptionGroupDelegate> delegate;
//初始化
-(instancetype)initWithFrame:(CGRect)frame;
//加载数据
-(void)loadData:(ItemOptionGroupSource *)data;
//是否显示答案
-(void)showDisplayAnswer:(BOOL)displayAnswer;
//清空
-(void)clean;
@end

