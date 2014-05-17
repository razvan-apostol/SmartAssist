//
//  SAEvent.h
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SAEvent : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSString * majorID;
@property (nonatomic, retain) NSString * minorID;
@property (nonatomic, retain) NSManagedObject *user;

@end
