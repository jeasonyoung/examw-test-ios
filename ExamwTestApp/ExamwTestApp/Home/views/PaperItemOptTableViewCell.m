//
//  PaperItemOptTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemOptTableViewCell.h"
#import "PaperItemOptModelCellFrame.h"
//试题选项Cell成员变量
@interface PaperItemOptTableViewCell (){
    UIImageView *_iconView;
    UILabel *_lbContent;
}
@end
//试题选项Cell实现
@implementation PaperItemOptTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //图标
        _iconView = [[UIImageView alloc] init];
        //内容
        _lbContent = [[UILabel alloc]  init];
        _lbContent.textAlignment = NSTextAlignmentLeft;
        _lbContent.numberOfLines = 0;
        
        //添加到容器
        [self.contentView addSubview:_iconView];
        [self.contentView addSubview:_lbContent];
    }
    return self;
}

#pragma mark 加载数据模型Cell Frame
-(void)loadModelCellFrame:(PaperItemOptModelCellFrame *)cellFrame{
    NSLog(@"加载试题选项数据模型Cell Frame:%@...", cellFrame);
    if(!cellFrame)return;
    //图标
    _iconView.image = cellFrame.icon;
    _iconView.frame = cellFrame.iconFrame;
    //内容
    _lbContent.attributedText = cellFrame.content;
    _lbContent.frame = cellFrame.contentFrame;
    
}
@end
