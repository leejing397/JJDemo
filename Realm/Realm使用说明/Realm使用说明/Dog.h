//
//  Dog.h
//  Realm使用说明
//
//  Created by Iris on 2018/3/30.
//Copyright © 2018年 Iris. All rights reserved.
//

#import <Realm/Realm.h>

@interface Dog : RLMObject
@property NSString *name;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Dog *><Dog>
RLM_ARRAY_TYPE(Dog)
