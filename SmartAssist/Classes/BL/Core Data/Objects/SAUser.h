//
//  SAUser.h
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SAEvent;

@interface SAUser : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * deviceID;
@property (nonatomic, retain) NSSet *events;
@end

@interface SAUser (CoreDataGeneratedAccessors)

- (void)addEventsObject:(SAEvent *)value;
- (void)removeEventsObject:(SAEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
