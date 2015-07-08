//
//  MRJavaScriptEventEmitter.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRProperty.h"
#import "MRAdView.h"
#import "MRJavaScriptEventEmitter.h"
#import "WBAdLogging.h"

@interface MRJavaScriptEventEmitter ()

@property (nonatomic) WBAdType logType;
@property (nonatomic, strong) UIWebView *webView;

@end

@interface MRJavaScriptEventEmitter ()
- (NSString *)executeJavascript:(NSString *)javascript withVarArgs:(va_list)args;
@end

@implementation MRJavaScriptEventEmitter

@synthesize webView = _webView;

- (id)initWithWebView:(UIWebView *)webView logType:(WBAdType)logType
{
    self = [super init];
    if (self) {
        _logType = logType;
        _webView = webView;
    }
    return self;
}


- (NSString *)executeJavascript:(NSString *)javascript, ... {
    va_list args;
    va_start(args, javascript);
    NSString *result = [self executeJavascript:javascript withVarArgs:args];
    va_end(args);
    return result;
}

- (void)fireChangeEventForProperty:(MRProperty *)property {
    NSString *JSON = [NSString stringWithFormat:@"{%@}", property];
    [self executeJavascript:@"window.mraidbridge.fireChangeEvent(%@);", JSON];
    AdLogType(WBAdLogLevelTrace, self.logType, @"JSON: %@", JSON);
}

- (void)fireChangeEventsForProperties:(NSArray *)properties {
    NSString *JSON = [NSString stringWithFormat:@"{%@}",
                      [properties componentsJoinedByString:@", "]];
    [self executeJavascript:@"window.mraidbridge.fireChangeEvent(%@);", JSON];
    AdLogType(WBAdLogLevelTrace, self.logType, @"JSON: %@", JSON);
}

- (void)fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message {
    [self executeJavascript:@"window.mraidbridge.fireErrorEvent('%@', '%@');", message, action];
}

- (void)fireReadyEvent {
    [self executeJavascript:@"window.mraidbridge.fireReadyEvent();"];
}

- (void)fireNativeCommandCompleteEvent:(NSString *)command {
    [self executeJavascript:@"window.mraidbridge.nativeCallComplete('%@');", command];
}

- (NSString *)executeJavascript:(NSString *)javascript withVarArgs:(va_list)args {
    NSString *js = [[NSString alloc] initWithFormat:javascript arguments:args];
    return [_webView stringByEvaluatingJavaScriptFromString:js];
}

@end
