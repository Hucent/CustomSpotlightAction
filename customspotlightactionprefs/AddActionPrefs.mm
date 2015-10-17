// Settings -> CustomSpotlightAction Draft 2

#import "AddActionPrefs.h"
#import <HucentCommon.h>
#define NAME_STRING @"Name"
#define KEYWORD_STRING @"Keyword"
#define URL_STRING @"Url"
#define CHECK_METHOD_FORMAT @"check%@Valid:"
#define FORMAT_METHOD_FORMAT @"format%@Value:"
//#define ACTIONNAME_STRING @"actionName"
#define NEW_KEYWORD @"\u266B"

@implementation AddActionPrefsListController
@synthesize pref_dict;
- (id)specifiers {
	NSString *content_ = [[self specifier] name];
	_keyword = [content_ isEqualToString:@"New"] ?  NEW_KEYWORD: content_;
	if (!_keyword) {
		[[self navigationController] popViewControllerAnimated:YES];
		return nil;
	}
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"AddActionPrefs" target:self] retain];
		if (![_keyword isEqualToString:NEW_KEYWORD]){
			debug_NSLog(@"in AddActionPrefsListController, %@", _keyword);
			//get the action detail 
			CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"mobi.hucent.customspotlightaction.server"];
	
			if (([[[messagingCenter sendMessageAndReceiveReplyName:@"KeyExists" userInfo:[NSDictionary dictionaryWithObject:_keyword forKey:@"Key"]] objectForKey:@"Result"] boolValue])) {
				NSDictionary *dict = [[messagingCenter sendMessageAndReceiveReplyName:@"ObjectForKey" userInfo:[NSDictionary dictionaryWithObject:_keyword forKey:@"Key"]] objectForKey:@"Result"];
				[pref_dict setDictionary:dict];
			    NSArray* keyArray = [pref_dict allKeys];
				unsigned int dictSize = [keyArray count];
				debug_NSLog(@"return dict size :%d", dictSize);
				for (unsigned int i = 0; i < dictSize; ++i)
				{
					debug_NSLog(@"dict ,key:%@, value:%@", [keyArray objectAtIndex:i], [pref_dict objectForKey:[keyArray objectAtIndex:i]]);
				}
			}
		}
	}
	//[self resetState];	
	return _specifiers;
}
-(void)setPreference:(id)value specifier:(id)specifier 
{
	// [self setPreferenceValue:value specifier:specifier];
	// //[[NSUserDefaults standardUserDefaults] synchronize];
	// [pref_dict setObject:value forKey:[specifier name]];
	
	// //as this message will receive the cursor move to the other text field
	// //or jump back to the previous page(eg. click on the save button)
	// //in case user update the field ,call  again
	// [self saveAction];
	NSString *content_ = [specifier name];

	debug_NSLog(@"CustomSpotlightAction:setPreference");

   	//const char* className = class_getName([_keyword class]);
   	//debug_NSLog(@"custom Spotlight action yourObject is a: %s", className);
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"mobi.hucent.customspotlightaction.server"];
	
	NSString* formatMethodName = [NSString stringWithFormat:FORMAT_METHOD_FORMAT,content_];	
	debug_NSLog(@"format method Name:%@", formatMethodName);
	SEL formatSelector=NSSelectorFromString(formatMethodName);
	id formatValue = [self respondsToSelector:formatSelector] ? [self performSelector:formatSelector withObject:value] : value;

	[pref_dict setObject:formatValue forKey:content_];

	NSString* checkMethodName = [NSString stringWithFormat:CHECK_METHOD_FORMAT,content_];
	debug_NSLog(@"Check method Name:%@", checkMethodName);
	SEL faSelector=NSSelectorFromString(checkMethodName);
	if([self respondsToSelector:faSelector] && ![self performSelector:faSelector withObject:formatValue])
    	return;

	if([content_ isEqualToString:NAME_STRING]){
		//should remove the old one
		[messagingCenter sendMessageName:@"RemoveKey" userInfo:[NSDictionary dictionaryWithObject:_keyword forKey:@"Key"]];
		_keyword = formatValue;
		debug_NSLog(@"CustomSpotlightAction:setPreference");
	}	

	if([_keyword isEqualToString:NEW_KEYWORD] ){
		debug_NSLog(@"CustomSpotlightAction:setPreference");
		//nothing can do until keyword is set
		return;
	}

	if (([[[messagingCenter sendMessageAndReceiveReplyName:@"KeyExists" userInfo:[NSDictionary dictionaryWithObject:_keyword forKey:@"Key"]] objectForKey:@"Result"] boolValue])) {
		NSDictionary *dict = [NSDictionary dictionaryWithObject:formatValue forKey:[specifier name]];
		[messagingCenter sendMessageName:@"OptimizedUpdateKey" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_keyword,@"Key", dict,@"Dictionary", nil]];
	}
	else{
		NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:pref_dict];
		//no need to update the name, it is another arg
		if([dict objectForKey:NAME_STRING] != nil){
			[dict removeObjectForKey:NAME_STRING];
		}

		[messagingCenter sendMessageName:@"UpdateKey" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:dict,@"Dictionary", _keyword,@"Key", nil]];
	}
	_keyword = [pref_dict objectForKey:NAME_STRING];
	[[self navigationItem] setTitle:_keyword];
	[[self specifier] setName:_keyword];
	[(PSListController *)[self parentController] reloadSpecifier:[self specifier] animated:YES];

	
	//[messagingCenter sendMessageName:@"Relayout" userInfo:nil];
}
-(NSString *)getPreference:(PSSpecifier *)specifier{
	debug_NSLog(@"CustomSpotlightAction: I'm in getPreference, key:%@, value:%@", [specifier name],[pref_dict objectForKey:[specifier name]]);
	return [pref_dict objectForKey:[specifier name]];
}

-(void)deleteAction:(id)specifier{
	CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"mobi.hucent.customspotlightaction.server"];
	debug_NSLog(@"CustomSpotlightAction:delete");
	if(![_keyword isEqualToString:NEW_KEYWORD] )
		[messagingCenter sendMessageName:@"RemoveKey" userInfo:[NSDictionary dictionaryWithObject:_keyword forKey:@"Key"]];
	
	NSMutableArray *specs = [NSMutableArray arrayWithArray:[(PSListController *)[self parentController] specifiers]];
	[specs removeObject:[self specifier]];
	[(PSListController *)[self parentController] setSpecifiers:specs];
		
	//[(PSListController *)[self parentController] reloadSpecifier:[self specifier] animated:YES];
	[[self navigationController] popViewControllerAnimated:YES];
}

-(BOOL) checkUrlValid:(id)value {
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]+:[^\\s]*" options:NSRegularExpressionCaseInsensitive error:nil];
	
	NSInteger numberOfMatches = [regex numberOfMatchesInString:value options:0 range:NSMakeRange(0, [value length])];
	
	if(numberOfMatches > 0)
		return YES;
	else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice!" 
		    message:@"Invalid Url. Url must be something like http://google.com/search?q=%@, or fantastical://parse?sentence=%@" 
		    delegate:nil 
		    cancelButtonTitle:@"OK" 
		    otherButtonTitles:nil];
		[alert show];
		[alert release];
		return YES;
	}
}
-(BOOL) checkKeywordValid:(id)value {
	return YES;
}
-(BOOL) checkNameValid:(id)value {
	if([value length] > 0)
		return YES;
	else{
    	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice!" 
    	    message:@"Name is required" 
    	    delegate:nil 
    	    cancelButtonTitle:@"OK" 
    	    otherButtonTitles:nil];
    	[alert show];
    	[alert release];
		return NO;
	}
}

-(id) formatKeywordValue:(id)value {
	return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}



- (void)viewDidLoad {
	[super viewDidLoad];
}

- (id)init;
{
 	if (!(self = [super init]))
   		return nil;
 // other stuff
	pref_dict = [[NSMutableDictionary alloc] init];
	return self;

}
@end
