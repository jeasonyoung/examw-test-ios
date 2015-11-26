//
//  PaperResultTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperResultTableViewCell.h"
#import "AppConstants.h"
#import "PaperResultModelCellFrame.h"
#import "TTTAttributedLabel.h"
//试卷结果Cell成员变量
@interface PaperResultTableViewCell (){
    //TTTAttributedLabel *_lbTitle,*_lbContent;
    UILabel *_lbContent;
}
@end
//试卷结果Cell实现
@implementation PaperResultTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //内容
        _lbContent = [[UILabel alloc] init];
        _lbContent.textAlignment = NSTextAlignmentLeft;
        _lbContent.lineBreakMode = NSLineBreakByWordWrapping;
        _lbContent.numberOfLines = 0;
        //添加到容器
        [self.contentView addSubview:_lbContent];
        
        
//        //标题
//        _lbTitle = [[TTTAttributedLabel alloc] init];
//        _lbTitle.textAlignment = NSTextAlignmentLeft;
//        _lbTitle.lineBreakMode = NSLineBreakByWordWrapping;
//        _lbTitle.lineSpacing = [AppConstants globalLineSpacing];
//        _lbTitle.minimumLineHeight = [AppConstants globalLineHeight];
//        _lbTitle.numberOfLines = 0;
//        //_lbTitle.attributedText
//        //_lbTitle.backgroundColor = [UIColor redColor];
//        
//        //内容
//        _lbContent = [[TTTAttributedLabel alloc] init];
//        _lbContent.textAlignment = NSTextAlignmentLeft;
//        _lbTitle.lineBreakMode = NSLineBreakByWordWrapping;
//        _lbTitle.lineSpacing = [AppConstants globalLineSpacing];
//        _lbTitle.minimumLineHeight = [AppConstants globalLineHeight];
//        _lbContent.numberOfLines = 0;
//        //_lbContent.backgroundColor = [UIColor redColor];
//        //添加到容器
//        [self.contentView addSubview:_lbTitle];
//        [self.contentView addSubview:_lbContent];
    }
    return self;
}

#pragma mark 加载数据模型frame
-(void)loadModelCellFrame:(PaperResultModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    NSLog(@"加载试卷结果数据模型frame...");
    
    //内容
    _lbContent.attributedText = cellFrame.contentAttributedString;
    _lbContent.frame = cellFrame.contentFrame;
    
//    //标题
//    if(cellFrame.title && cellFrame.title.length > 0){
//        _lbTitle.font = cellFrame.titleFont;
//        _lbTitle.frame = cellFrame.titleFrame;
//        _lbTitle.text = cellFrame.title;
//    }
//    //内容
//    if(cellFrame.content && cellFrame.content.length > 0){
//        _lbContent.font = cellFrame.contentFont;
//        if(cellFrame.contentFontColor){
//            _lbContent.textColor = cellFrame.contentFontColor;
//        }
//        _lbContent.frame = cellFrame.contentFrame;
//        _lbContent.text = cellFrame.content;
//    }
}
@end
