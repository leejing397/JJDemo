//
//  Person.h
//  Realm使用说明
//
//  Created by Iris on 2018/3/30.
//Copyright © 2018年 Iris. All rights reserved.
//

#import <Realm/Realm.h>

@interface Person : RLMObject

@property NSInteger age;
@property NSString *cardID;
@property NSString *weight;
//@property NSString *firstName;
//@property NSString *lastName;
@property NSString * fullName;
@property NSString *email;   // new property
@end


// This protocol enables typed collections. i.e.:
// RLMArray<Person *><Person>
RLM_ARRAY_TYPE(Person)
