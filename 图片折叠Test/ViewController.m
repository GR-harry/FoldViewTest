//
//  ViewController.m
//  图片折叠Test
//
//  Created by GR on 15/9/18.
//  Copyright © 2015年 GR. All rights reserved.
//

#import "ViewController.h"
#import "PageView2.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet PageView2 *pageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.pageView.image = [UIImage imageNamed:@"avator"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
