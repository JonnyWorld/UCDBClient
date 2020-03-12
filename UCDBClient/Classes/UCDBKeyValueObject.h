//
//  UCDBKeyValueObject.h
//  Pods
//
//  Created by baozhou on 2018/10/12.
//
//

#import <Foundation/Foundation.h>

@interface UCDBKeyValueObject : NSObject

@property (copy,nonatomic) NSString *dbKey;
@property (strong,nonatomic) NSDictionary *dbValue;

@end
