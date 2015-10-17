/**

**/

#import "CSAPreferencesHandler.h"
#import "CSANotificationHandler.h"
#import <HucentCommon.h>

// static void StopPlayback() {
// 	CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"am.theiostre.foldalbum.player"];
// 	[center sendMessageName:@"Stop" userInfo:nil];
// }

static CSANotificationHandler *sharedInstance_ = nil;
@implementation CSANotificationHandler
+ (id)sharedInstance {
	if (!sharedInstance_)
		sharedInstance_ = [[CSANotificationHandler alloc] init];
	
	return sharedInstance_;
}

- (void)addNewAlbumIconWithMessageName:(NSString *)message userInfo:(NSDictionary *)userInfo {
	// MPMediaItemCollection *collection = [NSKeyedUnarchiver unarchiveObjectWithData:[userInfo objectForKey:@"MediaCollection"]];
	// NSString *title = [userInfo objectForKey:@"Title"];
	
	// SBIconListModel *availableModel = [[objc_getClass("SBIconController") sharedInstance] firstAvailableModel];
	// [availableModel addAlbumFolderForTitle:title plusKeyName:title andMediaCollection:collection atIndex:0 insert:NO];
}

- (void)updateKeyWithMessageName:(NSString *)message userInfo:(NSDictionary *)userInfo {
	// StopPlayback();
	
	NSString *key = [userInfo objectForKey:@"Key"];
	NSDictionary *dict = [userInfo objectForKey:@"Dictionary"];
	debug_NSLog(@"CustomSpotlightAction: I'm in optimizedUpdateKeyWithMessageName");
	[[CSAPreferencesHandler sharedInstance] updateKey:key withDictionary:dict];
}

- (void)optimizedUpdateKeyWithMessageName:(NSString *)message userInfo:(NSDictionary *)userInfo {
	//StopPlayback();
	debug_NSLog(@"CustomSpotlightAction: I'm in optimizedUpdateKeyWithMessageName");
	NSString *key = [userInfo objectForKey:@"Key"];
	NSDictionary *dict = [userInfo objectForKey:@"Dictionary"];
	
	[[CSAPreferencesHandler sharedInstance] optimizedUpdateKey:key withDictionary:dict];
}

- (void)removeKeyWithMessageName:(NSString *)message userInfo:(NSDictionary *)userInfo {
	//StopPlayback();
	
	NSString *key = [userInfo objectForKey:@"Key"];
	[[CSAPreferencesHandler sharedInstance] deleteKey:key];
}

- (NSDictionary *)keyExistsWithMessageName:(NSString *)message userInfo:(NSDictionary *)userInfo {
	NSString *key = [userInfo objectForKey:@"Key"];
	NSNumber *ret = [NSNumber numberWithBool:[[CSAPreferencesHandler sharedInstance] keyExists:key]];
	
	return [NSDictionary dictionaryWithObject:ret forKey:@"Result"];
}

- (NSDictionary *)objectForKeyWithMessageName:(NSString *)message userInfo:(NSDictionary *)userInfo {
	NSString *key = [userInfo objectForKey:@"Key"];
	id ret = [[CSAPreferencesHandler sharedInstance] objectForKey:key];
	
	return [NSDictionary dictionaryWithObject:ret forKey:@"Result"];
}
- (NSDictionary *)objectForKeywordWithMessageName:(NSString *)message userInfo:(NSDictionary *)userInfo {
	NSString *key = [userInfo objectForKey:@"Key"];
	id ret = [[CSAPreferencesHandler sharedInstance] objectForKeyword:key];
	
	return [NSDictionary dictionaryWithObject:ret forKey:@"Result"];
}

- (NSDictionary *)allKeys {
	debug_NSLog(@"CustomSpotlightAction: I'm in allkeys");
	NSArray *allKeys = [[CSAPreferencesHandler sharedInstance] allKeys];
	return [NSDictionary dictionaryWithObject:allKeys forKey:@"Result"];
}

- (void)updateCSASetting{
	//NSLog(@"CustomSpotlightAction:I'm in updateCSASetting");

	[[CSAPreferencesHandler sharedInstance] updateCSASetting];

}

/*
// FIXME: When relayouting, there seems to be an odd bug.
// Maybe check out how Apple *fully* does its relayouting.
// Thanks BigBoss! (stolen from libhide)
- (void)relayout {
	SBIconModel *iconModel = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_0 ? MSHookIvar<SBIconModel *>([objc_getClass("SBIconController") sharedInstance], "_iconModel") : [objc_getClass("SBIconModel") sharedInstance];
	
	NSSet *_visibleIconTags = MSHookIvar<NSSet *>(iconModel, "_visibleIconTags");
	NSSet *_hiddenIconTags  = MSHookIvar<NSSet *>(iconModel, "_hiddenIconTags");
	
	if (_visibleIconTags && _hiddenIconTags) {
		[iconModel setVisibilityOfIconsWithVisibleTags:_visibleIconTags hiddenTags:_hiddenIconTags];
		
		if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_0)
			[iconModel layout];
		else
			[iconModel relayout];
	}
}*/
@end