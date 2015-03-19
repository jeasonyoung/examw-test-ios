//
//  PaperPreview.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperReview.h"
//试卷字段
#define __k_paper_fields_code @"id"//试卷ID
#define __k_paper_fields_name @"name"//试卷名称
#define __k_paper_fields_desc @"description"//试卷描述信息
#define __k_paper_fields_sourceName @"sourceName"//试卷来源
#define __k_paper_fields_areaName @"areaName"//所属地区
#define __k_paper_fields_type @"type"//试卷类型
#define __k_paper_fields_time @"time"//考试时长
#define __k_paper_fields_year @"year"//使用年份
#define __k_paper_fields_score @"score"//试卷总分
#define __k_paper_fields_structures @"structures"//试卷结构

//试卷类成员变量
@interface PaperReview (){
    NSMutableDictionary *_itemsCache;
}
@end
//试卷类实现。
@implementation PaperReview
#pragma mark 初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        _code = [dict objectForKey:__k_paper_fields_code];
        _name = [dict objectForKey:__k_paper_fields_name];
        _desc = [dict objectForKey:__k_paper_fields_desc];
        _sourceName = [dict objectForKey:__k_paper_fields_sourceName];
        _areaName = [dict objectForKey:__k_paper_fields_areaName];
        NSNumber *typeNum = [dict objectForKey:__k_paper_fields_type];
        if(typeNum){
            _type = typeNum.integerValue;
        }
        NSNumber *timeNum = [dict objectForKey:__k_paper_fields_time];
        if(timeNum){
            _time = timeNum.integerValue;
        }
        NSNumber *yearNum = [dict objectForKey:__k_paper_fields_year];
        if(yearNum){
            _year = yearNum.integerValue;
        }
        _score = [dict objectForKey:__k_paper_fields_score];
        NSArray *structuresArray = [dict objectForKey:__k_paper_fields_structures];
        if(structuresArray && structuresArray.count > 0){
            _structures = [PaperStructure deSerializeWithArray:structuresArray];
        }
    }
    return self;
}
#pragma mark 按顺序加载答题卡序号
-(void)loadAnswersheet:(void (^)(NSString *text, NSArray *indexPaths))structures{
    if(!_itemsCache) _itemsCache = [NSMutableDictionary dictionary];
    NSNumber *order = [NSNumber numberWithInt:0];
    if(self.structures && self.structures.count > 0){
        for(PaperStructure *ps in self.structures){
            if(!ps) continue;
            [self createItemAnswersheetWithStructure:ps Order:&order Sheets:structures];
        }
    }
}
//创建试题答题卡
-(void)createItemAnswersheetWithStructure:(PaperStructure *)structure
                                    Order:(NSNumber **)order
                                    Sheets:(void (^)(NSString *text, NSArray *indexPathSheets))sheets{
    NSString *title = structure.title, *code = structure.code;
    //结构下有试题集合
    if(structure.items && structure.items.count > 0){
        int index = (*order).intValue;
        NSMutableArray *indexPathArrays = [NSMutableArray array];
        for(PaperItem *item in structure.items){
            if(!item) continue;
            if(item.count > 1){
                for(int i = 0; i < item.count; i++){
                    [indexPathArrays addObject:[self createCacheWithOrder:index
                                                            StructureCode:code
                                                           StructureTitle:title
                                                                     Item:item
                                                                    Index:i]];
                    //
                    index++;
                }
            }else{
                [indexPathArrays addObject:[self createCacheWithOrder:index
                                                        StructureCode:code
                                                       StructureTitle:title
                                                                 Item:item
                                                                Index:0]];
                //
                index++;
            }
        }
        *order = [NSNumber numberWithInt:index];
        //调用块
        sheets(title,[indexPathArrays copy]);
    }else{//结构下没有试题
        //调用块
        sheets(title,nil);
    }
    //子结构
    if(structure.children && structure.children.count > 0){
        for(PaperStructure *ps in structure.children){
            if(!ps)continue;
            [self createItemAnswersheetWithStructure:ps Order:order Sheets:sheets];
        }
    }
}
//创建缓存
-(PaperItemOrderIndexPath *)createCacheWithOrder:(NSInteger)order
                                   StructureCode:(NSString *)code
                                  StructureTitle:(NSString *)title
                                            Item:(PaperItem *)item
                                           Index:(NSInteger)index{
    PaperItemOrderIndexPath *indexPath = [PaperItemOrderIndexPath paperOrder:order
                                                               StructureCode:code
                                                              StructureTitle:title
                                                                        Item:item
                                                                       Index:index];
    NSNumber *key = [NSNumber numberWithInteger:order];
    if(!_itemsCache)_itemsCache = [NSMutableDictionary dictionary];
    //添加到缓存
    [_itemsCache setObject:indexPath forKey:key];
    //返回
    return indexPath;
}

#pragma mark 按索引加载试题(索引从0开始)
-(void)loadItemAtOrder:(NSInteger)order ItemBlock:(void (^)(PaperItemOrderIndexPath *))block{
    if(order < 0 || order > self.total - 1)return;
    
    NSNumber *key = [NSNumber numberWithInteger:order];
    if(!_itemsCache)_itemsCache = [NSMutableDictionary dictionary];
    PaperItemOrderIndexPath *indexPath = [_itemsCache objectForKey:key];
    if(!indexPath){
        indexPath = [self createItemIndexPathAtOrder:order];
    }
    //调用块处理
    block(indexPath);
}
//创建试题索引
-(PaperItemOrderIndexPath *)createItemIndexPathAtOrder:(NSInteger)order{
    if(order < 0 || order > self.total - 1)return nil;
    if(self.structures && self.structures.count > 0){
        NSNumber *orderIndex = [NSNumber numberWithInt:0];
        PaperItemOrderIndexPath *indexPath;
        for(PaperStructure *ps in self.structures){
            if(!ps) continue;
            if([self findItemIndexPathAtOrder:order Structrue:ps OrderIndex:&orderIndex IndexPath:&indexPath]){
                break;
            }
        }
        return indexPath;
    }
    return nil;
}
//查找试题索引
-(BOOL)findItemIndexPathAtOrder:(NSInteger)order
                        Structrue:(PaperStructure *)ps
                       OrderIndex:(NSNumber **)orderIndex
                        IndexPath:(PaperItemOrderIndexPath **)indexPath{
    if(!ps)return NO;
    if(ps.items && ps.items.count > 0){
        int numOrder = [NSNumber numberWithInteger:order].intValue;
        NSString *title = ps.title, *code = ps.code;
        int index = (*orderIndex).intValue;
        for(PaperItem *item in ps.items){
            if(!item) continue;
            if(item.count > 1){
                for(int i = 0; i < item.count; i++){
                    if(index == numOrder){
                        *indexPath = [self createCacheWithOrder:index
                                                  StructureCode:code
                                                 StructureTitle:title
                                                           Item:item
                                                          Index:i];
                        return YES;
                    }
                    index++;
                }
            }else{
                if(index == numOrder){
                    *indexPath = [self createCacheWithOrder:index
                                              StructureCode:code
                                             StructureTitle:title
                                                       Item:item
                                                      Index:0];
                    return YES;
                }
                index++;
            }
        }
        *orderIndex = [NSNumber numberWithInt:index];
    }
    if(ps.children && ps.children.count > 0){
        for(PaperStructure *structure in ps.children){
            if([self findItemIndexPathAtOrder:order Structrue:structure OrderIndex:orderIndex IndexPath:indexPath]){
                return YES;
            }
        }
    }
    return NO;
}
#pragma mark 根据试题ID加载题序
-(NSInteger)findOrderAtItemCode:(NSString *)itemCode{
    if(!itemCode || itemCode.length == 0) return 0;
    NSNumber *order = [NSNumber numberWithInt:-1];
    NSArray *arrays = [itemCode componentsSeparatedByString:@"$"];
    if(self.structures && self.structures.count > 0){
        for(PaperStructure *ps in self.structures){
            if([self findItemCodeWithStructure:ps ItemCode:(NSString *)[arrays objectAtIndex:0] Order:&order]){
                break;
            }
        }
    }
    if(arrays.count > 1){
        order = [NSNumber numberWithInteger:order.integerValue + ((NSNumber *)[arrays objectAtIndex:(arrays.count - 1)]).integerValue];
    }
    
    return order.integerValue;
}
#pragma mark 根据ID查找题序
-(BOOL)findItemCodeWithStructure:(PaperStructure *)ps ItemCode:(NSString *)itemCode Order:(NSNumber **)order{
    if(!ps || !ps.items || ps.items.count == 0)return NO;
    NSInteger itemOrder = (*order).integerValue;
    for(PaperItem *item in ps.items){
        if(!item || !item.code)continue;
        itemOrder++;
        if([item.code isEqualToString:itemCode]){
            *order = [NSNumber numberWithInteger:itemOrder];
            return YES;
        }
    }
    *order = [NSNumber numberWithInteger:itemOrder];
    if(ps.children && ps.children.count > 0){
        for(PaperStructure *structure in ps.children){
            if([self findItemCodeWithStructure:structure ItemCode:itemCode Order:order]){
                return YES;
            }
        }
    }
    return NO;
}
#pragma mark 根据结构ID查找结构
-(void)findStructureAtStructureCode:(NSString *)code StructureBlock:(void (^)(PaperStructure *))block{
    if(!code || code.length == 0 || !self.structures || self.structures.count == 0)return;
    if(!block)return;
    [self findStructureWithStructures:self.structures AtStructureCode:code StructureBlock:block];
}
//
-(void)findStructureWithStructures:(NSArray *)arrays AtStructureCode:(NSString *)code StructureBlock:(void (^)(PaperStructure *))block{
    if(block && arrays && arrays.count > 0 && code && code.length > 0){
        for(PaperStructure *ps in arrays){
            if(!ps || !ps.code || ps.code.length == 0)continue;
            if([ps.code isEqualToString:code]){
                //NSLog(@"%@",ps.min);
                block(ps);
                break;
            }
            if(ps.children && ps.children.count > 0){
                [self findStructureWithStructures:ps.children AtStructureCode:code StructureBlock:block];
            }
        }
    }
}

#pragma mark 根据JSON字符串初始化
-(instancetype)initWithJSON:(NSString *)json{
    if(!json || json.length == 0) return nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    return [self initWithDictionary:dict];
}
#pragma mark 序列化
-(NSDictionary *)serializeJSON{
    NSMutableArray *structureSerialArrays = [NSMutableArray array];
    if(self.structures && self.structures.count > 0){
        for(PaperStructure *ps in self.structures){
            if(!ps || !ps.code) continue;
            [structureSerialArrays addObject:[ps serializeJSON]];
        }
    }
    return @{__k_paper_fields_code:(self.code ? self.code : @""),
             __k_paper_fields_name:(self.name ? self.name : @""),
             __k_paper_fields_desc:(self.desc ? self.desc : @""),
             __k_paper_fields_sourceName:(self.sourceName ? self.sourceName : @""),
             __k_paper_fields_areaName:(self.areaName ? self.areaName : @""),
             __k_paper_fields_type:[NSNumber numberWithInteger:self.type],
             __k_paper_fields_time:[NSNumber numberWithInteger:self.time],
             __k_paper_fields_year:[NSNumber numberWithInteger:self.year],
             __k_paper_fields_score:self.score,
             __k_paper_fields_structures:structureSerialArrays};
}
#pragma mark 序列为JSON字符串
-(NSString *)serialize{
    NSDictionary *dict = [self serializeJSON];
    NSError *err;
    if([NSJSONSerialization isValidJSONObject:dict]){
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&err];
        if(err){
            NSLog(@"PaperReview SerializeError:%@",err);
            return nil;
        }
        if(data && data.length > 0){
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}
#pragma mark 回收内存
-(void)dealloc{
    if(_itemsCache && _itemsCache.count > 0){
        [_itemsCache removeAllObjects];
    }
}
@end


//试卷结构字段
#define __k_paperstructure_fields_code @"id"//试卷结构ID
#define __k_paperstructure_fields_title @"title"//试卷结构标题
#define __k_paperstructure_fields_desc @"description"//试卷结构描述
#define __k_paperstructure_fields_typeName @"typeName"//题型名称
#define __k_paperstructure_fields_type @"type"//题型值
#define __k_paperstructure_fields_total @"total"//试题总数
#define __k_paperstructure_fields_score @"score"//每题得分
#define __k_paperstructure_fields_min @"min"//每题最少得分
#define __k_paperstructure_fields_ratio @"ratio"//分数比例
#define __k_paperstructure_fields_orderNo @"orderNo"//排序号
#define __k_paperstructure_fields_items @"items"//试题集合
#define __k_paperstructure_fields_children @"children"//子结构数组集合
//试卷结构类实现
@implementation PaperStructure
#pragma mark 初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        _code = [dict objectForKey:__k_paperstructure_fields_code];
        _title = [dict objectForKey:__k_paperstructure_fields_title];
        _desc = [dict objectForKey:__k_paperstructure_fields_desc];
        _typeName = [dict objectForKey:__k_paperstructure_fields_typeName];
        NSNumber *typeNum = [dict objectForKey:__k_paperstructure_fields_type];
        if(typeNum){
            _type = typeNum.integerValue;
        }
        NSNumber *totalNum = [dict objectForKey:__k_paperstructure_fields_total];
        if(totalNum){
            _total = totalNum.integerValue;
        }
        _score = [dict objectForKey:__k_paperstructure_fields_score];
        _min = [dict objectForKey:__k_paperstructure_fields_min];
        _ratio = [dict objectForKey:__k_paperstructure_fields_ratio];
        NSNumber *orderNoNum = [dict objectForKey:__k_paperstructure_fields_orderNo];
        if(orderNoNum){
            _orderNo = orderNoNum.integerValue;
        }
        NSArray *itemArrays = [dict objectForKey:__k_paperstructure_fields_items];
        if(itemArrays && itemArrays.count > 0){
            _items = [PaperItem deSerializeWithArray:itemArrays];
        }
        NSArray *chidArrays = [dict objectForKey:__k_paperstructure_fields_children];
        if(chidArrays && chidArrays.count > 0){
            _children = [PaperStructure deSerializeWithArray:chidArrays];
        }
    }
    return self;
}

#pragma mark 根据JSON字符串初始化
-(instancetype)initWithJSON:(NSString *)json{
    if(!json || json.length == 0)return nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    return [self initWithDictionary:dict];
}
#pragma mark 序列化
-(NSDictionary *)serializeJSON{
    NSMutableArray *itemSerialArrays = [NSMutableArray array],*childSerialArrays = [NSMutableArray array];
    if(self.items && self.items.count > 0){
        for(PaperItem *item in self.items){
            if(!item || !item.code) continue;
            [itemSerialArrays addObject:[item serializeJSON]];
        }
    }
    if(self.children && self.children.count > 0){
        for(PaperStructure *ps in self.children){
            if(!ps || !ps.code) continue;
            [childSerialArrays addObject:[ps serializeJSON]];
        }
    }
    
    return @{__k_paperstructure_fields_code:(self.code ? self.code : @""),
             __k_paperstructure_fields_title:(self.title ? self.title : @""),
             __k_paperstructure_fields_desc:(self.desc ? self.desc : @""),
             __k_paperstructure_fields_typeName:(self.typeName ? self.typeName : @""),
             __k_paperstructure_fields_type:[NSNumber numberWithInteger:self.type],
             __k_paperstructure_fields_total:[NSNumber numberWithInteger:self.total],
             __k_paperstructure_fields_score:self.score,
             __k_paperstructure_fields_min:self.min,
             __k_paperstructure_fields_ratio:self.ratio,
             __k_paperstructure_fields_orderNo:[NSNumber numberWithInteger:self.orderNo],
             __k_paperstructure_fields_items:itemSerialArrays,
             __k_paperstructure_fields_children:childSerialArrays};
}
#pragma mark 静态反序列化
+(NSArray *)deSerializeWithArray:(NSArray *)array{
    if(!array || array.count == 0) return nil;
    NSMutableArray *structureArrays = [NSMutableArray array];
    for(NSDictionary *dict in array){
        if(!dict || dict.count == 0) continue;
        PaperStructure *ps = [[PaperStructure alloc] initWithDictionary:dict];
        if(ps){
            [structureArrays addObject:ps];
        }
    }
    return [structureArrays mutableCopy];
}
#pragma mark 序列化为JSON字符串
-(NSString *)serialize{
    NSDictionary *dict = [self serializeJSON];
    NSError *err;
    if([NSJSONSerialization isValidJSONObject:dict]){
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&err];
        if(err){
            NSLog(@"PaperStructure SerializeError:%@",err);
            return nil;
        }
        if(data && data.length > 0){
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}
@end
//试卷试题字段
#define __k_paperitem_fields_code @"id"//试题ID
#define __k_paperitem_fields_typeName @"typeName"//试题类型
#define __k_paperitem_fields_type @"type"//试题类型值
#define __k_paperitem_fields_content @"content"//试题内容
#define __k_paperitem_fields_answer @"answer"//试题答案
#define __k_paperitem_fields_analysis @"analysis"//试题解析
#define __k_paperitem_fields_level @"level"//试题难度值
#define __k_paperitem_fields_orderNo @"orderNo"//试题排序号
#define __k_paperitem_fields_count @"count"//包含试题总数
#define __k_paperitem_fields_children @"children"//子试题集合
//试卷试题类实现
@implementation PaperItem
#pragma mark 初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        _code = [dict objectForKey:__k_paperitem_fields_code];
        _typeName = [dict objectForKey:__k_paperitem_fields_typeName];
        NSNumber *typeNum = [dict objectForKey:__k_paperitem_fields_type];
        if(typeNum){
            _type = typeNum.integerValue;
        }
        _content = [dict objectForKey:__k_paperitem_fields_content];
        _answer = [dict objectForKey:__k_paperitem_fields_answer];
        _analysis = [dict objectForKey:__k_paperitem_fields_analysis];
        NSNumber *levelNum = [dict objectForKey:__k_paperitem_fields_level];
        if(levelNum){
            _level = levelNum.integerValue;
        }
        NSNumber *orderNoNum = [dict objectForKey:__k_paperitem_fields_orderNo];
        if(orderNoNum){
            _orderNo = orderNoNum.integerValue;
        }
        NSNumber *countNum = [dict objectForKey:__k_paperitem_fields_count];
        if(countNum){
            _count = countNum.integerValue;
        }
        NSArray *childArrays = [dict objectForKey:__k_paperitem_fields_children];
        if(childArrays && childArrays.count > 0){
            _children = [PaperItem deSerializeWithArray:childArrays];
        }
    }
    return self;
}
#pragma mark 初始化
-(instancetype)initWithJSON:(NSString *)json{
    if(!json || json.length == 0) return nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    return [self initWithDictionary:dict];
}
#pragma mark 序列化
-(NSDictionary *)serializeJSON{
    NSMutableArray *childSerialArrays = [NSMutableArray array];
    if(self.children && self.children.count > 0){
        for(PaperItem *item in self.children){
            if(!item || !item.code) continue;
            [childSerialArrays addObject:[item serializeJSON]];
        }
    }
    
    return @{__k_paperitem_fields_code:(self.code ? self.code : @""),
             __k_paperitem_fields_typeName:(self.typeName ? self.typeName : @""),
             __k_paperitem_fields_type:[NSNumber numberWithInteger:self.type],
             __k_paperitem_fields_content:(self.content ? self.content : @""),
             __k_paperitem_fields_answer:(self.answer ? self.answer : @""),
             __k_paperitem_fields_analysis:(self.analysis ?  self.analysis : @""),
             __k_paperitem_fields_level:[NSNumber numberWithInteger:self.level],
             __k_paperitem_fields_orderNo:[NSNumber numberWithInteger:self.orderNo],
             __k_paperitem_fields_count:[NSNumber numberWithInteger:self.count],
             __k_paperitem_fields_children:childSerialArrays};
}
#pragma mark 静态反序列化
+(NSArray *)deSerializeWithArray:(NSArray *)array{
    if(!array || array.count == 0)return nil;
    NSMutableArray *itemArrays = [NSMutableArray array];
    for(NSDictionary *dict in array){
        if(!dict || dict.count == 0) continue;
        PaperItem *item = [[PaperItem alloc] initWithDictionary:dict];
        if(item){
            [itemArrays addObject:item];
        }
    }
    return [itemArrays mutableCopy];
}
#pragma mark 序列化为JSON字符串
-(NSString *)serialize{
    NSDictionary *dict = [self serializeJSON];
    NSError *err;
    if([NSJSONSerialization isValidJSONObject:dict]){
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&err];
        if(err){
            NSLog(@"PaperItem SerializeError:%@",err);
            return nil;
        }
        if(data && data.length > 0){
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}
@end

//试题索引实现
@implementation PaperItemOrderIndexPath
#pragma mark 初始化
-(instancetype)initWithOrder:(NSInteger)order
               StructureCode:(NSString *)code
               StructureTitle:(NSString *)title
                        Item:(PaperItem *)item
                       Index:(NSInteger)index{
    if(self = [super init]){
        _order = order;
        _structureCode = code;
        _structureTitle = title;
        _item = item;
        _index = index;
    }
    return self;
}
#pragma mark 静态初始化
+(instancetype)paperOrder:(NSInteger)order
            StructureCode:(NSString *)code
           StructureTitle:(NSString *)title
                     Item:(PaperItem *)item
                    Index:(NSInteger)index{
    return [[self alloc] initWithOrder:order StructureCode:code StructureTitle:title Item:item Index:index];
}
@end