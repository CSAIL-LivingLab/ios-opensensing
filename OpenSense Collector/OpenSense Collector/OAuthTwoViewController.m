//
//  OAuthTwoViewController.m
//  OpenSense Collector
//
//  Created by Albert Carter on 11/3/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import "OAuthTwoViewController.h"

@interface OAuthTwoViewController ()
@property (strong, atomic) NSString *urlString;

@end

@implementation OAuthTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void) viewWillAppear:(BOOL)animated{
    // prep the request and send it to web view
    self.webView.delegate = self;
    [self prepUrl];
    NSLog(@"----\n%@\n-----", self.urlString);
    NSURLRequest *theRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:theRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    // extract the bearer token from the url
    NSString *js = @"/access_token/.test(document.URL)";
    
    NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:js];
    
    NSString *url = [self.webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    
    
    NSLog(@"----\n%@\n-----", url);
    
    //    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    //    NSLog(@"html:----\n%@", html);
    
    if ([result isEqualToString:@"true"]){
        // extract url
        NSString *extractJS = @"document.URL.match(/(access_token\\=)([\\d|a-zA-Z]*)/)[2]";
        NSString *bearer_token = [self.webView stringByEvaluatingJavaScriptFromString:extractJS];
        NSLog(@"extractJS = %@", bearer_token);
        
        // save the bearer token
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:bearer_token forKey:@"bearer_token"];
        [defaults synchronize];
        
        // let the user know that they logged in
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged in"
                                                        message:@"Thank you for authorizing Living Labs and OpenPDS"
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



# pragma mark Url Prep
- (void) prepUrl{
    NSMutableString * urlStr = [NSMutableString stringWithString:@"https://celldata.media.mit.edu/Shibboleth.sso/Login?target="];
    NSString *escapeStrPrep = [NSString stringWithFormat:@"%@%@%@%@", @"/oauth2/authorize?", @"client_id=", @"1a9e5bcfd53229c546772a17a99cae", @"&response_type=token&redirect_uri="];
    CFStringRef clientStr = (__bridge CFStringRef) escapeStrPrep;
    
    CFStringRef redirectUriStr = CFSTR("https://celldata.media.mit.edu/redirect_uri");
    
    NSString *encodedClientStr = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(
                                                                                               kCFAllocatorDefault,
                                                                                               clientStr,
                                                                                               NULL,
                                                                                               CFSTR(":/?#[]@!$&'()*+,;="),
                                                                                               kCFStringEncodingUTF8);
    CFStringRef encodedRedirectUriStr = CFURLCreateStringByAddingPercentEscapes(
                                                                                kCFAllocatorDefault,
                                                                                redirectUriStr,
                                                                                NULL,
                                                                                CFSTR(":/?#[]@!$&'()*+,;="),
                                                                                kCFStringEncodingUTF8);
    NSString * doubleEncodedRedirectUriStr = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(
                                                                                                           kCFAllocatorDefault,
                                                                                                           encodedRedirectUriStr,
                                                                                                           NULL,
                                                                                                           CFSTR(":/?#[]@!$&'()*+,;="),
                                                                                                           kCFStringEncodingUTF8);
    
    NSArray *urlStrArr = [[NSArray alloc] initWithObjects:urlStr, encodedClientStr, doubleEncodedRedirectUriStr, nil];
    self.urlString= [urlStrArr componentsJoinedByString:@""];
}


# pragma mark UI Actions
- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    // dismiss the view, and then dismiss the user back to the home scree, since they didn't log in.
    // the original property, parentViewController doesn't set, so another one is passed. - ARC 2014-09-05
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)reloadButton:(id)sender {
    NSLog(@"reload clicked");
    [self.webView reload];
}

@end
