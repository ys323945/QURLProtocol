//
//  WebViewVC.m
//  QinzURL
//
//  Created by Qinz on 2019/3/28.
//  Copyright © 2019 Qinz. All rights reserved.
//

#import "WebViewVC.h"
#import "QURLProtocol.h"

@interface WebViewVC ()<NSURLSessionDataDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation WebViewVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSURLProtocol registerClass:[QURLProtocol class]];
    [QURLProtocol hookNSURLSessionConfiguration];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]];
    [self.webView loadRequest:request];

}



@end
