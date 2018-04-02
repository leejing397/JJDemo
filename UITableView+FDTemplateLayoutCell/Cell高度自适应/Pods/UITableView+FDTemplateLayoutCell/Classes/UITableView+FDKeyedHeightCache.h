// The MIT License (MIT)
//
// Copyright (c) 2015-2016 forkingdog ( https://github.com/forkingdog )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//特此免费授予任何人获得本软件及相关文档文件（“软件”）的副本，以不受限制地处理本软件，包括但不限于使用，复制，修改和合并 ，发布，分发，再许可和/或销售本软件的副本，并允许本软件提供给其的人员遵守以下条件：
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//上述版权声明和本许可声明应包含在本软件的所有副本或主要部分中。
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//本软件按“原样”提供，不附有任何形式的明示或暗示保证，包括但不限于适销性，适用于特定用途和不侵权的保证。 在任何情况下，作者或版权所有者都不承担任何索赔，损害或其他责任，无论是在合同，侵权或其他方面的行为，不论是由软件或其使用或其他交易引起或与之相关的行为。 软件。
#import <UIKit/UIKit.h>

@interface FDKeyedHeightCache : NSObject
//判断缓存中是否存在key为值的缓存高度
- (BOOL)existsHeightForKey:(id<NSCopying>)key;
//对指定key的cell设置高度为height
- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key;
//从缓存中获取对应key的cell的高度height值
- (CGFloat)heightForKey:(id<NSCopying>)key;

// Invalidation
//从缓存中删除指定key的cell的值
- (void)invalidateHeightForKey:(id<NSCopying>)key;
//移除缓存中所有的cell的高度缓存值
- (void)invalidateAllHeightCache;
@end

@interface UITableView (FDKeyedHeightCache)

/// Height cache by key. Generally, you don't need to use it directly.
@property (nonatomic, strong, readonly) FDKeyedHeightCache *fd_keyedHeightCache;
@end
