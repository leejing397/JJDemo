/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseHelper.h                                         *
 *                                                        *
 * hprose helper class header for Objective-C.            *
 *                                                        *
 * LastModified: Jul 15, 2015                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@interface HproseHelper : NSObject

+ (BOOL) isSerializableType:(char)type;
+ (NSDictionary *) getHproseProperties:(Class)cls;
+ (NSString *) getClassName:(Class)cls;
+ (Class) getClass:(NSString *)className;

@end


@interface NSInputStream(HproseHelper)

- (int) readByte;
- (void) readBuffer:(uint8_t *)buffer maxLength:(NSUInteger)length;

@end

@interface NSOutputStream(HproseHelper)

- (NSInteger) writeByte:(uint8_t)b;
- (void) writeBuffer:(const uint8_t *)buffer maxLength:(NSUInteger)length;
- (void) copyFrom:(NSInputStream *)source maxLength:(NSUInteger)length;

@end

