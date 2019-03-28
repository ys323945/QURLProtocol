//
//  QURLProtocol.h
//  QinzURL
//
//  Created by Qinz on 2019/3/28.
//  Copyright © 2019 Qinz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QURLProtocol : NSURLProtocol<NSURLSessionDataDelegate>

+ (void)hookNSURLSessionConfiguration;

@end

NS_ASSUME_NONNULL_END
