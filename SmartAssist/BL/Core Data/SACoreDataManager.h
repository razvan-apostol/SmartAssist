//
//  SACoreDataManager.h
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString* const kSqliteFileName;

@class WKUser;

//Block Defines
typedef void (^CompletionBlock)(BOOL success, id returnObject);
typedef void (^UpdateBlock)(id dbObject,id updateData);
typedef void (^ParameterBlock)(NSFetchRequest* requestToBeParametered);

@interface SACoreDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Methods

+ (SACoreDataManager *)sharedManager;

/**
 * Fetches data from CoreData with custom parameters
 * @param parameterBlock ... with this we can set any parameters to the NSFetchRequest instance
 * @param tableName ... the name of the desired table in the db
 */
- (NSArray *)fetchDataWithParameterBlock:(ParameterBlock)parameterBlock andTableName:(NSString *)tableName;
- (void)fetchDataAsyncWithParameterBlock:(ParameterBlock)parameterBlock andTableName:(NSString *)tableName andCompletion:(CompletionBlock)completionBlock;

/**
 * Adds async an object into the specified table
 * @param dataArray ... the data to be added
 * @param tableName ... the name of the desired table in the db
 * @param updateBlock ...  custom code to fill the newly added object with info from dataArray
 */
- (void)insertDataAsync:(NSArray *)dataArray forTableName:(NSString *)tableName withUpdateBlock:(UpdateBlock)updateBlock andCompletion:(CompletionBlock)completionBlock;

/**
 * Adds an object into the specified table
 * @param tableName ... the name of the desired table in the db
 * @returns newly inserted object
 */
- (id)insertDataforTableName:(NSString *)tableName;

/**
 * Deletes all objects from the specified table
 * @param tableName ... the name of the desired table in the db
 */
- (void)deleteAllObjectsFromTable:(NSString *)tableName withPredicate:(NSPredicate *)predicate;

/**
 * Saves changes in the db
 */
- (void)save;

/**
 * Saves changes in the db if necessary
 */
- (void)saveContext;

/**
 * Init and clean local database
 */
- (void)cleanLocalDataBase;

/**
 * Cleans up the database of objects created earlier than a given time interval
 * @param completion ... the completion block. Called after the completion database cleanup
 */
- (void)cleanupDatabaseWithCompletion:(dispatch_block_t)completion;


@end
