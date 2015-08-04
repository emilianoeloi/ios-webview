//
//  ViewController.m
//  ioswebview
//
//  Created by Emiliano Barbosa on 7/31/15.
//  Copyright (c) 2015 Bocamuchas. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ViewController () <UIWebViewDelegate>

@property WebViewJavascriptBridge* bridge;
@property (weak, nonatomic) IBOutlet UITextField *text;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIWebView *webview;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadWebview];
}

-(void)loadWebview{
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_webview webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"Received message from javascript: %@", data);
        responseCallback(@"Right back atcha");
    }];
    
    [self.bridge send:@"Well hello there"];
    [self.bridge send:[NSDictionary dictionaryWithObject:@"Foo" forKey:@"Bar"]];
    [self.bridge send:@"Give me a response, will you?" responseCallback:^(id responseData) {
        NSLog(@"ObjC got its response! %@", responseData);
    }];
    
    NSURL *url = [NSURL URLWithString:_text.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webview loadRequest:request];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark WebView Delegates
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    _text.text = request.URL.absoluteString;
    return YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    _text.text = webView.request.URL.absoluteString;
    
    NSString *javascript = @"document.body.style.webkitTouchCallout='none';";
    
        javascript = [javascript stringByAppendingString:@"function connectWebViewJavascriptBridge(e){window.WebViewJavascriptBridge?e(WebViewJavascriptBridge):document.addEventListener('WebViewJavascriptBridgeReady',function(){e(WebViewJavascriptBridge)},!1)}connectWebViewJavascriptBridge(function(e){e.init(function(e,i){alert('Received message: '+e),i&&i('Right back atcha')}),e.send('Hello from the javascript'),e.send('Please respond to this',function(e){console.log('Javascript got its response',e)})});"];
    
    [webView stringByEvaluatingJavaScriptFromString:javascript];
}

@end
