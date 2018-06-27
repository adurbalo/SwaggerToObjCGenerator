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

@interface ViewController ()

@property (unsafe_unretained) IBOutlet NSTextView *theTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
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
    self.theTextView.string = [self.theTextView.string?:@"" stringByAppendingFormat:@"%@\n", message];
}

#pragma mark - Actions

- (IBAction)startTapped:(NSButton *)sender
{
    [self logMessage:@"Files generation start 🛫"];
    
    id<Generatable> generatableObject = [[SettingsManager sharedManager] generator];
    Generator *generator = [[Generator alloc] initWithGeneratableObject:generatableObject];
    //[generator start];
    
    [self logMessage:@"Files generation complete 🛬"];
}

- (IBAction)quitTapped:(NSButton *)sender
{
    [[NSApplication sharedApplication] terminate:nil];
}

@end
