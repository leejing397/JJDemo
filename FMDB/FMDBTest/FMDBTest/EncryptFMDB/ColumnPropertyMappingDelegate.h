

#import <Foundation/Foundation.h>

//实现数据库列名到model属性名的映射
@protocol ColumnPropertyMappingDelegate <NSObject>

@required
- (NSDictionary *)columnPropertyMapping;

@end
