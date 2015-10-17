// Settings -> CustomSpotlightAction Draft 2

#import "CustomSpotlightActionPrefs.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTextFieldSpecifier.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#include <objc/runtime.h>
#import "AddActionPrefs.h"
#import <HucentCommon.h>

//#define CSA_PLIST_PATH @"/var/mobile/Library/CustomSpotlightAction/Preferences/pref.plist"

//static NSMutableDictionary *_dict = [[NSDictionary alloc] initWithContentsOfFile:CSA_PLIST_PATH];

@implementation CustomSpotlightActionPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiers] retain];
		//_specifiers = [[self loadSpecifiersFromPlistName:@"CustomSpotlightActionPrefs" target:self] retain];
	}
	debug_NSLog(@"Custom Spotlight Action: I'm in CustomSpotlightActionPrefsListController");
	return _specifiers;
}
- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIBarButtonItem *add = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createEntry)] autorelease];
	[[self navigationItem] setRightBarButtonItem:add];
}
- (void)createEntry {
	PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:@"New" target:self set:NULL get:NULL detail:objc_getClass("AddActionPrefsListController") cell:PSLinkCell edit:Nil];
	[spec setProperty:@"New" forKey:@"label"];

	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"mobi.hucent.customspotlightaction.server"];
	NSArray *dicts = [[messagingCenter sendMessageAndReceiveReplyName:@"AllKeys" userInfo:nil] objectForKey:@"Result"];
	
	//why -2? for donatebutton and it's group
	[self insertSpecifier:spec atIndex:[[self specifiers] count]-[dicts count]-2 animated:YES];
}


- (NSArray *)loadSpecifiers {
	NSMutableArray *ret = [NSMutableArray array];
	
	// TODO: Don't load anything from that plist s_s
	NSArray *firstObjects = [self loadSpecifiersFromPlistName:@"CustomSpotlightActionPrefs" target:self];
	[ret addObjectsFromArray:firstObjects];
	
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"mobi.hucent.customspotlightaction.server"];
	NSArray *dicts = [[messagingCenter sendMessageAndReceiveReplyName:@"AllKeys" userInfo:nil] objectForKey:@"Result"];
	
	for (NSDictionary *dict in dicts) {
		PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:[dict objectForKey:@"Name"] target:self set:NULL get:NULL detail:[AddActionPrefsListController class] cell:PSLinkCell edit:Nil];
		//[spec setProperty:[dict objectForKey:@"actionName"] forKey:@"label"];
		[ret insertObject:spec atIndex:[ret count] - 2];
	}
	
	return ret;
}
-(void)setCSAIgnoreCase:(id)value specifier:(id)specifier {
	debug_NSLog(@"CustomSpotlightAction: Save SetCSAIgnoreCase");
	//[[NSUserDefaults standardUserDefaults] synchronize];
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	//[_dict setObject:value forKey:[specifier name]];
	//[_dict writeToFile:CSA_PLIST_PATH atomically:YES];
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"mobi.hucent.customspotlightaction.server"];
	[messagingCenter sendMessageName:@"UpdateCSASetting" userInfo:nil];
}

- (void)showDonationPage:(PSSpecifier *)spec {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://hucent.mobi/donatecsa.html"]];
}

@end

// http://code.google.com/p/networkpx/wiki/PreferencesSpecifierPlistFormat is epic
// 