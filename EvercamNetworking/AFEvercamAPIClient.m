// AFEvercamAPIClient.h
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFEvercamAPIClient.h"

static NSString * const AFEverCamAPIBaseURLString = @"https://api.evercam.io/v1/";


@implementation AFEvercamAPIClient

+ (instancetype)sharedClient {
    static AFEvercamAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFEvercamAPIClient alloc] initWithBaseURL:[NSURL URLWithString:AFEverCamAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSMutableIndexSet* codes = [NSMutableIndexSet indexSet];
        [codes addIndex:CODE_OK];
        [codes addIndex:CODE_CREATE];
        [codes addIndex:CODE_UNAUTHORISED];
        [codes addIndex:CODE_FORBIDDEN];
        [codes addIndex:CODE_ERROR];
        [codes addIndex:CODE_NOT_FOUND];
        [codes addIndex:CODE_CONFLICT];
        [codes addIndex:CODE_SERVER_ERROR];
        
        _sharedClient.responseSerializer.acceptableStatusCodes = codes;
    });
    
    return _sharedClient;
}

- (NSString *)baseUrl {
    return AFEverCamAPIBaseURLString;
}

@end
