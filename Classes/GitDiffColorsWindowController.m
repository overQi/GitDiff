//
//  GitDiffColorsWindowController.m
//  GitDiff
//
//  Created by Allen Wu on 8/17/14.
//
//

#import "GitDiffColorsWindowController.h"

static NSString *const GitDiffModifiedColorKey = @"GitDiffModifiedColor";
static NSString *const GitDiffAddedColorKey    = @"GitDiffAddedColor";
static NSString *const GitDiffDeletedColorKey  = @"GitDiffDeletedColor";
static NSString *const GitDiffPopoverColorKey  = @"GitDiffPopoverColor";
static NSString *const GitDiffChangedColorKey  = @"GitDiffChangedColor";


@interface GitDiffColorsWindowController ()
{
    NSDictionary   *_pluginDefaults;
    NSUserDefaults *_userDefaults;
}

@property (weak) IBOutlet NSColorWell *modifiedColorWell;
@property (weak) IBOutlet NSColorWell *addedColorWell;
@property (weak) IBOutlet NSColorWell *deletedColorWell;
@property (weak) IBOutlet NSColorWell *popoverColorWell;
@property (weak) IBOutlet NSColorWell *changedColorWell;
@end


@implementation GitDiffColorsWindowController

- (instancetype)initWithPluginBundle:(NSBundle *)bundle {

    NSString *nibPath = [bundle pathForResource:@"GitDiff" ofType:@"nib"];
    if (!nibPath) {
        if ( [[NSAlert alertWithMessageText:@"GitDiff Plugin:"
                              defaultButton:@"OK" alternateButton:@"Goto GitHub" otherButton:nil
                  informativeTextWithFormat:@"Could not load colors interface. GitDiff will not work correctly. This is a problem when installing using Alcatraz related to Xcode6. Please download GitDiff and build from the sources on GitHub. This will install the plugin manually."]
              runModal] == NSAlertAlternateReturn )
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/johnno1962/GitDiff"]];
        return nil;
    }
    
    self = [super initWithWindowNibPath:nibPath owner:self];
    if (self)
    {
        NSString *pluginDefaultsPath = [bundle pathForResource:@"Defaults" ofType:@"plist"];
        _pluginDefaults = [NSDictionary dictionaryWithContentsOfFile:pluginDefaultsPath];
        _userDefaults   = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)awakeFromNib {
    [self loadColors];
}


#pragma mark - Actions

- (IBAction)gitDiffColorWellChanged:(id)sender
{
    [self saveColors];
}

- (IBAction)gitDiffColorResetPressed:(id)sender
{
    [self resetColors];
}


#pragma mark - Acessors

- (NSColor *)modifiedColor {
    return [self colorForKey:GitDiffModifiedColorKey];
}

- (NSColor *)addedColor {
    return [self colorForKey:GitDiffAddedColorKey];
}

- (NSColor *)deletedColor {
    return [self colorForKey:GitDiffDeletedColorKey];
}

- (NSColor *)popoverColor {
    return [self colorForKey:GitDiffPopoverColorKey];
}

- (NSColor *)changedColor {
    return [self colorForKey:GitDiffChangedColorKey];
}


#pragma mark - Colors

- (void)resetColors
{
    self.modifiedColorWell.color = [self colorFromPlistString:_pluginDefaults[GitDiffModifiedColorKey]];
    self.addedColorWell.color    = [self colorFromPlistString:_pluginDefaults[GitDiffAddedColorKey]];
    self.deletedColorWell.color  = [self colorFromPlistString:_pluginDefaults[GitDiffDeletedColorKey]];
    self.popoverColorWell.color  = [self colorFromPlistString:_pluginDefaults[GitDiffPopoverColorKey]];
    self.changedColorWell.color  = [self colorFromPlistString:_pluginDefaults[GitDiffChangedColorKey]];
    
    [self saveColors];
}

- (void)loadColors
{
    self.modifiedColorWell.color = [self colorForKey:GitDiffModifiedColorKey];
    self.addedColorWell.color    = [self colorForKey:GitDiffAddedColorKey];
    self.deletedColorWell.color  = [self colorForKey:GitDiffDeletedColorKey];
    self.popoverColorWell.color  = [self colorForKey:GitDiffPopoverColorKey];
    self.changedColorWell.color  = [self colorForKey:GitDiffChangedColorKey];
}

- (void)saveColors
{
    [_userDefaults setObject:[self plistStringFromColor:self.modifiedColorWell.color] forKey:GitDiffModifiedColorKey];
    [_userDefaults setObject:[self plistStringFromColor:self.addedColorWell.color] forKey:GitDiffAddedColorKey];
    [_userDefaults setObject:[self plistStringFromColor:self.deletedColorWell.color] forKey:GitDiffDeletedColorKey];
    [_userDefaults setObject:[self plistStringFromColor:self.popoverColorWell.color] forKey:GitDiffPopoverColorKey];
    [_userDefaults setObject:[self plistStringFromColor:self.changedColorWell.color] forKey:GitDiffChangedColorKey];
}


#pragma mark - Helpers

- (NSColor *)colorFromPlistString:(NSString *)colorString
{
    NSArray* colorStringComponents = [colorString componentsSeparatedByString:@" "];
    CGFloat r = 0.0f,
            g = 0.0f,
            b = 0.0f,
            a = 0.0f;
    
    if ( colorStringComponents.count == 4 ) {
        r = [colorStringComponents[0] floatValue];
        g = [colorStringComponents[1] floatValue];
        b = [colorStringComponents[2] floatValue];
        a = [colorStringComponents[3] floatValue];
    }
    
    return [NSColor colorWithRed:r green:g blue:b alpha:a];
}

- (NSString *)plistStringFromColor:(NSColor *)color
{
    CGFloat r, g, b, a;
    [[color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]] getRed:&r green:&g blue:&b alpha:&a];

    return [NSString stringWithFormat:@"%.3f %.3f %.3f %.3f", r, g, b, a];
}

- (NSColor *)colorForKey:(NSString *)key
{
    if ( [_userDefaults stringForKey:key] ) {
        return [self colorFromPlistString:[_userDefaults stringForKey:key]];
    }
    else {
        return [self colorFromPlistString:_pluginDefaults[key]];
    }
}

@end
