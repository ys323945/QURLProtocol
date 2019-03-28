//
//  QURLProtocol.m
//  QinzURL
//
//  Created by Qinz on 2019/3/28.
//  Copyright © 2019 Qinz. All rights reserved.
//

#import "QURLProtocol.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString *const QZProtocolKey = @"QZProtocolKey";

@interface QURLProtocol()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLSessionDataTask *task;

@end


@implementation QURLProtocol


+(BOOL)canInitWithRequest:(NSURLRequest *)request{
    
    //已经拦截过就不再进行拦截，避免死循环
    if ([NSURLProtocol propertyForKey:QZProtocolKey inRequest:request]) {
        return NO;
    }
    
    //Hook图片，用于广告过滤等
    NSArray *array = @[@"png", @"jpeg", @"gif", @"jpg"];
    if([array containsObject:request.URL.pathExtension]){
        return YES;
    }
    
    //拦截百度
    if ([[request.URL absoluteString] containsString:@"www.baidu.com"]) {

        return YES;
    }
    return NO;
}

- (void)startLoading{
    
    //标记，下次不拦截自己设置的
    [NSURLProtocol setProperty:@(YES) forKey:QZProtocolKey inRequest:[self.request mutableCopy]];
    
    
    //过滤广告
    NSArray *array = @[@"png",@"jpg",@"jpeg"];
    if ([array containsObject:[self.request.URL pathExtension]]) {
        NSData *data = [self getImageData];
        [self.client URLProtocol:self didLoadData:data];
    }
    
    // 替换百度Logo图片
    if ([[self.request.URL absoluteString] isEqualToString:@"https://m.baidu.com/static/index/plus/plus_logo_web.png"]) {
        NSData *data = [self getImageData];
        [self.client URLProtocol:self didLoadData:data];
    }
    
    //重定向
    if ([[self.request.URL absoluteString] isEqualToString:@"https://www.baidu.com/"]) {
        
        
        NSString*url = @"https://www.jianshu.com/";
        NSURLRequest*myRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        NSURLSessionConfiguration *configuration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        self.queue.name = @"com.Qinz.cn";
        
        NSURLSession *session =
        [NSURLSession sessionWithConfiguration:configuration
                                      delegate:self
                                 delegateQueue:self.queue];
        //偷梁换柱
        self.task = [session dataTaskWithRequest:myRequest];
        [self.task resume];
        
    }
    
}

- (void)stopLoading{
    
    [self.task cancel];
}


#pragma mark - NSURLSessionDataDelegate
// 当服务端返回信息时，这个回调函数会被ULS调用，在这里实现http返回信息的截
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    if ([self.request.URL.absoluteString isEqualToString:@"https://www.baidu.com/"]) {
        
        // 将接收到的数据返回给系统处理
        [self.client URLProtocol:self didLoadData:data];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    if (response != nil){
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}



//返回规范的request
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    
    return request;
}

//调用胡烈即可
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}



#pragma mark - private
- (NSData *)getImageData{
    
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Qinz.jpg" ofType:@""];
    return [NSData dataWithContentsOfFile:fileName];
}


#pragma mark - hook

+ (void)hookNSURLSessionConfiguration{
    
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    
    Method originalMethod = class_getInstanceMethod(cls, @selector(protocolClasses));
    Method stubMethod = class_getInstanceMethod([self class], @selector(protocolClasses));
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"没有这个方法,无法进行交换"];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
}

- (NSArray *)protocolClasses {
    //如果还有其他的监控protocol,可以在这里加进去
    return @[[QURLProtocol class]];
    
}



@end
