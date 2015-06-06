//
//  MoreMenuModelTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MoreMenuModelTableViewCell.h"
#import "MoreMenuModelCellFrame.h"

//更多菜单数据模型Cell成员变量
@interface MoreMenuModelTableViewCell (){
    UIImageView *_iconView;
    UILabel *_lbtitle;
}
@end
//更多菜单数据模型Cell实现
@implementation MoreMenuModelTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //图标
        _iconView = [[UIImageView alloc] init];
        //标题
        _lbtitle = [[UILabel alloc] init];
        _lbtitle.textAlignment = NSTextAlignmentLeft;
        _lbtitle.numberOfLines = 0;
        //添加到容器
        [self.contentView addSubview:_iconView];
        [self.contentView addSubview:_lbtitle];
    }
    return self;
}

#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(MoreMenuModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    //图标
    if(cellFrame.icon){
        _iconView.image = cellFrame.icon;
    }
    _iconView.frame = cellFrame.iconFrame;
    //标题
    _lbtitle.font = cellFrame.titleFont;
    _lbtitle.frame = cellFrame.titleFrame;
    _lbtitle.text = cellFrame.title;
}

@end
