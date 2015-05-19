//
//  ExamTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ExamTableViewCell.h"

//考试TableViewCell成员变量
@interface ExamTableViewCell (){
    UILabel *_lbName;
}
@end

//考试TableViewCell实现
@implementation ExamTableViewCell
#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _lbName = [[UILabel alloc]init];
        _lbName.textAlignment = NSTextAlignmentLeft;
        _lbName.numberOfLines = 0;
        [self.contentView addSubview:_lbName];
    }
    return self;
}

#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(ExamModelCellFrame *)cellFrame{
    NSLog(@"加载数据模型:%@",cellFrame);
    if(!cellFrame)return;
    _lbName.text = cellFrame.name;
    _lbName.font = cellFrame.nameFont;
    _lbName.frame = cellFrame.nameFrame;
}


#pragma mark 重载选中
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
