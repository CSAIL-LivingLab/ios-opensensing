//
//  OAuthTwoViewController.h
//  OpenSense Collector
//
//  Created by Albert Carter on 11/3/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OAuthTwoViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>

- (IBAction)cancelButton:(id)sender;
- (IBAction)reloadButton:(id)sender;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end
