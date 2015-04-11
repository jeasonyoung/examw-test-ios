//
//  DataSyncService.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//数据同步服务
@interface DataSyncService : NSObject
//忽略注册码
@property(nonatomic,assign)BOOL ignoreCode;
//同步数据
-(void)sync:(void(^)(NSString *))result;
@end
