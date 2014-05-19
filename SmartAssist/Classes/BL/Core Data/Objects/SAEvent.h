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

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * majorID;
@property (nonatomic, retain) NSNumber * minorID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * beaconID;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSManagedObject *user;

@end
