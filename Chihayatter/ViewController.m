//
//  ViewController.m
//  Chihayatter
//
//  Created by Tomonori Ohba on 2015/04/19.
//  Copyright (c) 2015年 Tomonori Ohba. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
- (IBAction)postButtonOnTouch:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Text入力エリアに枠を付ける
    self.tweetText.layer.borderColor = [UIColor purpleColor].CGColor;
    self.tweetText.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postButtonOnTouch:(id)sender {
    // Social Framework
    // iOS上でアカウント設定されているか確認
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ツイートエラー"
                                                        message:@"Twitterアカウントが設定されていません。"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    // iOS上のアカウント設定からTwitterアカウントを取得する
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // iOS上のTwitterアカウントに対し、アプリからのアクセス許可をもらう
    [accountStore
     requestAccessToAccountsWithType:accountType
     options:nil
     completion:^(BOOL granted, NSError *error) {
         // アクセス許可がOKなら投稿
         if (granted) {
             NSArray *accountArray = [accountStore accountsWithAccountType:accountType];
             if (accountArray.count > 0) {
                 // Twitter POSTのURL
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];                 
                 // POSTパラメタを生成する
                 NSDictionary *params = [NSDictionary dictionaryWithObject:self.tweetText.text forKey:@"status"];
                 // Twitter POST用のリクエストを生成
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodPOST
                                                                   URL:url
                                                            parameters:params];
                 // 最初に取得できたTwitterアカウントを使う（暫定）
                 // 複数設定できるので、本当は事前にどのアカウントを使うか、アプリで設定出来た方がいい
                 [request setAccount:[accountArray objectAtIndex:0]];
                 // Twitter POST
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                     NSLog(@"responseData=%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                 }];
             }
         }
     }];
    
}
@end
