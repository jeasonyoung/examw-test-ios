//
//  PaperItemTitleTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemTitleTableViewCell.h"
#import "AppConstants.h"
#import "PaperItemTitleModelCellFrame.h"

#import "TTTAttributedLabel.h"

//试题标题Cell成员变量
@interface PaperItemTitleTableViewCell (){
    //UILabel *_lbTitle;
    TTTAttributedLabel *_lbTitle;
}

@end
//试题标题Cell实现
@implementation PaperItemTitleTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //标题
        _lbTitle = [[TTTAttributedLabel alloc] init];
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.numberOfLines = 0;
        _lbTitle.lineBreakMode = NSLineBreakByWordWrapping;
        _lbTitle.lineSpacing = [AppConstants globalLineSpacing];
        _lbTitle.minimumLineHeight = [AppConstants globalLineHeight];
        //添加到容器
        [self.contentView addSubview:_lbTitle];
    }
    return self;
}


#pragma mark 加载数据模型Cell Frame
-(void)loadModelCellFrame:(PaperItemTitleModelCellFrame *)cellFrame{
    NSLog(@"加载试题标题数据模型CellFrame:%@...",cellFrame);
    if(!cellFrame)return;
    //标题
    _lbTitle.attributedText = cellFrame.title;
    _lbTitle.frame = cellFrame.titleFrame;
    
}
@end
