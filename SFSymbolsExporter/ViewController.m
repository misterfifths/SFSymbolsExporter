#import "ViewController.h"
#import "SFSymbolsExporter.h"


@interface ViewController ()

@property (weak) IBOutlet NSButton *insetsCheckbox;
@property (weak) IBOutlet NSButton *templateCheckbox;
@property (weak) IBOutlet NSColorWell *fillColorWell;
@property (weak) IBOutlet NSTextField *fillColorLabel;

@property (nonatomic, strong) NSColor *previousFillColor;

@end


@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.previousFillColor = self.fillColorWell.color = [NSColor blackColor];
    self.fillColorWell.alphaValue = self.fillColorLabel.alphaValue = 0.5;
}

-(IBAction)templateCheckboxChanged:(id)sender
{
    if(self.templateCheckbox.state == NSControlStateValueOn) {
        self.fillColorWell.enabled = NO;
        self.fillColorWell.alphaValue = self.fillColorLabel.alphaValue = 0.5;
        self.previousFillColor = self.fillColorWell.color;
        self.fillColorWell.color = [NSColor blackColor];
    }
    else {
        self.fillColorWell.enabled = YES;
        self.fillColorWell.alphaValue = self.fillColorLabel.alphaValue = 1;
        self.fillColorWell.color = self.previousFillColor;
    }
}

-(void)saveSymbols:(NSDictionary<NSString *, NSString *> *)symbolsByName
       toDirectory:(NSURL *)directoryURL
{
    BOOL asTemplate = self.templateCheckbox.state == NSControlStateValueOn;
    NSColor *fillColor = asTemplate ? nil : self.fillColorWell.color;
    BOOL includeInsets = self.insetsCheckbox.state == NSControlStateValueOn;

    for(NSString *symbolName in symbolsByName) {
        NSError *err;
        if(![SFSymbolsExporter writeImageSetForSymbolNamed:symbolName
                                               inDirectory:directoryURL
                                                  template:asTemplate
                                                 fillColor:fillColor
                                    includeAlignmentInsets:includeInsets
                                                     error:&err])
        {
            NSLog(@"Error saving symbol named '%@': %@", symbolName, err);
            [self presentError:err];
            return;
        }
    }

    NSAlert *successAlert = [NSAlert new];
    NSImageSymbolConfiguration *symbolConf = [NSImageSymbolConfiguration configurationWithHierarchicalColor:[NSColor systemBlueColor]];
    successAlert.icon = [[NSImage imageWithSystemSymbolName:@"hand.thumbsup" accessibilityDescription:nil] imageWithSymbolConfiguration:symbolConf];
    successAlert.messageText = @"Success!";
    successAlert.informativeText = [NSString stringWithFormat:@"Exported %zu icons to %s", symbolsByName.count, directoryURL.fileSystemRepresentation];
    successAlert.alertStyle = NSAlertStyleInformational;
    [successAlert beginSheetModalForWindow:self.view.window completionHandler:nil];
}

-(void)handleDragOfSymbols:(NSDictionary<NSString *, NSString *> *)symbolsByName
{
    [NSApp activateIgnoringOtherApps:YES];

    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = YES;
    panel.message = @"Select a directory to save the symbols.";
    panel.prompt = @"Export";

    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if(result != NSModalResponseOK)
            return;

        [self saveSymbols:symbolsByName toDirectory:panel.URL];
    }];
}

@end
