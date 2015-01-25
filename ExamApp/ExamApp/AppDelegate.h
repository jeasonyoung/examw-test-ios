//
//  AppDelegate.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
//应该Window UI
@property (nonatomic,strong) UIWindow *window;
//被管理数据上下文
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
//被管理数据模型
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
//被管理数据持久化
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//保存数据
- (void)saveContext;
//应用程序文档目录URL
- (NSURL *)applicationDocumentsDirectory;
@end