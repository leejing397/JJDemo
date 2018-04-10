Masonry

**具体可以看一下`MasonryTest`项目**

###1.Masonry支持的属性

```
@property (nonatomic, strong, readonly) MASConstraint *left;
@property (nonatomic, strong, readonly) MASConstraint *top;
@property (nonatomic, strong, readonly) MASConstraint *right;
@property (nonatomic, strong, readonly) MASConstraint *bottom;
@property (nonatomic, strong, readonly) MASConstraint *leading;
@property (nonatomic, strong, readonly) MASConstraint *trailing;
@property (nonatomic, strong, readonly) MASConstraint *width;
@property (nonatomic, strong, readonly) MASConstraint *height;
@property (nonatomic, strong, readonly) MASConstraint *centerX;
@property (nonatomic, strong, readonly) MASConstraint *centerY;
@property (nonatomic, strong, readonly) MASConstraint *baseline;
```

这些属性与NSLayoutAttrubute的对照表如下:
<table>
<thead>
<tr>
<th style="text-align:left">Masonry</th>
<th style="text-align:left">NSAutoLayout</th>
<th style="text-align:left">说明</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left">left</td>
<td style="text-align:left">NSLayoutAttributeLeft</td>
<td style="text-align:left">左侧</td>
</tr>
<tr>
<td style="text-align:left">top</td>
<td style="text-align:left">NSLayoutAttributeTop</td>
<td style="text-align:left">上侧</td>
</tr>
<tr>
<td style="text-align:left">right</td>
<td style="text-align:left">NSLayoutAttributeRight</td>
<td style="text-align:left">右侧</td>
</tr>
<tr>
<td style="text-align:left">bottom</td>
<td style="text-align:left">NSLayoutAttributeBottom</td>
<td style="text-align:left">下侧</td>
</tr>
<tr>
<td style="text-align:left">leading</td>
<td style="text-align:left">NSLayoutAttributeLeading</td>
<td style="text-align:left">首部</td>
</tr>
<tr>
<td style="text-align:left">trailing</td>
<td style="text-align:left">NSLayoutAttributeTrailing</td>
<td style="text-align:left">尾部</td>
</tr>
<tr>
<td style="text-align:left">width</td>
<td style="text-align:left">NSLayoutAttributeWidth</td>
<td style="text-align:left">宽</td>
</tr>
<tr>
<td style="text-align:left">height</td>
<td style="text-align:left">NSLayoutAttributeHeight</td>
<td style="text-align:left">高</td>
</tr>
<tr>
<td style="text-align:left">centerX</td>
<td style="text-align:left">NSLayoutAttributeCenterX</td>
<td style="text-align:left">横向中点</td>
</tr>
<tr>
<td style="text-align:left">centerY</td>
<td style="text-align:left">NSLayoutAttributeCenterY</td>
<td style="text-align:left">纵向中点</td>
</tr>
<tr>
<td style="text-align:left">baseline</td>
<td style="text-align:left">NSLayoutAttributeBaseline</td>
<td style="text-align:left">文本基线</td>
</tr>
</tbody>
</table>

> 其中l`eading`与`left` `trailing`与`right` 在正常情况下是等价的 
>
但是当一些布局是从右至左时(比如阿拉伯文?没有类似的经验) 则会对调 
>
换句话说就是基本可以不理不用 用`left`和`right`就好了

###2.简单使用
####2.1 居中显示一个`view`

```
UIView *sv = [UIView new];
    sv.backgroundColor = [UIColor redColor];
    [self.view addSubview:sv];
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(300, 300));
    }];
```

![](https://ws4.sinaimg.cn/large/006tNc79gy1fq6e1indnej30ar0jqq3b.jpg)

####2.2 在Masonry中能够添加autolayout约束有三个函数

```
- (NSArray *)mas_makeConstraints:(void(^)(MASConstraintMaker *make))block;
- (NSArray *)mas_updateConstraints:(void(^)(MASConstraintMaker *make))block;
- (NSArray *)mas_remakeConstraints:(void(^)(MASConstraintMaker *make))block;

/*
    mas_makeConstraints 只负责新增约束 Autolayout不能同时存在两条针对于同一对象的约束 否则会报错 
    mas_updateConstraints 针对上面的情况 会更新在block中出现的约束 不会导致出现两个相同约束的情况
    mas_remakeConstraints 则会清除之前的所有约束 仅保留最新的约束
    
    三种函数善加利用 就可以应对各种情况了
*/
```

###3.初级使用
####3.1 让一个view略小于其superView(边距为10)

```
    UIView *sv = [UIView new];
    sv.backgroundColor = [UIColor redColor];
    [self.view addSubview:sv];
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(300, 300));
    }];
    
    UIView *sv1 = [UIView new];
    sv1.backgroundColor = [UIColor blueColor];
    [sv addSubview:sv1];
    [sv1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sv).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
        
        /* 等价于
         make.top.equalTo(sv).with.offset(10);
         make.left.equalTo(sv).with.offset(10);
         make.bottom.equalTo(sv).with.offset(-10);
         make.right.equalTo(sv).with.offset(-10);
         */
        
        /* 也等价于
         make.top.left.bottom.and.right.equalTo(sv).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
         */
    }];
```
运行如图：

![](https://ws4.sinaimg.cn/large/006tNc79gy1fq6ee9ygbfj30ap0j63yu.jpg)

####3.2 让两个高度为150的view垂直居中且等宽且等间隔排列 间隔为10(自动计算其宽度)

```
    UIView *v1 = [[UIView alloc]init];
    v1.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:v1];
    
    UIView *v2 = [[UIView alloc]init];
    v2.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:v2];
    
    [v1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50.0f);
        make.centerY.mas_equalTo(self.view);
        
        make.left.mas_equalTo(self.view).mas_offset(50.0f);
        make.right.mas_equalTo(v2.mas_left).mas_offset(-10.0f);
        make.width.mas_equalTo(v2);
    }];
    
    [v2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50.0f);
        make.centerY.mas_equalTo(self.view);
        make.width.mas_equalTo(v1);
        make.right.mas_equalTo(self.view).mas_offset(-50.0f);
        make.left.mas_equalTo(v1.mas_right).mas_offset(10.0f);
    }];

```
运行如图：
![](https://ws2.sinaimg.cn/large/006tNc79gy1fq6eylkk8nj30z00igtck.jpg)

>这里我们在两个子view之间互相设置的约束 可以看到他们的宽度在约束下自动的被计算出来了

###4.中级使用
####4.1 在UIScrollView顺序排列一些view并自动计算contentSize

```
UIScrollView *scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor redColor];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 20, 50));
    }];
    
    UIView *v1 = [[UIView alloc]init];
    v1.backgroundColor = [UIColor yellowColor];
    [scrollView addSubview:v1];
    [v1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(scrollView);
        make.edges.mas_equalTo(scrollView);
    }];
    
    int count = 10;
    
    UIView *lastView = nil;
    
    for ( int i = 1 ; i <= count ; ++i )
    {
        UIView *subv = [UIView new];
        [v1 addSubview:subv];
        subv.backgroundColor = [UIColor colorWithHue:( arc4random() % 256 / 256.0 )
                                          saturation:( arc4random() % 128 / 256.0 ) + 0.5
                                          brightness:( arc4random() % 128 / 256.0 ) + 0.5
                                               alpha:1];
        
        [subv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(v1);
            make.height.mas_equalTo(@(20*i));
            
            if ( lastView )
            {
                make.top.mas_equalTo(lastView.mas_bottom);
            }
            else
            {
                make.top.mas_equalTo(v1.mas_top);
            }
        }];
        
        lastView = subv;
    }
    
    [v1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastView.mas_bottom);
    }];
```

**运行，图层如下**
![](https://ws1.sinaimg.cn/large/006tNc79ly1fq6feq8xh1j30op0gagme.jpg)

###5.高级使用
####5.1 横向或者纵向等间隙的排列一组view

参考案例3 我们可以通过一个小技巧来实现这个目的 为此我写了一个Category

```
@implementation UIView(Masonry_LJC)

- (void) distributeSpacingHorizontallyWith:(NSArray*)views
{
    NSMutableArray *spaces = [NSMutableArray arrayWithCapacity:views.count+1];
    
    for ( int i = 0 ; i < views.count+1 ; ++i )
    {
        UIView *v = [UIView new];
        [spaces addObject:v];
        [self addSubview:v];
        
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(v.mas_height);
        }];
    }    
    
    UIView *v0 = spaces[0];
    
    [v0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.centerY.equalTo(((UIView*)views[0]).mas_centerY);
    }];
    
    UIView *lastSpace = v0;
    for ( int i = 0 ; i < views.count; ++i )
    {
        UIView *obj = views[i];
        UIView *space = spaces[i+1];
        
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastSpace.mas_right);
        }];
        
        [space mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(obj.mas_right);
            make.centerY.equalTo(obj.mas_centerY);
            make.width.equalTo(v0);
        }];
        
        lastSpace = space;
    }
    
    [lastSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
    }];
    
}

- (void) distributeSpacingVerticallyWith:(NSArray*)views
{
    NSMutableArray *spaces = [NSMutableArray arrayWithCapacity:views.count+1];
    
    for ( int i = 0 ; i < views.count+1 ; ++i )
    {
        UIView *v = [UIView new];
        [spaces addObject:v];
        [self addSubview:v];
        
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(v.mas_height);
        }];
    }
    
    
    UIView *v0 = spaces[0];
    
    [v0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.centerX.equalTo(((UIView*)views[0]).mas_centerX);
    }];
    
    UIView *lastSpace = v0;
    for ( int i = 0 ; i < views.count; ++i )
    {
        UIView *obj = views[i];
        UIView *space = spaces[i+1];
        
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastSpace.mas_bottom);
        }];
        
        [space mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(obj.mas_bottom);
            make.centerX.equalTo(obj.mas_centerX);
            make.height.equalTo(v0);
        }];
        
        lastSpace = space;
    }
    
    [lastSpace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
    }];

}

@end
```

使用

```
UIView *sv11 = [UIView new];
UIView *sv12 = [UIView new];
UIView *sv13 = [UIView new];
UIView *sv21 = [UIView new];
UIView *sv31 = [UIView new];

sv11.backgroundColor = [UIColor redColor];
sv12.backgroundColor = [UIColor redColor];
sv13.backgroundColor = [UIColor redColor];
sv21.backgroundColor = [UIColor redColor];
sv31.backgroundColor = [UIColor redColor];

[sv addSubview:sv11];
[sv addSubview:sv12];
[sv addSubview:sv13];
[sv addSubview:sv21];
[sv addSubview:sv31];

//给予不同的大小 测试效果

[sv11 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(@[sv12,sv13]);
    make.centerX.equalTo(@[sv21,sv31]);
    make.size.mas_equalTo(CGSizeMake(40, 40));
}];

[sv12 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(70, 20));
}];

[sv13 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(50, 50));
}];

[sv21 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(50, 20));
}];

[sv31 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(40, 60));
}];

[sv distributeSpacingHorizontallyWith:@[sv11,sv12,sv13]];
[sv distributeSpacingVerticallyWith:@[sv11,sv21,sv31]];

[sv showPlaceHolderWithAllSubviews];
[sv hidePlaceHolder];

```

