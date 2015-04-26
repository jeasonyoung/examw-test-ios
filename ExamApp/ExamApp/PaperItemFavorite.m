//
//  PaperItemFavorite.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemFavorite.h"
//#import "ItemContentView.h"

//试题收藏实现类
@implementation PaperItemFavorite
//序列化
-(NSDictionary *)serializeJSON{
    return @{__k_paperitemfavorite_fields_code:(self.code ? self.code : @""),
             __k_paperitemfavorite_fields_subjectCode:(self.subjectCode ? self.subjectCode : @""),
             __k_paperitemfavorite_fields_itemCode:(self.itemCode ? self.itemCode : @""),
             __k_paperitemfavorite_fields_itemType:(self.itemType ? self.itemType : [NSNumber numberWithInteger:0]),
             __k_paperitemfavorite_fields_itemContent:(self.itemContent ? self.itemContent : @""),
             __k_paperitemfavorite_fields_remarks:(self.remarks ? self.remarks : @""),
             __k_paperitemfavorite_fields_status:(self.status ? self.status : [NSNumber numberWithInteger:0]),
             __k_paperitemfavorite_fields_createTime:(self.createTime ? self.createTime : @"")};
}
//#pragma mark 转换为数据源
//-(ItemContentSource *)toSourceAtOrder:(NSInteger)order{
//    if(_itemCode && _itemCode.length > 0 && _itemContent && _itemContent.length > 0){
//        NSArray *array = [_itemCode componentsSeparatedByString:@"$"];
//        NSInteger index = 0;
//        if(array && array.count == 2){
//            NSString *num = [array objectAtIndex:1];
//            if(num){
//                index = [num integerValue];
//            }
//        }
//        //
//        PaperItem *item = [[PaperItem alloc]initWithJSON:_itemContent];
//        if(!item) return nil;
//        //
//        return [ItemContentSource itemContentStructureCode:nil
//                                                    Source:item
//                                                     Index:index
//                                                     Order:order
//                                             SelectedValue:nil];
//        
//    }
//    return nil;
//}
@end
