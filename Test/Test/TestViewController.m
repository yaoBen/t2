
//
//  TestViewController.m
//  westars
//
//  Created by developer on 15/6/6.
//  Copyright (c) 2015年 westars. All rights reserved.
//

#import "TestViewController.h"

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height -20);
    [self.view addSubview:self.tableView];
    self.tableView.delegate =self;
    self.tableView.dataSource = self;
    NSInteger myInteger = 2;
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathWithIndex:myInteger]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"identifier"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"cell :%d", indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"didSelectRowAtIndexPath");
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touches: %@", touches);
    NSLog(@"event: %@", event);
}
@end
