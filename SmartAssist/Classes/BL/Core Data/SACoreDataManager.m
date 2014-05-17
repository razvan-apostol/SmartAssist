//
//  SACoreDataManager.m
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

/**
 * \brief SACoreDataManager ... Handles basic database operations like : Add, Retrieve and Delete Data
 */

#import "SACoreDataManager.h"

#define CORE_DATA_MAIN_TABLE @"Application"

//Set the name of your xcdatamodeld file
NSString* const kCoreDataModelFileName = @"SmartAssist";

//Set the name of the sqlite file in which CoreData will persist information
NSString* const kSqliteFileName = @"WKApplication.sqlite";


@interface SACoreDataManager ()
@end

/**
 *
 */
@implementation SACoreDataManager

{
    dispatch_queue_t _async_queries_queue;
}

static SACoreDataManager *_coreDataManager = nil;
+ (SACoreDataManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _coreDataManager = [[self alloc] init];
    });
    
    return _coreDataManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self managedObjectContext];
        _async_queries_queue = dispatch_queue_create("com.WhiteKnight.async_queries_queue", NULL);
    }
    return self;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kCoreDataModelFileName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator != nil) {
		return _persistentStoreCoordinator;
	}
	
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSqliteFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        
        //TODO:Preload existing data here is needed
        /*
         NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ContactsLoading" ofType:@"sqlite"]];
         NSError* err = nil;
         
         if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
         NSLog(@"Oops, could copy preloaded data");
         }*/
    }
    
    NSError *error = nil;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark - Delete data

- (void)cleanupDatabaseWithCompletion:(dispatch_block_t)completion
{
	dispatch_async(_async_queries_queue, ^{
		// Create new managed object context
		NSManagedObjectContext *context = [self getNewManagedObjectContext];
		
		// Add here code
		
		// Commit changes
		NSError *err = nil;
		[context save:&err];
		
		// Notify completion
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), completion);
		}
	});
}

- (void)cleanLocalDataBase {
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
    
    //Delete core data
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kSqliteFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
}

- (void)deleteAllObjectsFromTable:(NSString *)tableName withPredicate:(NSPredicate*)predicate{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [_managedObjectContext deleteObject:managedObject];
    }
}

#pragma mark - Get data

- (NSArray*)fetchDataWithParameterBlock:(ParameterBlock)parameterBlock andTableName:(NSString*)tableName inObjectContext:(NSManagedObjectContext*)managedObjectContext{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    parameterBlock(fetchRequest);
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) NSLog(@"Fetch request failed");
    else return array;
    
    return nil;
}

- (NSArray*)fetchDataWithParameterBlock:(ParameterBlock)parameterBlock andTableName:(NSString*)tableName{
    return [self fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
        parameterBlock(requestToBeParametered);
    } andTableName:tableName inObjectContext:self.managedObjectContext];
}

- (void)fetchDataAsyncWithParameterBlock:(ParameterBlock)parameterBlock andTableName:(NSString*)tableName andCompletion:(CompletionBlock)completionBlock{
    
    dispatch_async(_async_queries_queue, ^{
        
        // Create a new managed object context
        // Set its persistent store coordinator
        NSManagedObjectContext *newMoc = [self getNewManagedObjectContext];
        
        NSArray *array = [self fetchDataWithParameterBlock:^(NSFetchRequest *requestToBeParametered) {
            parameterBlock(requestToBeParametered);
        } andTableName:tableName inObjectContext:newMoc];
        
        if (array.count > 0)
            completionBlock(YES,array);
        else completionBlock(NO,array);
    });
}

#pragma mark - Insert data

- (void)insertDataAsync:(NSArray*)dataArray forTableName:(NSString*)tableName withUpdateBlock:(UpdateBlock)updateBlock andCompletion:(CompletionBlock)completionBlock
{
    //The idea begin this is
    //We create a new managed object context from our main, we update it async, then we merge the changes into our main M.O.C
    dispatch_async(_async_queries_queue, ^{
        
        // Create a new managed object context
        // Set its persistent store coordinator
        NSManagedObjectContext *newMoc = [self getNewManagedObjectContext];
        
        // Do the work
        for (int i = 0; i < dataArray.count; i++){
            
            id insertedObject = [self insertDataforTableName:tableName inObjectContext:newMoc];
            id updateData = dataArray[i];
            updateBlock(insertedObject,updateData);
        }
        
        // Call save on context (this will send a save notification and call the method below)
        NSError *error = nil;
        [newMoc save:&error];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        if (error)
            completionBlock(NO,error);
        else completionBlock(YES,nil);
    });
}

- (void)mergeChanges:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

- (id)insertDataforTableName:(NSString *)tableName inObjectContext:(NSManagedObjectContext*)managedObjectContext{
    id managedObject = nil;
    managedObject = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:managedObjectContext];
    return managedObject;
}

- (id)insertDataforTableName:(NSString*)tableName{
    id managedObject = nil;
    managedObject = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
    return managedObject;
}

- (void)save
{
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    
    if (error) NSLog(@"Could not save changes to database: %@, %@", [error localizedDescription], error.userInfo);
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

//We use this method to get all the properties of an abstract object from a dictionary
//We assume the data is a parsed JSON NSDictionary and that our CoreData objects have properties that reflect all it's keys
//For now this works for non collection properties
//TODO: Change the dictionary result as you need it
- (void)updateDBObject:(id)dbObject withDictionary:(NSDictionary*)dictionary
{
    NSArray *keys = [dictionary allKeys];
    
    for (int i = 0; i < keys.count; i++){
        NSString *propertyName = keys[i];
        
        //Check if object has this propery
        NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                               [[propertyName substringToIndex:1] capitalizedString],
                               [propertyName substringFromIndex:1]];
        
        if ([dbObject respondsToSelector:NSSelectorFromString(setterStr)]) {
            [dbObject setValue:dictionary[propertyName] forKey:propertyName];
        }
    }
}

#pragma mark -
#pragma mark - Get a managed object context

- (NSManagedObjectContext *)getNewManagedObjectContext
{
    NSPersistentStoreCoordinator *mainThreadContextStoreCoordinator = [self.managedObjectContext persistentStoreCoordinator];
    
    // Create a new managed object context
    // Set its persistent store coordinator
    NSManagedObjectContext *newMoc = [[NSManagedObjectContext alloc] init];
    [newMoc setPersistentStoreCoordinator:mainThreadContextStoreCoordinator];
    
    // Register for context save changes notification
    NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self
               selector:@selector(mergeChanges:)
                   name:NSManagedObjectContextDidSaveNotification
                 object:newMoc];
    
    return newMoc;
    
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
