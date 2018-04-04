//
//  BlockViewController.m
//  RAC
//
//  Created by Iris on 2018/4/3.
//  Copyright © 2018年 Iris. All rights reserved.
//

#import "BlockViewController.h"

#import "Person.h"

@interface BlockViewController ()
@property(strong ,nonatomic)Person * p;
@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    Person * p = [[Person alloc]init];
    p.run(100);
    
}

-(void)block2{
    Person * p = [[Person alloc]init];
    [p eat:^(NSString * s) {
        NSLog(@"😆%@",s);
    }];
    
}

- (void)block1 {
    Person * p = [[Person alloc]init];
    
    //block  -- inlineBlock
    void(^HKBlock)(void) = ^() {
        NSLog(@"block");
    };
    
    p.block = HKBlock;
    _p = p;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
