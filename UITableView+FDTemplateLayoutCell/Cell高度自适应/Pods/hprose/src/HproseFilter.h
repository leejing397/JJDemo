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
 * HproseFilter.h                                         *
 *                                                        *
 * hprose filter protocol for Objective-C.                *
 *                                                        *
 * LastModified: May 17, 2015                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseContext.h"

@protocol HproseFilter

- (NSData *) inputFilter:(NSData *) data withContext:(HproseContext *) context;
- (NSData *) outputFilter:(NSData *) data withContext:(HproseContext *) context;

@end
