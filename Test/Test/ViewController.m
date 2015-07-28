//
//  ViewController.m
//  Test
//
//  Created by 姚犇 on 15/6/6.
//  Copyright (c) 2015年 姚犇. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"
#import "UMUUploaderManager.h"
#import "NSString+NSHash.h"
#import "NSString+Base64Encode.h"
#import "UIImageView+WebCache.h"
#import "HZPhotoBrowser.h"

@interface ViewController ()<NSXMLParserDelegate,HZPhotoBrowserDelegate>
@property (nonatomic, strong)  UIProgressView *propressView;
@property (nonatomic, copy)  NSString *xmlelement;
@property (nonatomic, strong)  NSMutableArray *arrays;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    _arrays = [NSMutableArray array];
    _arrays = [@[@"http://ww2.sinaimg.cn/thumbnail/98719e4agw1e5j49zmf21j20c80c8mxi.jpg",
                @"http://ww2.sinaimg.cn/thumbnail/67307b53jw1epqq3bmwr6j20c80axmy5.jpg",
                @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
                @"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif",
                @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg",
                @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg",
                @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
                @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
                @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg",
                @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg",
                @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",
                @"http://ww2.sinaimg.cn/thumbnail/677febf5gw1erma104rhyj20k03dz16y.jpg",
                @"http://ww4.sinaimg.cn/thumbnail/677febf5gw1erma1g5xd0j20k0esa7wj.jpg",
                ] mutableCopy];
//    self.propressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
//    self.propressView.frame = CGRectMake(20, 80, 280, 40);
//    [self.view addSubview:self.propressView];
    
    NSString *strPathXml = [[NSBundle mainBundle] pathForResource:@"parenting_content_table" ofType:@"xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:strPathXml];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser setDelegate:self];
//    [parser parse];
}

- (IBAction)jump:(id)sender
{
//    TestViewController *vc = [[TestViewController alloc] init];
//    [self presentViewController:vc animated:YES completion:nil];
    NSString * url = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpeg"];
    NSData * fileData = [NSData dataWithContentsOfFile:url];
    NSDictionary * fileInfo = [UMUUploaderManager fetchFileInfoDictionaryWith:fileData];//获取文件信息
    
    NSDictionary * signaturePolicyDic =[self constructingSignatureAndPolicyWithFileInfo:fileInfo];
    
    NSString * signature = signaturePolicyDic[@"signature"];
    NSString * policy = signaturePolicyDic[@"policy"];
    NSString * bucket = signaturePolicyDic[@"bucket"];
    
    __weak typeof(self)weakSelf = self;
    UMUUploaderManager * manager = [UMUUploaderManager managerWithBucket:bucket];
    [manager uploadWithFile:fileData policy:policy signature:signature progressBlock:^(CGFloat percent, long long requestDidSendBytes) {
        NSLog(@"%f",percent);
        weakSelf.propressView.progress = percent;
    } completeBlock:^(NSError *error, NSDictionary *result, BOOL completed) {
        UIAlertView * alert;
        if (completed) {
            alert = [[UIAlertView alloc]initWithTitle:@"" message:@"上传成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            NSData *data = (NSData *)result;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@\n%@",[result class],dict);
        }else {
            alert = [[UIAlertView alloc]initWithTitle:@"" message:@"上传失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            NSLog(@"%@",error);
        }
        [alert show];
        
    }];
}

/**
 *  根据文件信息生成Signature\Policy\bucket (安全起见，以下算法应在服务端完成)
 *
 *  @param paramaters 文件信息
 *
 *  @return
 */
- (NSDictionary *)constructingSignatureAndPolicyWithFileInfo:(NSDictionary *)fileInfo
{
#warning 您需要加上自己的bucket和secret
    NSString * bucket = @"mudboy";
    NSString * secret = @"MYwqHVMy4NG3cZf1j+1hmVVg6dA=";
    
    NSMutableDictionary * mutableDic = [[NSMutableDictionary alloc]initWithDictionary:fileInfo];
    [mutableDic setObject:@(ceil([[NSDate date] timeIntervalSince1970])+60) forKey:@"expiration"];//设置授权过期时间
    [mutableDic setObject:[NSString stringWithFormat:@"/test1/%@.jpeg",@"fileName"] forKey:@"path"];//设置保存路径
    /**
     *  这个 mutableDic 可以塞入其他可选参数 见：http://docs.upyun.com/api/form_api/#Policy%e5%86%85%e5%ae%b9%e8%af%a6%e8%a7%a3
     */
    NSString * signature = @"";
    NSArray * keys = [mutableDic allKeys];
    keys= [keys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString * key in keys) {
        NSString * value = mutableDic[key];
        signature = [NSString stringWithFormat:@"%@%@%@",signature,key,value];
    }
    signature = [signature stringByAppendingString:secret];
    
    return @{@"signature":[signature MD5],
             @"policy":[self dictionaryToJSONStringBase64Encoding:mutableDic],
             @"bucket":bucket};
}

- (NSString *)dictionaryToJSONStringBase64Encoding:(NSDictionary *)dic
{
    id paramesData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:paramesData
                                                 encoding:NSUTF8StringEncoding];
    return [jsonString base64encode];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _xmlelement = [[NSString alloc] initWithString:elementName];
    //xmlelement为XML元素节点(xmlelement为字符串变量，是在.h文件中定义的。)
    NSLog(@"didStartElement parser:%@\n elementName:%@\n namespaceURI:%@\n qName:%@\n attributeDict:%@",parser,elementName,namespaceURI,qName,attributeDict);
    if ([elementName isEqual:@"item"]) {
        if (attributeDict) {
//            [_arrays addObject:attributeDict];
        }
    }
//    NSLog(@"_arrays:%@",_arrays);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//    if ([_xmlelement isEqualToString:@"START_TIME"]) {
//        [ywKPI.times addObject:[string substringToIndex:10]];
//    }
//    //START_TIME XML文件内容节点，ywKPI.times 数组对象，string xml文件START_TIME 节点值。 以下类似。
//    if ([_xmlelement isEqualToString:@"REGION_USERLABEL"]) {
//        [ywKPI.citys addObject:string];
//    }
//    if ([_xmlelement isEqualToString:@"BHTIME_CS"]) {
//        [ywKPI.dlymss addObject:string];
//    }
//    if ([_xmlelement isEqualToString:@"BHTIME_PS"]) {
//        [ywKPI.fzymss addObject:string];
//    }
//    if ([_xmlelement isEqualToString:@"GSM_NET_RATE"]) {
//        NSString *gsmwljtl =[[NSString alloc]initWithFormat: @"%@%@",[NSString stringWithFormat:@"%.2f",[string floatValue]],@"%"];
//        [ywKPI.gsmwljtls addObject:gsmwljtl];   
//    }
    NSLog(@"foundCharacters parser:%@\n string:%@",parser,string);
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
//    _xmlelement = nil;
    NSLog(@"didEndElement elementName:%@\n namespaceURI:%@\n qName:%@",elementName,namespaceURI,qName);
    //xmlelement为字符串变量，是在.h文件中定义的。
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierCell = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCell forIndexPath:indexPath];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:10];
    image.contentMode = UIViewContentModeCenter;
    image.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageBrowser:)];
    [image addGestureRecognizer:tap];
    [image sd_setImageWithURL:[NSURL URLWithString:_arrays.firstObject]];
    
    return cell;
}

- (void)imageBrowser:(UITapGestureRecognizer *)tap
{
//    UIImageView *iamge = (UIImageView *)tap.view;
    UITableViewCell *cell = (UITableViewCell *)tap.view.superview.superview;
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    
    HZPhotoBrowser *browser = [[HZPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = cell; // 原图的父控件
    NSArray *images = self.arrays;
    browser.imageCount = images.count; // 图片总数
    browser.currentImageIndex = 0;
    browser.delegate = self;
    
    [cell.window.rootViewController presentViewController:browser animated:NO completion:nil];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    //    UITableViewCell *cell = (UITableViewCell *)browser.sourceImagesContainerView;
    //    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //    NSArray *images = self.drops[indexPath.row][@"images"];
    //    UIImageView *image = (UIImageView *)[cell viewWithTag:74];
    //    return image.image;
    return nil;
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    UITableViewCell *cell = (UITableViewCell *)browser.sourceImagesContainerView;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    NSString *urlStr = self.arrays[index];
    NSString *urlStr = [self.arrays[index] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    //    NSString *urlStr = [[self.drops[index] thumbnail_pic] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    return [NSURL URLWithString:urlStr];
}


@end
