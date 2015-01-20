//
//  LaunchViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface LaunchViewController : UIViewController

//数据管理上下文
@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;


@end
