//
//  TitleTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "TitleTableViewCell.h"
#import "TitleModelCellFrame.h"
//标题内容Cell成员变量
@interface TitleTableViewCell (){
    UILabel *_lbTitle;
}
@end
//标题内容Cell实现
@implementation TitleTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //标题
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.numberOfLines = 0;
        
        //添加到容器
        [self.contentView addSubview:_lbTitle];
    }
    return self;
}

#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(TitleModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    
    _lbTitle.font = cellFrame.titleFont;
    _lbTitle.frame = cellFrame.titleFrame;
    _lbTitle.text = cellFrame.title;
}

@end
