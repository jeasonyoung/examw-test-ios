//
//  ItemView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemView.h"
#import "PaperReview.h"

#import "UIColor+Hex.h"

#import "NSStringUtils.h"
#import "UIViewUtils.h"

//试题选中结果实现
@implementation ItemViewSelected
#pragma mark 初始化
-(instancetype)initWithItemCode:(NSString *)itemCode itemIndex:(NSUInteger)index selectedCode:(NSString *)selectedCode{
    if(self = [super init]){
        _itemCode = itemCode;
        _itemIndex = index;
        _selectedCode = selectedCode;
    }
    return  self;
}
#pragma mark 静态初始化
+(instancetype)selectedWithItemCode:(NSString *)itemCode itemIndex:(NSUInteger)index selectedCode:(NSString *)selectedCode{
    return [[self alloc]initWithItemCode:itemCode itemIndex:index selectedCode:selectedCode];
}
@end

#define __kItemViewModelType_NormalTitle 10//普通标题
#define __kItemViewModelType_ShareTopTitle 11//共享一级标题
#define __kItemViewModelType_ShareSubTitle 12//共享子标题
#define __kItemViewModelType_SingleOption 21//单选选项
#define __kItemViewModelType_MultiOption 22//多选选项
#define __kItemViewModelType_AnswerAnalysis 30//答案解析
//试题UI数据模型
@interface ItemViewModel : NSObject
//类型10-普通标题,11-共享一级标题,12-共享二级标题 21-单选,22-多选,30-答案解析
@property(nonatomic,assign)NSUInteger type;
//代码ID
@property(nonatomic,copy)NSString *code;
//序号标题
@property(nonatomic,copy)NSString *title;
//内容
@property(nonatomic,copy)NSString *content;
//我的答案
@property(nonatomic,copy)NSString *myAnswer;
//正确答案
@property(nonatomic,copy)NSString *rightAnswer;
//是否显示答案
@property(nonatomic,assign)BOOL displayAnswer;
//是否选中
@property(nonatomic,assign,readonly,getter=isSelected)BOOL selected;
//初始化普通标题(共享子标题)
+(instancetype)modelWithType:(NSUInteger)type orderTitle:(NSString *)orderTitle content:(NSString *)content;
//初始化共享一级标题
+(instancetype)modelWithType:(NSUInteger)type content:(NSString *)content;
//初始化选项
+(instancetype)modelWithType:(NSUInteger)type itemCode:(NSString *)code content:(NSString *)content
                    myAnswer:(NSString *)myAnswer rightAnswer:(NSString *)rightAnswer displayAnswer:(BOOL)display;
//初始化答案解析
+(instancetype)modelWithRightAnswer:(NSString *)rightAnswer myAnswer:(NSString *)myAnswer analysis:(NSString *)content;
@end
//试题UI数据模型实现
@implementation ItemViewModel
-(instancetype)initWithType:(NSUInteger)type code:(NSString *)code title:(NSString *)title content:(NSString *)content
                   myAnswer:(NSString *)myAnswer rightAnswer:(NSString *)rightAnswer displayAnswer:(BOOL)display{
    if(self = [super init]){
        _type = type;
        _code = code;
        _content = content;
        _myAnswer = myAnswer;
        _rightAnswer = rightAnswer;
        _displayAnswer = display;
    }
    return self;
}
#pragma mark 重载是否选择
-(BOOL)isSelected{
    if((_type == __kItemViewModelType_SingleOption || _type == __kItemViewModelType_MultiOption) && _myAnswer && _code){
        return [NSStringUtils existContains:_myAnswer subText:_code];
    }
    return NO;
}
#pragma mark 初始化普通标题(共享子标题)
+(instancetype)modelWithType:(NSUInteger)type orderTitle:(NSString *)orderTitle content:(NSString *)content{
    return [[self alloc]initWithType:type code:nil title:orderTitle content:content myAnswer:nil rightAnswer:nil displayAnswer:NO];
}
#pragma mark 初始化共享一级标题
+(instancetype)modelWithType:(NSUInteger)type content:(NSString *)content{
    return [[self alloc]initWithType:type code:nil title:nil content:content myAnswer:nil rightAnswer:nil displayAnswer:NO];
}
#pragma mark 初始化选项
+(instancetype)modelWithType:(NSUInteger)type itemCode:(NSString *)code content:(NSString *)content
                    myAnswer:(NSString *)myAnswer rightAnswer:(NSString *)rightAnswer displayAnswer:(BOOL)display{
    return [[self alloc]initWithType:type code:code title:nil content:content
                            myAnswer:myAnswer rightAnswer:rightAnswer displayAnswer:display];
}
#pragma mark 初始化答案解析
+(instancetype)modelWithRightAnswer:(NSString *)rightAnswer myAnswer:(NSString *)myAnswer analysis:(NSString *)content{
    return [[self alloc]initWithType:__kItemViewModelType_AnswerAnalysis code:nil title:nil content:content
                            myAnswer:myAnswer rightAnswer:rightAnswer displayAnswer:NO];
}
@end

//试题UI数据模型Frame
@interface ItemViewModelFrame : NSObject
//模型代码
@property(nonatomic,copy,readonly)NSString *modelCode;
//模型类型
@property(nonatomic,assign,readonly)NSUInteger modelType;
//模型类型值
@property(nonatomic,copy,readonly)NSString *modelTypeText;
//图标尺寸
@property(nonatomic,assign,readonly)CGRect iconFrame;
//图片
@property(nonatomic,copy,readonly)UIImage *icon;
//内容尺寸
@property(nonatomic,assign,readonly)CGRect contentFrame;
//内容
@property(nonatomic,copy,readonly)NSAttributedString *contentAttri;
//我的答案尺寸
@property(nonatomic,assign,readonly)CGRect myAnswerFrame;
//我的答案
@property(nonatomic,copy,readonly)NSAttributedString *myAnswerAttri;
//正确答案尺寸
@property(nonatomic,assign,readonly)CGRect rightAnswerFrame;
//正确答案
@property(nonatomic,copy,readonly)NSAttributedString *rightAnswerAttri;
//答案解析标题尺寸
@property(nonatomic,assign,readonly)CGRect analysisTitleFrame;
//答案解析标题
@property(nonatomic,copy,readonly)NSAttributedString *analysisTitleAttri;
//行高
@property(nonatomic,assign,readonly)CGFloat rowHeight;
//设置模型数据
@property(nonatomic,copy)ItemViewModel *data;
@end
#define __kItemViewModelFrame_Top 5//顶部间隔
#define __kItemViewModelFrame_Bottom 5//底部间隔
#define __kItemViewModelFrame_Left 5//左边间隔
#define __kItemViewModelFrame_Right 5//右边间隔
#define __kItemViewModelFrame_Margin 5//内部间隔
#define __kItemViewModelFrame_fontSize 14//字体尺寸
//#define __kItemViewModelFrame_fontColor 0x000000//默认字体颜色
#define __kItemViewModelFrame_rightFontColor 0x00FF00//做对
#define __kItemViewModelFrame_errorFontColor 0xFF0000//做错

#define __kItemViewModelFrame_iconWith 22//icon的宽
#define __kItemViewModelFrame_iconHeight 22//icon的高
#define __kItemViewModelFrame_iconSingleSelected @"option_single_selected.png"//单选选中图片
#define __kItemViewModelFrame_iconSingleNormal @"option_single_normal.png"//单选未选中
#define __kItemViewModelFrame_iconMultySelected @"option_multy_selected.png"//多选选中图片
#define __kItemViewModelFrame_iconMultyNormal @"option_multy_normal.png"//多选未选中图片
#define __kItemViewModelFrame_iconRight @"option_single_right.png"//选项选对
#define __kItemViewModelFrame_iconError @"option_single_error.png"//选项选错

//#define __k_itemanswerview_borderColor 0x00E5EE//答案边框颜色
#define __kItemViewModelFrame_analysisMyTitle @"我的回答:"//
#define __kItemViewModelFrame_analysisMyFontColor 0x0000FF//答案颜色
#define __kItemViewModelFrame_analysisMyTipFontColor 0xFFFAFA//字体颜色
#define __kItemViewModelFrame_analysisMyTipRight @" √ 答对了"//
#define __kItemViewModelFrame_analysisMyTipRightbgColor 0x008B00//背景色
#define __kItemViewModelFrame_analysisMyTipWrong @" × 答错了"//
#define __kItemViewModelFrame_analysisMyTipWrongbgColor 0xFF0000//背景色

#define __kItemViewModelFrame_analysisRightTitle @"正确答案:"//
#define __kItemViewModelFrame_analysisAnalysisTitle @"答案解析"//

//#define __k_itemanswerview_analysis_bgColor 0xFFEFDB//背景色

//试题UI数据模型Frame成员变量
@interface ItemViewModelFrame (){
    UIFont *_font;
}
@end
//试题UI数据模型Frame实现
@implementation ItemViewModelFrame
#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _font = [UIFont systemFontOfSize:__kItemViewModelFrame_fontSize];
    }
    return self;
}
//设置模型数据
-(void)setData:(ItemViewModel *)data{
    if((_data = data)){
        _modelType = _data.type;
        _modelTypeText = [NSString stringWithFormat:@"%d",(int)_modelType];
        _modelCode = _data.code;
        NSNumber *outY = [NSNumber numberWithFloat:__kItemViewModelFrame_Top];
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - __kItemViewModelFrame_Left - __kItemViewModelFrame_Right;
        switch (_modelType) {
            case __kItemViewModelType_NormalTitle:{//普通标题
                [self setupNormalTitleWithWidth:width OutY:&outY];
                break;
            }
            case __kItemViewModelType_ShareTopTitle:{//共享一级标题
                [self setupTopTitleWithWidth:width OutY:&outY];
                break;
            }
            case __kItemViewModelType_ShareSubTitle:{//共享子标题
                [self setupNormalTitleWithWidth:width OutY:&outY];
                break;
            }
            case __kItemViewModelType_SingleOption:{//单选选项
                [self setupSingleOptionWithWidth:width OutY:&outY];
                break;
            }
            case __kItemViewModelType_MultiOption:{//多选选项
                [self setupMultiOptionWithWidth:width OutY:&outY];
                break;
            }
            case __kItemViewModelType_AnswerAnalysis:{//答案解析
                [self setupAnalysisWithWidth:width OutY:&outY];
                break;
            }
            default:
                break;
        }
        //行高
        _rowHeight = outY.floatValue + __kItemViewModelFrame_Bottom;
    }
}
//创建普通标题
-(void)setupNormalTitleWithWidth:(CGFloat)width OutY:(NSNumber **)outY{
    NSString *title = _data.content;
    if(_data.title && ![NSStringUtils existContains:_data.content subText:_data.title]){
        NSString *content = [NSStringUtils replaceFirstContent:_data.content regex:@"([1-9]+\\.)" target:@""];
        title = [NSString stringWithFormat:@"%@ %@",_data.title,content];
    }
    [self setupTitleWithTitle:title Width:width OutY:outY];
}
//创建共享一级标题
-(void)setupTopTitleWithWidth:(CGFloat)width OutY:(NSNumber **)outY{
    NSString *title = [NSStringUtils replaceAllContent:_data.content regex:@"([1-9]+\\.)" target:@""];
   [self setupTitleWithTitle:title Width:width OutY:outY];
}
//创建标题
-(void)setupTitleWithTitle:(NSString *)title Width:(CGFloat)width OutY:(NSNumber **)outY{
    if(!title || title.length == 0)return;
    NSMutableAttributedString *titleAttri = [NSStringUtils toHtmlWithText:title];
    [titleAttri addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, title.length)];
    _contentAttri = titleAttri;
    
    CGSize titleAttriSize = [NSStringUtils boundingRectWithHtml:titleAttri constrainedToWidth:width];
    _contentFrame = CGRectMake(__kItemViewModelFrame_Left, (*outY).floatValue, width, titleAttriSize.height);
    
    *outY = [NSNumber numberWithFloat:(CGRectGetMaxY(_contentFrame) + __kItemViewModelFrame_Bottom)];
}
//单选选项
-(void)setupSingleOptionWithWidth:(CGFloat)width OutY:(NSNumber **)outY{
    
    [self setupOptionWithContent:_data.content Width:width
                       imgNormal:__kItemViewModelFrame_iconSingleNormal
                     imgSelected:__kItemViewModelFrame_iconSingleSelected
                            OutY:outY];
}
//多选选项
-(void)setupMultiOptionWithWidth:(CGFloat)width OutY:(NSNumber **)outY{
    [self setupOptionWithContent:_data.content Width:width
                       imgNormal:__kItemViewModelFrame_iconMultyNormal
                     imgSelected:__kItemViewModelFrame_iconMultySelected
                            OutY:outY];
}
//选项
-(void)setupOptionWithContent:(NSString *)content Width:(CGFloat)width
                    imgNormal:(NSString *)imgNormal
                  imgSelected:(NSString*)imgSelected
                         OutY:(NSNumber **)outY{
    
    if(!content || content.length == 0)return;
    
    NSString *img;
    
    NSMutableAttributedString *contentAttri = [NSStringUtils toHtmlWithText:content];
    NSRange contentRange = NSMakeRange(0, content.length);
    
    [contentAttri addAttribute:NSFontAttributeName value:_font range:contentRange];
    if(_data.isSelected){//选中
        if(_data.displayAnswer && _data.rightAnswer){//显示对错
            BOOL isRight = [NSStringUtils existContains:_data.rightAnswer subText:_data.code];
            img = isRight ?  __kItemViewModelFrame_iconRight : __kItemViewModelFrame_iconError;
            if(isRight){
                [contentAttri addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor colorWithHex:__kItemViewModelFrame_rightFontColor]
                                     range:contentRange];
            }else{
                NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor colorWithHex:__kItemViewModelFrame_errorFontColor],
                                        NSStrikethroughStyleAttributeName:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle)};
                
                [contentAttri addAttributes:attrs range:contentRange];
            }
        }else{//不显示对错
            img = imgSelected;
        }
    }else{//未选中
        img = imgNormal;
    }
    _icon = [UIImage imageNamed:img];
    _iconFrame = CGRectMake(__kItemViewModelFrame_Left, (*outY).floatValue,
                            __kItemViewModelFrame_iconWith, __kItemViewModelFrame_iconHeight);
    CGFloat maxHeight = CGRectGetHeight(_iconFrame);
    CGFloat contentWidth = width - CGRectGetMaxX(_iconFrame) - __kItemViewModelFrame_Margin;
    CGSize contentSize = [NSStringUtils boundingRectWithHtml:contentAttri constrainedToWidth:contentWidth];
    if(maxHeight < contentSize.height){
        maxHeight = contentSize.height;
    }
    _contentFrame = CGRectMake(CGRectGetMaxX(_iconFrame) + __kItemViewModelFrame_Margin, (*outY).floatValue,
                               contentWidth, maxHeight);
    _contentAttri = contentAttri;
    
    *outY = [NSNumber numberWithFloat:((*outY).floatValue + maxHeight)];
    
}
//答案解析
-(void)setupAnalysisWithWidth:(CGFloat)width OutY:(NSNumber **)outY{
    //我的答案
    NSMutableString *myAnswer = [NSMutableString stringWithString:__kItemViewModelFrame_analysisMyTitle];
    NSUInteger pos = myAnswer.length;
    [myAnswer appendFormat:@"%@ ",(_data.myAnswer ? _data.myAnswer : @"")];
    NSRange myAnswerRang = NSMakeRange(pos, myAnswer.length - pos);
    pos = myAnswer.length;
    UIColor *bgColor;
    if(_data.rightAnswer && _data.myAnswer && [NSStringUtils existContains:_data.rightAnswer subText:_data.myAnswer]){//答对
        bgColor = [UIColor colorWithHex:__kItemViewModelFrame_analysisMyTipRightbgColor];
        [myAnswer appendString:__kItemViewModelFrame_analysisMyTipRight];
    }else{//答错
        bgColor = [UIColor colorWithHex:__kItemViewModelFrame_analysisMyTipWrongbgColor];
        [myAnswer appendString:__kItemViewModelFrame_analysisMyTipWrong];
    }
    NSRange myAnswerTipRange = NSMakeRange(pos, myAnswer.length - pos);
    NSMutableAttributedString *myAnswerAttri = [NSStringUtils toHtmlWithText:myAnswer];
    //设置字体
    [myAnswerAttri addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, myAnswer.length)];
    //我的答案前景色
    [myAnswerAttri addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:__kItemViewModelFrame_analysisMyFontColor] range:myAnswerRang];
    //我的答案tip前景色
    [myAnswerAttri addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:__kItemViewModelFrame_analysisMyTipFontColor] range:myAnswerTipRange];
    //我的答案tip背景色
    [myAnswerAttri addAttribute:NSBackgroundColorAttributeName value:bgColor range:myAnswerTipRange];
    //我的答案
    CGSize myAnswerAttriSize = [NSStringUtils boundingRectWithHtml:myAnswerAttri constrainedToWidth:width];
    _myAnswerFrame = CGRectMake(__kItemViewModelFrame_Left, (*outY).floatValue, width, myAnswerAttriSize.height);
    _myAnswerAttri = myAnswerAttri;
    
    //正确答案
    NSString *rightAnswer = [NSString stringWithFormat:@"%@ %@",__kItemViewModelFrame_analysisRightTitle,(_data.rightAnswer ? _data.rightAnswer : @"")];
    NSMutableAttributedString *rightAnswerAttri = [NSStringUtils toHtmlWithText:rightAnswer];
    //设置字体
    [rightAnswerAttri addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, rightAnswer.length)];
    CGSize rightAnswerSize = [NSStringUtils boundingRectWithHtml:rightAnswerAttri constrainedToWidth:width];
    _rightAnswerFrame = CGRectMake(__kItemViewModelFrame_Left, CGRectGetMaxY(_myAnswerFrame) + __kItemViewModelFrame_Margin, width, rightAnswerSize.height);
    _rightAnswerAttri = rightAnswerAttri;
    
    //答案解析标题
    NSString *analysisTitle = __kItemViewModelFrame_analysisAnalysisTitle;
    NSMutableAttributedString *analysisTitleAttri = [NSStringUtils toHtmlWithText:analysisTitle];
    //设置字体
    [analysisTitleAttri addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, analysisTitle.length)];
    CGSize analysisTitleSize = [NSStringUtils boundingRectWithHtml:analysisTitleAttri constrainedToWidth:width];
    _analysisTitleFrame = CGRectMake(__kItemViewModelFrame_Left, CGRectGetMaxY(_rightAnswerFrame) + __kItemViewModelFrame_Margin, width, analysisTitleSize.height);
    _analysisTitleAttri = analysisTitleAttri;
    
    //答案解析
    NSString *analysis = _data.content;
    NSMutableAttributedString *analysisAttri = [NSStringUtils toHtmlWithText:analysis];
    //设置字体
    [analysisAttri addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, analysis.length)];
    CGFloat analysisWidth = width - __kItemViewModelFrame_Margin;
    CGSize analysisSize = [NSStringUtils boundingRectWithHtml:analysisAttri constrainedToWidth:analysisWidth];
    _contentFrame = CGRectMake(__kItemViewModelFrame_Left + (__kItemViewModelFrame_Margin/2),
                               CGRectGetMaxY(_analysisTitleFrame) + (__kItemViewModelFrame_Margin/2),
                               analysisWidth, analysisSize.height);
    _contentAttri = analysisAttri;
    
    //输出
    *outY = [NSNumber numberWithFloat:(CGRectGetMaxY(_contentFrame))];
}
@end


//试题UI的行
@interface ItemViewCell : UITableViewCell
//初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
//加载试题UI模型Frame
-(void)loadModelFrame:(ItemViewModelFrame *)modelFrame;
@end

//试题UI的行的实现
@implementation ItemViewCell
#pragma mark 初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]){
        
    }
    return self;
}
#pragma mark 加载试题UI模型Frame
-(void)loadModelFrame:(ItemViewModelFrame *)modelFrame{
    
}
@end


//试题UI标题行
@interface ItemViewTitleCell : ItemViewCell
@end
#define __kItemViewTitleCell_titlebgColor 0xC9F28C//试题标题边框颜色
#define __kItemViewTitleCell_cornerRadius 5//圆角曲度
#define __kItemViewTitleCell_borderWidth 0.2//边线宽度
@interface ItemViewTitleCell (){
    UILabel *_content;
}
@end
//试题UI标题行实现
@implementation ItemViewTitleCell
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithReuseIdentifier:reuseIdentifier]){
        _content = [[UILabel alloc]init];
        _content.numberOfLines = 0;
        _content.textAlignment = NSTextAlignmentLeft;
        UIColor *bgColor = [UIColor colorWithHex:__kItemViewTitleCell_titlebgColor];
        [UIViewUtils addBoundsRadiusWithView:_content
                                CornerRadius:__kItemViewTitleCell_cornerRadius
                                 BorderColor:bgColor
                                 BorderWidth:__kItemViewTitleCell_borderWidth
                             BackgroundColor:bgColor];
        [self.contentView addSubview:_content];
    }
    return self;
}
#pragma mark 加载试题UI模型Frame
-(void)loadModelFrame:(ItemViewModelFrame *)modelFrame{
    if(!modelFrame)return;
    _content.frame = modelFrame.contentFrame;
    _content.attributedText = modelFrame.contentAttri;
}
@end

//试题UI选项行
@interface ItemViewOptionCell : ItemViewCell
@end
//试题UI选项行成员变量
@interface ItemViewOptionCell (){
    UIImageView *_imgView;
    UILabel *_contentView;
}
@end
//试题UI选项行实现
@implementation ItemViewOptionCell
#pragma mark 构造初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithReuseIdentifier:reuseIdentifier]){
        //图标
        _imgView = [[UIImageView alloc]init];
        [self.contentView addSubview:_imgView];
        //内容
        _contentView = [[UILabel alloc]init];
        _contentView.numberOfLines = 0;
        _contentView.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_contentView];
    }
    return self;
}
#pragma mark 加载试题UI模型Frame
-(void)loadModelFrame:(ItemViewModelFrame *)modelFrame{
    if(!modelFrame)return;
    //图标
    [_imgView setImage:modelFrame.icon];
    _imgView.frame = modelFrame.iconFrame;
    //内容
    _contentView.frame = modelFrame.contentFrame;
    _contentView.attributedText = modelFrame.contentAttri;
}
@end

//试题UI答案解析行
@interface ItemViewAnalysisCell : ItemViewCell
@end
//试题UI答案解析行成员变量
@interface ItemViewAnalysisCell(){
    UILabel *myAnswer,*rightAnswer,*analysisTitle,*analysis;
}
@end
//试题UI答案解析行实现
@implementation ItemViewAnalysisCell
#pragma mark 重载初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithReuseIdentifier:reuseIdentifier]){
        //我的答案
        myAnswer = [[UILabel alloc]init];
        myAnswer.numberOfLines = 0;
        myAnswer.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:myAnswer];
        //正确答案
        rightAnswer = [[UILabel alloc]init];
        rightAnswer.numberOfLines = 0;
        rightAnswer.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:rightAnswer];
        //答案解析标题
        analysisTitle = [[UILabel alloc]init];
        analysisTitle.numberOfLines = 0;
        analysisTitle.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:analysisTitle];
        //答案解析内容
        analysis = [[UILabel alloc]init];
        analysis.numberOfLines = 0;
        analysis.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:analysis];
    }
    return self;
}
#pragma mark 加载试题UI模型Frame
-(void)loadModelFrame:(ItemViewModelFrame *)modelFrame{
    if(!modelFrame)return;
    //我的答案
    myAnswer.frame = modelFrame.myAnswerFrame;
    myAnswer.attributedText = modelFrame.myAnswerAttri;
    //正确答案
    rightAnswer.frame = modelFrame.rightAnswerFrame;
    rightAnswer.attributedText = modelFrame.rightAnswerAttri;
    //答案解析标题
    analysisTitle.frame = modelFrame.analysisTitleFrame;
    analysisTitle.attributedText = modelFrame.analysisTitleAttri;
    //答案解析内容
    analysis.frame = modelFrame.contentFrame;
    analysis.attributedText = modelFrame.contentAttri;
}
@end


#define __kItemView_cellTitlePrefix @"1"//cell标题前缀
#define __kItemView_cellOptionPrefix @"2"//cell选项前缀
#define __kItemView_cellAnalysisPrefix @"3"//cell解析前缀

#define __kItemView_cellIdentifierFormat @"cell_%@"//
//试题UI成员变量
@interface ItemView (){
    UITableView *_tableView;
    PaperItem *_item;
    
    NSMutableArray *_dataArrays;
    ItemViewModel *_answerAnalysisModel;
    
    NSUInteger _itemIndex;
    NSString *_myAnswers;
    bool _dispalyeAnswer;
}
@end
//试题UI实现
@implementation ItemView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self =[super initWithFrame:frame]){
        //初始化
        //初始化tableview
        CGRect tempFrame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _tableView = [[UITableView alloc]initWithFrame:tempFrame style:UITableViewStylePlain];
        [self addSubview:_tableView];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollsToTop = NO;
    }
    return self;
}
#pragma mark 设置Frame
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGRect tempFrame = _tableView.frame;
    tempFrame.size = frame.size;
    _tableView.frame = tempFrame;
}
#pragma mark 试题JSON集合
-(NSDictionary *)toItemJSON{
    if(_item){
        return [_item serializeJSON];
    }
    return nil;
}
#pragma mark 重新加载数据
-(void)loadData{
    //加载试题数据
    [self reloadItem];
    //重新加载
    [_tableView reloadData];
}
#pragma mark 显示答案
-(void)displayAnswer:(BOOL)display{
    if(_dispalyeAnswer == display)return;
    _dispalyeAnswer = display;
    if(_dataArrays && _dataArrays.count > 0){
        NSMutableArray *reloadIndexPaths = [NSMutableArray array],
            *insertIndexPaths = [NSMutableArray array],
            *deleteIndexPaths = [NSMutableArray array];
        //数据模型处理
        for(NSUInteger i = 0; i < _dataArrays.count; i++){
            ItemViewModelFrame *modelFrame = [_dataArrays objectAtIndex:i];
            if([modelFrame.modelTypeText hasPrefix:__kItemView_cellOptionPrefix]){//选项
                ItemViewModel *model = modelFrame.data;
                model.displayAnswer = _dispalyeAnswer;
                if(model.isSelected){//选中的行
                    //更新数据
                    modelFrame.data = model;
                    //更新的行
                    [reloadIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
            }else if(!_dispalyeAnswer && [modelFrame.modelTypeText hasPrefix:__kItemView_cellAnalysisPrefix]){//不显示，答案解析
                //须删除的数据模型
                [_dataArrays removeObjectAtIndex:i];
                //须要删除的行
                [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        //更新解析
        if(_answerAnalysisModel){
            _answerAnalysisModel.displayAnswer = _dispalyeAnswer;
        }
        if(_dispalyeAnswer && _answerAnalysisModel){//显示答案解析
            ItemViewModelFrame *analysisFrame = [[ItemViewModelFrame alloc]init];
            analysisFrame.data = _answerAnalysisModel;
            [_dataArrays addObject:analysisFrame];
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:(_dataArrays.count - 1) inSection:0]];
        }
        //新增
        if(insertIndexPaths.count > 0){
            [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        //删除
        if(deleteIndexPaths.count > 0){
            [_tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        //重新加载
        if(reloadIndexPaths.count > 0){
            [_tableView reloadRowsAtIndexPaths:reloadIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}
//加载试题数据
-(void)reloadItem{
    _dataArrays = [NSMutableArray array];
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(dataWithItemView:)]){
        //试题
        if((_item = [self.dataSource dataWithItemView:self])){
            NSString *orderTitle;
            //题序标题
            if([self.dataSource respondsToSelector:@selector(itemOrderTitleWithItemView:)]){
                orderTitle = [self.dataSource itemOrderTitleWithItemView:self];
            }
            //我的答案
            if([self.dataSource respondsToSelector:@selector(answerWithItemView:)]){
                _myAnswers = [self.dataSource answerWithItemView:self];
            }
            //是否显示答案
            if([self.dataSource respondsToSelector:@selector(displayAnswerWithItemView:)]){
                _dispalyeAnswer = [self.dataSource displayAnswerWithItemView:self];
            }else{
                _dispalyeAnswer = NO;
            }
            //试题索引
            _itemIndex = 0;
            _answerAnalysisModel = nil;
            //加载试题内容数据
            [self createItemContentWithItem:_item options:nil isCreateTitle:YES orderTitle:orderTitle];
            //显示答案解析
            if(_dispalyeAnswer && _answerAnalysisModel){
                ItemViewModelFrame *analysisFrame = [[ItemViewModelFrame alloc]init];
                analysisFrame.data = _answerAnalysisModel;
                //添加数据缓存
                [_dataArrays addObject:analysisFrame];
            }
        }
    }
}
//创建试题内容数据
-(void)createItemContentWithItem:(PaperItem *)item options:(NSArray *)options isCreateTitle:(BOOL)isCreateTitle
                      orderTitle:(NSString *)orderTitle{
    if(!item)return;
    //试题题型
    PaperItemType itemType = PaperItemTypeSingle;
    if((item.type >= (int)PaperItemTypeSingle) && (item.type <= (int)PaperItemTypeShareAnswer)){
        itemType = (PaperItemType)item.type;
    }
    static NSString *optOrderRegex = @"([A-Z]\\.)";
    
    switch (itemType){
        case PaperItemTypeSingle://单选
        case PaperItemTypeMulty://多选
        case PaperItemTypeUncertain://不定向选
        {
            NSUInteger type;
            if(isCreateTitle){//创建标题
                type = __kItemViewModelType_NormalTitle;
                //创建标题并添加到数据缓存
                [_dataArrays addObject:[self createNormalTitleFrameWithType:type orderTitle:orderTitle content:item.content]];
            }
            //选项
            type = ((itemType == PaperItemTypeSingle) ? __kItemViewModelType_SingleOption : __kItemViewModelType_MultiOption);
            if(!options || options.count == 0) options = item.children;
            
            NSMutableArray *myAnswerArrays = [NSMutableArray array],*rightAnswerArrays = [NSMutableArray array];
            if(options){
                for(PaperItem *opt in options){
                    if(!opt)continue;
                    //初始化选项数据
                    ItemViewModelFrame *optFrame = [[ItemViewModelFrame alloc]init];
                    optFrame.data = [ItemViewModel modelWithType:type itemCode:opt.code content:opt.content
                                                        myAnswer:_myAnswers rightAnswer:item.answer displayAnswer:_dispalyeAnswer];
                    //添加数据缓存
                    [_dataArrays addObject:optFrame];
                    
                    //我的答案处理
                    if(_myAnswers && _myAnswers.length > 0 && [NSStringUtils existContains:_myAnswers subText:opt.code]){
                        NSString *optOrder = [NSStringUtils findFirstContent:opt.content regex:optOrderRegex];
                        if(optOrder && optOrder.length > 0){
                            [myAnswerArrays addObject:[optOrder substringWithRange:NSMakeRange(0, 1)]];
                        }
                    }
                    //正确答案处理
                    if(item.answer && item.answer.length > 0 && [NSStringUtils existContains:item.answer subText:opt.code]){
                        NSString *optOrder = [NSStringUtils findFirstContent:opt.content regex:optOrderRegex];
                        if(optOrder && optOrder.length > 0){
                            [rightAnswerArrays addObject:[optOrder substringWithRange:NSMakeRange(0, 1)]];
                        }
                    }
                }
            }
            //答案解析
            _answerAnalysisModel = [ItemViewModel modelWithRightAnswer:[rightAnswerArrays componentsJoinedByString:@" "]
                                                              myAnswer:[myAnswerArrays componentsJoinedByString:@" "]
                                                              analysis:item.analysis];
            break;
        }
        case PaperItemTypeJudge:{//判断题
            NSUInteger type;
            if(isCreateTitle){//创建标题
                type = __kItemViewModelType_NormalTitle;
                //创建标题并添加到数据缓存
                [_dataArrays addObject:[self createNormalTitleFrameWithType:type orderTitle:orderTitle content:item.content]];
            }
            //判断选项
            type = __kItemViewModelType_SingleOption;
            NSString *code,*content,*rightAnswer,*myAnswer;
            
            //“正确”选项
            code = [NSString stringWithFormat:@"%d",(int)PaperItemJudgeAnswerRight];
            content = [PaperItem judgeAnswerName:PaperItemJudgeAnswerRight];
            
            //我的答案
            if(_myAnswers && [NSStringUtils existContains:_myAnswers subText:code]){
                myAnswer = content;
            }
            //正确答案
            if(item.answer && [NSStringUtils existContains:item.answer subText:code]) {
                rightAnswer = content;
            }
            
            ItemViewModelFrame *rightOptFrame = [[ItemViewModelFrame alloc]init];
            rightOptFrame.data = [ItemViewModel modelWithType:type itemCode:code content:content myAnswer:_myAnswers
                                                rightAnswer:item.answer displayAnswer:_dispalyeAnswer];
            [_dataArrays addObject:rightOptFrame];
            //“错误”选项
            code = [NSString stringWithFormat:@"%d",(int)PaperItemJudgeAnswerWrong];
            content = [PaperItem judgeAnswerName:PaperItemJudgeAnswerWrong];
            
            //我的答案
            if(_myAnswers && [NSStringUtils existContains:_myAnswers subText:code]){
                myAnswer = content;
            }
            //正确答案
            if(item.answer && [NSStringUtils existContains:item.answer subText:code]) {
                rightAnswer = content;
            }
            
            ItemViewModelFrame *wrongOptFrame = [[ItemViewModelFrame alloc]init];
            wrongOptFrame.data = [ItemViewModel modelWithType:type itemCode:code content:content myAnswer:_myAnswers
                                                rightAnswer:item.answer displayAnswer:_dispalyeAnswer];
            [_dataArrays addObject:wrongOptFrame];
            
            //答案解析
            _answerAnalysisModel = [ItemViewModel modelWithRightAnswer:rightAnswer myAnswer:myAnswer analysis:item.analysis];
        
        }
        case PaperItemTypeQanda:{//问答题
            NSUInteger type;
            if(isCreateTitle){//创建标题
                type = __kItemViewModelType_NormalTitle;
                //创建标题并添加到数据缓存
                [_dataArrays addObject:[self createNormalTitleFrameWithType:type orderTitle:orderTitle content:item.content]];
            }
            //答案解析
            _answerAnalysisModel = [ItemViewModel modelWithRightAnswer:item.answer myAnswer:_myAnswers analysis:item.analysis];
            break;
        }
        case PaperItemTypeShareTitle:{//共享题干题
            if(!isCreateTitle)return;
            //加载试题索引
            if([self.dataSource respondsToSelector:@selector(itemIndexWithItemView:)]){
                _itemIndex = [self.dataSource itemIndexWithItemView:self];
            }
            NSUInteger type = __kItemViewModelType_ShareTopTitle;
            //创建一级标题并添加到数据缓存
            [_dataArrays addObject:[self createTopTitleFrameWithType:type content:item.content]];
            //当前试题
            if(item.children && item.children.count > _itemIndex){
                PaperItem *subItem = [item.children objectAtIndex:_itemIndex];
                if(!subItem)return;
                //创建二级标题并添加到数据缓存
                type = __kItemViewModelType_ShareSubTitle;
                [_dataArrays addObject:[self createSubTitleFrameWithType:type orderTitle:orderTitle content:subItem.content]];
                //选项
                [self createItemContentWithItem:subItem options:nil isCreateTitle:NO orderTitle:orderTitle];
            }
            break;
        }
        case PaperItemTypeShareAnswer:{//共享答案题
            if(!isCreateTitle)return;
            //加载试题索引
            if([self.dataSource respondsToSelector:@selector(itemIndexWithItemView:)]){
                _itemIndex = [self.dataSource itemIndexWithItemView:self];
            }
            NSUInteger type = __kItemViewModelType_ShareTopTitle;
            //创建一级标题并添加到数据缓存
            [_dataArrays addObject:[self createTopTitleFrameWithType:type content:item.content]];
            //当前试题
            if(item.children && item.children > 0){
                NSUInteger max = 0;
                PaperItem *p;
                NSMutableArray *options = [NSMutableArray array];
                for(PaperItem *child in item.children){
                    if(!child)continue;
                    if(child.orderNo > max){
                        if(p){
                            [options addObject:p];
                        }
                        p = child;
                        max = child.orderNo;
                    }else{
                        [options addObject:child];
                    }
                }
                if(p && p.children && p.children.count > _itemIndex){
                    PaperItem *subItem = [p.children objectAtIndex:_itemIndex];
                    if(!subItem)return;
                    //创建二级标题并添加到数据缓存
                    type = __kItemViewModelType_ShareSubTitle;
                    [_dataArrays addObject:[self createSubTitleFrameWithType:type orderTitle:orderTitle content:subItem.content]];
                    //选项
                    [self createItemContentWithItem:subItem options:options isCreateTitle:NO orderTitle:orderTitle];
                }
            }
            break;
        }
        default:break;
    }
}

//创建标题模型Frame
-(ItemViewModelFrame *)createNormalTitleFrameWithType:(NSUInteger)type orderTitle:(NSString *)orderTitle content:(NSString *)content{
    //创建标题
    ItemViewModelFrame *titleFrame = [[ItemViewModelFrame alloc]init];
    titleFrame.data = [ItemViewModel modelWithType:type orderTitle:orderTitle content:content];
    return titleFrame;
}
//创建共享一级标题模型Frame
-(ItemViewModelFrame *)createTopTitleFrameWithType:(NSUInteger)type content:(NSString *)content{
    ItemViewModelFrame *topTitleFrame = [[ItemViewModelFrame alloc]init];
    topTitleFrame.data = [ItemViewModel modelWithType:type content:content];
    return topTitleFrame;
}
//创建共享二级标题模型Frame
-(ItemViewModelFrame *)createSubTitleFrameWithType:(NSUInteger)type orderTitle:(NSString *)orderTitle content:(NSString *)content{
    ItemViewModelFrame *subTitleFrame = [[ItemViewModelFrame alloc]init];
    subTitleFrame.data = [ItemViewModel modelWithType:type orderTitle:orderTitle content:content];
    return subTitleFrame;
}

#pragma mark UITableViewDataSource
//数据行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataArrays){
        return _dataArrays.count;
    }
    return 0;
}
//显示行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_dataArrays || _dataArrays.count < indexPath.row)return nil;
    ItemViewModelFrame *dataModelFrame = [_dataArrays objectAtIndex:indexPath.row];
    NSString *cellType,*identifier;
    if([dataModelFrame.modelTypeText hasPrefix:__kItemView_cellTitlePrefix]){//标题
        cellType = __kItemView_cellTitlePrefix;
    }else if([dataModelFrame.modelTypeText hasPrefix:__kItemView_cellOptionPrefix]){//选项
        cellType = __kItemView_cellOptionPrefix;
    }else{//答案解析
        cellType = __kItemView_cellAnalysisPrefix;
    }
    identifier = [NSString stringWithFormat:__kItemView_cellIdentifierFormat,cellType];
    ItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        if([cellType isEqualToString:__kItemView_cellTitlePrefix]){//标题
            cell = [[ItemViewTitleCell alloc]initWithReuseIdentifier:identifier];
        }else if([cellType isEqualToString:__kItemView_cellOptionPrefix]){//选项
            cell = [[ItemViewOptionCell alloc]initWithReuseIdentifier:identifier];
        }else{//答案解析
            cell = [[ItemViewAnalysisCell alloc]initWithReuseIdentifier:identifier];
        }
    }
    //加载数据
    [cell loadModelFrame:dataModelFrame];
    //返回
    return cell;
}
//显示行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataArrays && _dataArrays.count > indexPath.row){
        ItemViewModelFrame *dataModelFrame = [_dataArrays objectAtIndex:indexPath.row];
        return dataModelFrame.rowHeight;
    }
    return 0;
}

#pragma mark UITableViewDelegate
//选中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL deselectedAnimated = NO;
    if(_dataArrays && indexPath.row > _dataArrays.count){
        ItemViewModelFrame *dataModelFrame = [_dataArrays objectAtIndex:indexPath.row];
        NSUInteger type = dataModelFrame.modelType;
        if(type == __kItemViewModelType_SingleOption){//单选
            NSString *selcetedCode = dataModelFrame.modelCode;
            if(!_myAnswers || (_myAnswers.length == 0) || (![selcetedCode isEqualToString:_myAnswers])){
                deselectedAnimated = YES;
                _myAnswers = selcetedCode;
                NSMutableArray *reloadIndexPaths = [NSMutableArray array];
                //选项处理
                for(NSUInteger i = 0; i < _dataArrays.count; i++){
                    ItemViewModelFrame *optFrame = [_dataArrays objectAtIndex:i];
                    if(optFrame && (optFrame.modelType == type)){
                        ItemViewModel *model = optFrame.data;
                        BOOL old = model.isSelected;
                        model.myAnswer = _myAnswers;
                        if(model.isSelected != old){//是否选中发生变化的
                            [reloadIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        }
                    }
                }
                //答案解析处理
                if(_answerAnalysisModel){
                    _answerAnalysisModel.myAnswer = _myAnswers;
                }
                //更新选项
                if(reloadIndexPaths.count > 0){
                    [tableView reloadRowsAtIndexPaths:reloadIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }else if(type == __kItemViewModelType_MultiOption){//多选
            NSString *selcetedCode = dataModelFrame.modelCode;
            if(!_myAnswers || (_myAnswers.length == 0) || (![NSStringUtils existContains:_myAnswers subText:selcetedCode])){//选中
                deselectedAnimated = YES;
                //重新组织我的答案
                NSMutableString *answers = [NSMutableString stringWithString:(_myAnswers ? _myAnswers : @"")];
                if(answers.length > 0){
                    [answers appendString:@","];
                }
                [answers appendString:selcetedCode];
                _myAnswers = answers;
            }else if([NSStringUtils existContains:_myAnswers subText:selcetedCode]){//取消选中
                //重新组织我的答案
                NSArray *answersArrays = [_myAnswers componentsSeparatedByString:@","];
                NSMutableArray *newAnswerArrays;
                if(answersArrays && answersArrays.count > 0){
                    newAnswerArrays = [NSMutableArray arrayWithCapacity:(answersArrays.count - 1)];
                    for(NSString *code in answersArrays){
                        if(!code || code.length == 0)continue;
                        if(![code isEqualToString:selcetedCode]){
                            [newAnswerArrays addObject:code];
                        }
                    }
                }
                if(newAnswerArrays && newAnswerArrays.count > 0){
                    deselectedAnimated = YES;
                    _myAnswers = [newAnswerArrays componentsJoinedByString:@","];
                }
            }
            if(deselectedAnimated){
                NSMutableArray *reloadIndexPaths = [NSMutableArray array];
                //选项处理
                for(NSUInteger i = 0; i < _dataArrays.count; i++){
                    ItemViewModelFrame *optFrame = [_dataArrays objectAtIndex:i];
                    if(optFrame && (optFrame.modelType == type)){
                        ItemViewModelFrame *optFrame = [_dataArrays objectAtIndex:i];
                        if(optFrame && (optFrame.modelType == type)){
                            ItemViewModel *model = optFrame.data;
                            BOOL old = model.isSelected;
                            model.myAnswer = _myAnswers;
                            if(model.isSelected != old){//是否选中发生变化的
                                [reloadIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                            }
                        }
                    }
                }
                //答案解析处理
                if(_answerAnalysisModel){
                    _answerAnalysisModel.myAnswer = _myAnswers;
                }
                //更新选项
                if(reloadIndexPaths.count > 0){
                    [tableView reloadRowsAtIndexPaths:reloadIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }
    }
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:deselectedAnimated];
    //传递点击事件
    if(deselectedAnimated){
        [self itemViewSelectedOnSelected];
    }
}
//触发选中事件
-(void)itemViewSelectedOnSelected{
    if(_item && self.delegate && [self.delegate respondsToSelector:@selector(itemView:didSelectAtSelected:)]){
        ItemViewSelected *selectedData = [ItemViewSelected selectedWithItemCode:_item.code itemIndex:_itemIndex
                                                                   selectedCode:_myAnswers];
        [self.delegate itemView:self didSelectAtSelected:selectedData];
    }
}
@end
