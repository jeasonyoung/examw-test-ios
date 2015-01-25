//
//  AppDelegate.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppDelegate.h"
#import "LaunchViewController.h"
//应用代理成员
@interface AppDelegate (){
    
}
@end
//应用代理实现类
@implementation AppDelegate
//app开始运行时调用
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //设置Widow的背景颜色
    self.window.backgroundColor = [UIColor whiteColor];
    //设置Window的根控制器
    self.window.rootViewController = [[LaunchViewController alloc] init];
    //启动显示
    [self.window makeKeyAndVisible];
    
//    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
//    controller.managedObjectContext = self.managedObjectContext;
    return YES;
}
//app将进入非激活状态
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
//app恢复激活状态。
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
//app进入后台模式
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
//app将进入前台模式
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
//app将关闭
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack
//应用程序文档目录URL
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.examw.test.ios.ExamApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
//获取数据管理模型
-(NSManagedObjectModel *)getManagedObjectModel{
    if(_managedObjectModel != nil){
        return _managedObjectModel;
    }
    //数据模型文件
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ExamApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
//获取数据持久化
-(NSPersistentStoreCoordinator *)getPersistentStoreCoordinator{
    if(_persistentStoreCoordinator != nil){
        return _persistentStoreCoordinator;
    }
    //初始化数据持久对象
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self getManagedObjectModel]];
    //数据库文件
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ExamApp.sqlite"];
    NSError *err = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&err]){
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = err;
        err = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", err, [err userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}
//获取数据管理上下文
-(NSManagedObjectContext *)getManagedObjectContext{
    if(_managedObjectContext != nil){
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self getPersistentStoreCoordinator];
    if(coordinator == nil) return nil;
    //初始化数据管理上下文
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}
#pragma mark - Core Data Saving support
//保存数据
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
@end