//
//  UCDBKeyValueObject.m
//  Pods
//
//  Created by baozhou on 2018/10/12.
//
//

#import "UCDBKeyValueObject.h"
#import <LKDBHelper/LKDBHelper.h>

@implementation UCDBKeyValueObject

+ (NSString *)getPrimaryKey{
    return @"dbKey";
}

+ (NSString *)getTableName {
    return @"ucdbKeyValue";
}

+ (BOOL)isContainParent {
    return YES;
}

@end
