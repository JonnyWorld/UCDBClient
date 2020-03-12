//
//  UCDBClient.m
//  Pods
//
//  Created by baozhou on 2018/10/12.
//
//

#import "UCDBClient.h"

#import <YYTools/Tools.h>

@implementation UCDBClient

//耗时操作放在异步队列，具体根据情况
static dispatch_queue_t db_queue()
{
    static dispatch_queue_t db_queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        db_queue = dispatch_queue_create("com.uccar.dbclient", NULL);
    });
    return db_queue;
}

//注册数据库文件名字
+ (void)registerDBName:(NSString *)fileName {
    [[self getUsingLKDBHelper] setDBName:fileName];
}

#pragma mark - KeyValue
/** 针对单个key进行存储，类似NSUserDefault */

//将值存入数据库，可以是基本数据类型，也可以是对象
+ (void)saveToDBWithValue:(id)value forKey:(NSString *)key {
    if(key && key.length>0){
        dispatch_async(db_queue(), ^{
            UCDBKeyValueObject *kvObject = [UCDBKeyValueObject new];
            kvObject.dbKey = key;
            if(value){
                kvObject.dbValue = @{@"dbValue":value};
                [kvObject updateToDB];
            } else {
                NSLog(@"value is null when save to db.");
            }
        });
    } else {
        NSLog(@"key is empty when save to db.");
    }
}

+ (void)saveToDBWithValue:(id)value forKey:(NSString *)key completed:(void (^)(void))completedBlock {
    if(key && key.length>0 && value){
        dispatch_async(db_queue(), ^{
            UCDBKeyValueObject *kvObject = [UCDBKeyValueObject new];
            kvObject.dbKey = key;
            kvObject.dbValue = @{@"dbValue":value};
            
            [UCDBKeyValueObject insertArrayByAsyncToDB:@[kvObject] completed:^(BOOL allInserted) {
                if (completedBlock && allInserted) {
                    [Tools runMainThread:^{
                        completedBlock();
                    }];
                }
            }];
        });
    } else {
        NSLog(@"key or value is empty when save to db.");
        if(completedBlock){
            completedBlock();
        }
    }
}

//根据Key查找值
+ (id)dbValueForKey:(NSString *)key {
    if(key && key.length>0){
        UCDBKeyValueObject *kvObject = [UCDBKeyValueObject searchSingleWithWhere:@{@"dbKey":key} orderBy:nil];
        if(kvObject && kvObject.dbValue){
            return [kvObject.dbValue objectForKey:@"dbValue"];
        }
    } else {
        NSLog(@"key is empty when select from db.");
    }
    return nil;
}

//根据Key移除值
+ (BOOL)removeDBValueForKey:(NSString *)key {
    if(key && key.length>0){
        UCDBKeyValueObject *kvObject = [UCDBKeyValueObject searchSingleWithWhere:@{@"dbKey":key} orderBy:nil];
        return [kvObject deleteToDB];
    }
    return NO;
}

#pragma mark - Subclass keyValue

+ (void)saveToDBWithValue:(id)value forKey:(NSString *)key baseSubClassName:(NSString *)subClassName {
    if(key && key.length>0 && value){
        dispatch_async(db_queue(), ^{
            UCDBKeyValueObject *kvObject = [NSClassFromString(subClassName) new];
            kvObject.dbKey = key;
            kvObject.dbValue = @{@"dbValue":value};
            [kvObject updateToDB];
        });
    } else {
        NSLog(@"key is empty when save to db.");
    }
}

+ (void)saveToDBWithValue:(id)value forKey:(NSString *)key baseSubClassName:(NSString *)subClassName completed:(void (^)(void))completedBlock {
    if(key && key.length>0 && value){
        dispatch_async(db_queue(), ^{
            UCDBKeyValueObject *kvObject = [NSClassFromString(subClassName) new];
            kvObject.dbKey = key;
            kvObject.dbValue = @{@"dbValue":value};
            
            [NSClassFromString(subClassName) insertArrayByAsyncToDB:@[kvObject] completed:^(BOOL allInserted) {
                if (completedBlock && allInserted) {
                    [Tools runMainThread:^{
                        completedBlock();
                    }];
                }
            }];
        });
    } else {
        NSLog(@"key or value is empty when save to db.");
    }
}

//根据Key查找值
+ (id)dbValueForKey:(NSString *)key baseSubClassName:(NSString *)subClassName {
    if(key && key.length>0){
        UCDBKeyValueObject *kvObject = [NSClassFromString(subClassName) searchSingleWithWhere:@{@"dbKey":key} orderBy:nil];
        if(kvObject && kvObject.dbValue){
            return [kvObject.dbValue objectForKey:@"dbValue"];
        }
    } else {
        NSLog(@"key is empty when select from db.");
    }
    return nil;
}

//根据Key移除值
+ (BOOL)removeDBValueForKey:(NSString *)key baseSubClassName:(NSString *)subClassName {
    if(key && key.length>0){
        UCDBKeyValueObject *kvObject = [NSClassFromString(subClassName) searchSingleWithWhere:@{@"dbKey":key} orderBy:nil];
        return [kvObject deleteToDB];
    }
    return NO;
}

#pragma mark - Single Object

/** 针对单个对象，进行增删改查, */

//将单个对象，作为独立的表存在，表名就是该对象的类名。如果对象存在，则是更新操作。
+ (void)saveToDBWithObject:(NSObject *)object{
    if(object){
        dispatch_async(db_queue(), ^{
            [object updateToDB];
        });
    } else {
        NSLog(@"object is nil when save to db.");
    }
}

+ (void)saveToDBWithObject:(NSObject *)object completed:(void (^)(void))completedBlock{
    if(object){
        dispatch_async(db_queue(), ^{
            [object.class insertArrayByAsyncToDB:@[object] completed:^(BOOL allInserted) {
                if (completedBlock && allInserted) {
                    [Tools runMainThread:^{
                        completedBlock();
                    }];
                }
            }];
        });
    } else {
        NSLog(@"object is nil when save to db.");
    }
}

+ (void)saveToDBWithObjects:(NSArray *)objects className:(NSString *)className completed:(void (^)(void))completedBlock{
    if(objects && objects.count>0){
        dispatch_async(db_queue(), ^{
            [NSClassFromString(className) insertArrayByAsyncToDB:objects completed:^(BOOL allInserted) {
                if (completedBlock && allInserted) {
                    [Tools runMainThread:^{
                        completedBlock();
                    }];
                }
            }];
        });
    } else {
        NSLog(@"object is nil when save to db.");
    }
}

//查询单个对象
+ (NSObject *)dbObjectWithClassName:(NSString *)classname propertyName:(NSString *)propertyName propertyValue:(id)value {
    if(!(propertyName && propertyName.length>0)) {
        NSLog(@"propertyName is empty when select from db.");
        return nil;
    }
    
    if(!value) {
        NSLog(@"value is empty when select from db.");
        return nil;
    }
    
    return [NSClassFromString(classname) searchSingleWithWhere:@{propertyName:value} orderBy:nil];
}

//查询所有对象
+ (NSArray *)dbObjectsWithClassName:(NSString *)classname {
    return [NSClassFromString(classname) searchWithWhere:nil];
}

//根据条件，查询多个对象
+ (NSArray *)dbObjectsWithClassName:(NSString *)classname where:(id)where orderBy:(NSString *)orderBy offset:(NSInteger)offset count:(NSInteger)count{
    
    return [NSClassFromString(classname) searchWithWhere:where orderBy:orderBy offset:offset count:count];
}

//删除对象
+ (BOOL)removeDBObject:(NSObject *)object {
    return [object deleteToDB];
}

//移除所有对象数据
+ (BOOL)removeObjectsForClassName:(NSString *)className {
    return [NSClassFromString(className) deleteWithWhere:nil];
}

//查询表数据数目
+ (NSInteger)countWithClassName:(NSString *)className where:(NSString *)where {
    return [NSClassFromString(className) rowCountWithWhere:where];
}

//查询是否存在数据库
+ (BOOL)isExistFromDBWithObject:(NSObject *)object {
    return [object isExistsFromDB];
}

@end
