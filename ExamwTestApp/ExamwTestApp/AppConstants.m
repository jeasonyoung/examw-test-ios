//
//  AppConstants.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "AppConstants.h"

//应用静态常量实现
@implementation AppConstants

#pragma mark 全局列表字体
+(UIFont *)globalListFont{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

#pragma mark 全局列表二级字体
+(UIFont *)globalListSubFont{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

#pragma mark 全局列表三级字体
+(UIFont *)globalListThirdFont{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

#pragma mark 试卷试题字体
+(UIFont *)globalPaperItemFont{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

#pragma mark 全局行距
+(CGFloat)globalLineSpacing{
    return 10.0f;
}

#pragma mark 全局行高
+(CGFloat)globalLineHeight{
    return 10.0f;
}
@end
