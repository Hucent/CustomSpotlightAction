// CustomSpotlightAction - Draft 1
// With simple dylib loading (already an enhancement to SpotEnhancer)

// NEXT GOAL: Make it better than SLShortcuts
// (note to self) REMEMBER TO MAKE IT FREE U IDIOT

#import <dlfcn.h>
#import <UIKit/UIKit.h>
#import <AppSupport/CPDistributedNotificationCenter.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "CSANotificationHandler.h"
#import "CSAPreferencesHandler.h"
#import <SpringBoard/SBSearchController.h>
#import <SpringBoard/SBSearchViewController.h>
#import <SpringBoard/SBSearchHeader.h>

typedef void (^CSASearchDoneBlock)();
static UISearchBar *clickedbar;
//#define DYLIB_PATH @"/var/mobile/Library/CustomSpotlightAction/"
//#define PLIST_PATH @"/var/mobile/Library/CustomSpotlightAction/Preferences/pref.plist"
//#define STRING_CRAP [[[SCUtils dylibs] objectAtIndex:i] stringByDeletingPathExtension]

static void handleSearchText(NSString * searchText, CSASearchDoneBlock block){
	NSLog(@"i am in handleSearchText %@", searchText);
	/*NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	
	for (unsigned int i=0; i<[[dict allKeys] count]; i++) {
		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://baidu.com"]]];
	}
	if (dict != nil) [dict release];*/

	if([searchText length] == 0)
		return;
	//keyword + " " + query

	//NSArray * textArray = [searchText componentsSeparatedByString:@" "];
	NSRange range = [searchText rangeOfString:@" "];
	if(range.location == NSNotFound)
		return;
	CSAPreferencesHandler *handler = [CSAPreferencesHandler sharedInstance];

	NSDictionary* dict = [handler objectForKeyword:[searchText substringToIndex:range.location]];
	if(dict != nil){
	if(block)
		block();

		//NSLog(@"CustomSpotlightAction:%@", searchText);
		//[self clearSearchBar];
		/*NSString* urlString = [NSString stringWithFormat:[dict objectForKey:@"Url"], 
						[[searchText substringFromIndex:range.location+range.length] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];*/
		NSString* queryString = [[searchText substringFromIndex:range.location+range.length] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];

		NSMutableString *urlString = [NSMutableString stringWithString:[dict objectForKey:@"Url"]];
		[urlString replaceOccurrencesOfString:@"%@" withString:queryString options:NSCaseInsensitiveSearch range:(NSRange){0,[[dict objectForKey:@"Url"] length]}];	
		NSLog(@"CustomSpotlightAction:Y R going to open:%@", urlString);
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
	}

}

%hook SBSearchViewController
- (void)_searchFieldReturnPressed{	
SBSearchHeader *searchHeader;
object_getInstanceVariable(self, "_searchHeader", (void **)&searchHeader);
	handleSearchText([searchHeader.searchField.text copy], ^{
		NSLog(@"iam in block");
		searchHeader.searchField.text = @"";
	});
	%orig;
}
%end

%hook SBSearchController

- (void)searchBarSearchButtonClicked:(UISearchBar *)clicked {
	NSLog(@"i am in CSA");
	%orig;
	handleSearchText([clicked.text copy], ^{
		clicked.text = @"";
		[self searchBarSearchButtonClicked:clickedbar];
		[self searchBar:clickedbar textDidChange:@""];
	});
}

%end

%ctor {
	%init;
	NSLog(@"CustomSpotlightAction: Initialing");
	CSANotificationHandler *handler = [CSANotificationHandler sharedInstance];
	
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"mobi.hucent.customspotlightaction.server"];
	
	[messagingCenter registerForMessageName:@"UpdateKey" target:handler selector:@selector(updateKeyWithMessageName:userInfo:)];
	[messagingCenter registerForMessageName:@"OptimizedUpdateKey" target:handler selector:@selector(optimizedUpdateKeyWithMessageName:userInfo:)];
	[messagingCenter registerForMessageName:@"RemoveKey" target:handler selector:@selector(removeKeyWithMessageName:userInfo:)];
	[messagingCenter registerForMessageName:@"KeyExists" target:handler selector:@selector(keyExistsWithMessageName:userInfo:)];
	[messagingCenter registerForMessageName:@"ObjectForKey" target:handler selector:@selector(objectForKeyWithMessageName:userInfo:)];
	[messagingCenter registerForMessageName:@"ObjectForKeyword" target:handler selector:@selector(objectForKeywordWithMessageName:userInfo:)];
	[messagingCenter registerForMessageName:@"AllKeys" target:handler selector:@selector(allKeys)];	
	[messagingCenter registerForMessageName:@"UpdateCSASetting" target:handler selector:@selector(updateCSASetting)];	

	[messagingCenter runServerOnCurrentThread];
}