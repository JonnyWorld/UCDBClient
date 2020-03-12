//
//  UCDBClient.h
//  Pods
//
//  Created by baozhou on 2018/10/12.
//
//

#import <Foundation/Foundation.h>
#import <LKDBHelper/LKDBHelper.h>
#import "UCDBKeyValueObject.h"

//数据库管理对象增删改查
@interface UCDBClient : NSObject

//注册数据库文件名字，不设置默认数据库名字为LKDB
+ (void)registerDBName:(NSString *)fileName;

#pragma mark - KeyValue
/** 针对单个key进行存储，类似NSUserDefault */

//将值存入数据库，可以是基本数据类型，也可以是对象
+ (void)saveToDBWithValue:(id)value forKey:(NSString *)key;
+ (void)saveToDBWithValue:(id)value forKey:(NSString *)key completed:(void (^)(void))completedBlock;

//根据Key查找值
+ (id)dbValueForKey:(NSString *)key;

//根据Key移除值
+ (BOOL)removeDBValueForKey:(NSString *)key;

#pragma mark - Subclass keyValue
/** 创建UCDBKeyValueObject的子类，并重写getUserHelper来指定数据库进行存储**/
//将值存入数据库，可以是基本数据类型，也可以是对象
+ (void)saveToDBWithValue:(id)value forKey:(NSString *)key baseSubClassName:(NSString *)subClassName;
+ (void)saveToDBWithValue:(id)value forKey:(NSString *)key baseSubClassName:(NSString *)subClassName completed:(void (^)(void))completedBlock;

//根据Key查找值
+ (id)dbValueForKey:(NSString *)key baseSubClassName:(NSString *)subClassName;

//根据Key移除值
+ (BOOL)removeDBValueForKey:(NSString *)key baseSubClassName:(NSString *)subClassName;

#pragma mark - Single Object
/** 针对单个对象，进行增删改查, 同步操作 */
//注意：如果对象指定单独的主键，则需要在对象类声明中重写+ (NSString *)getPrimaryKey这个方法。
//注意：如果对象指定单独的表名，则需要在对象类声明中重写+ (NSString *)getTableName 这个方法。

//将单个对象，作为独立的表存在，表名就是该对象的类名。如果对象存在，则是更新操作。
//注意：保存有延迟
+ (void)saveToDBWithObject:(NSObject *)object;

//以下2个方法为异步保存数据库的方法，用时需考虑清楚
//除非自己知道操作该数据库时是独立的时机，如果有多处时机可能导致同时保存，可考虑上面同步方法
+ (void)saveToDBWithObject:(NSObject *)object completed:(void (^)(void))completedBlock;
+ (void)saveToDBWithObjects:(NSArray *)objects className:(NSString *)className completed:(void (^)(void))completedBlock;

//查询单个对象
+ (NSObject *)dbObjectWithClassName:(NSString *)classname propertyName:(NSString *)propertyName propertyValue:(id)value;

//查询所有对象
+ (NSArray *)dbObjectsWithClassName:(NSString *)classname;

//根据条件，查询多个对象
/**
查找数据（where格式："name = 'zhang'"；orderBy格式：升序 "name asc"，降序 "name desc"；offset偏移量：10表示从第11个开始；count查找数量：10表示查找10个）
 */
+ (NSArray *)dbObjectsWithClassName:(NSString *)classname where:(id)where orderBy:(NSString *)orderBy offset:(NSInteger)offset count:(NSInteger)count;

//删除对象
+ (BOOL)removeDBObject:(NSObject *)object;

//移除所有对象数据
+ (BOOL)removeObjectsForClassName:(NSString *)className;

//查询表数据数目
+ (NSInteger)countWithClassName:(NSString *)className where:(NSString *)where;

//查询是否存在数据库
+ (BOOL)isExistFromDBWithObject:(NSObject *)object;

@end
