//
//  ViewController.m
//  OpenAPItoObjC_CodeGen
//
//  Created by Andrey Durbalo on 6/27/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "ViewController.h"
#import "SettingsManager.h"
#import "Generator.h"
#import "Constants.h"

@interface ViewController ()

@property (unsafe_unretained) IBOutlet NSTextView *theTextView;
@property (weak) IBOutlet NSTextField *destinationPathTextField;
@property (weak) IBOutlet NSTextField *prefixTextField;
@property (weak) IBOutlet NSTextField *contentPathTextField;
@property (weak) IBOutlet NSTextField *contentURLTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateContent];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)logMessage:(NSString *)message
{
    if (message.length == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.theTextView.string = [self.theTextView.string?:@"" stringByAppendingFormat:@"%@\n", message];
    });
}

- (void)updateContent
{
    self.destinationPathTextField.stringValue = [SettingsManager sharedManager].destinationPath ? : @"";
    self.prefixTextField.stringValue = [SettingsManager sharedManager].prefix ? : @"";
    self.contentPathTextField.stringValue = [SettingsManager sharedManager].contentPath ? : @"";
    self.contentURLTextField.stringValue = [SettingsManager sharedManager].contentURL ? : @"";
}

- (void)setupConfiguration
{
    [SettingsManager sharedManager].destinationPath = [self.destinationPathTextField.stringValue stringByTrimmingCharactersInSet:
                                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SettingsManager sharedManager].prefix = [self.prefixTextField.stringValue stringByTrimmingCharactersInSet:
    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SettingsManager sharedManager].contentPath = [self.contentPathTextField.stringValue stringByTrimmingCharactersInSet:
    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SettingsManager sharedManager].contentURL = [self.contentURLTextField.stringValue stringByTrimmingCharactersInSet:
    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Notifications

- (void)subscribeToNotifications:(BOOL)subscribe
{
    if (subscribe) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:NotifyLogMessageNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)handleNotification:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]]) {
        [self logMessage:notification.object];
    }
}

#pragma mark - Actions

- (IBAction)startTapped:(NSButton *)sender
{
    [self subscribeToNotifications:YES];
    
    notifyLog(@"Files generation start 🛫");
    
    [self setupConfiguration];
   
    id<Generatable> generatableObject = [[SettingsManager sharedManager] generator];
    Generator *generator = [[Generator alloc] initWithGeneratableObject:generatableObject];
    [generator start];
    
    notifyLog(@"Files generation complete 🛬");
    
    [self subscribeToNotifications:NO];
}

- (IBAction)quitTapped:(NSButton *)sender
{
    [[NSApplication sharedApplication] terminate:nil];
}

@end
