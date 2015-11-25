//
//  DownloadDao.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//下载服务器数据
@interface DownloadDao : NSObject

//加载下载试卷的最后时间。
-(NSString *)loadDownloadLastTime;

//下载处理
-(void)downloadWithIgnoreCode:(BOOL)ignoreCode
                    andResult:(void(^)(BOOL,NSString *))handler;
@end
