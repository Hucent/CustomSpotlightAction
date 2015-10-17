/**

**/

#import "CSAPreferencesHandler.h"
#import <HucentCommon.h>

static NSDictionary *CSALayoutDict() {
	return [NSDictionary dictionaryWithContentsOfFile:@CSALayoutPath];
}

static CSAPreferencesHandler *sharedInstance_ = nil;
@implementation CSAPreferencesHandler
+ (id)sharedInstance {
	if (!sharedInstance_)
		sharedInstance_ = [[CSAPreferencesHandler alloc] init];

	return sharedInstance_;
}

- (id)init {
	if ((self = [super init])) {
		_cacheSetting = [CSALayoutDict() retain];
		id cache = [_cacheSetting objectForKey:@"CSAFolderCache"];
		if (![cache isKindOfClass:[NSArray class]]) {
			debug_NSLog(@"[Custom Spotlight Action] Failure. Deleting your plist.");
			[[NSFileManager defaultManager] removeItemAtPath:@CSALayoutPath error:NULL];
			_cache = [[NSMutableArray array] retain];
		}
		else 
			_cache = [[NSMutableArray arrayWithArray:cache] retain];

		//init setting dict
		//_cacheSetting = [CSALayoutDict() retain];
		debug_NSLog(@"CustomSpotlightAction: I'm in init:%@", [self ignoreCase]?@"YES":@"NO");
	}

	return self;
}

- (void)dealloc {
	[_cache release];
	[_cacheSetting release];
	[super dealloc];
}

- (BOOL)keyExists:(NSString *)key {
	NSUInteger count = [_cache count];
	for (NSUInteger i=0; i<count; i++) {
		if ([[[_cache objectAtIndex:i] objectForKey:@"Name"] isEqualToString:key])
			return YES;
	}

	return NO;
}

- (BOOL)keywordExists:(NSString *)key {
	NSUInteger count = [_cache count];
	BOOL ignoreCaseValue = [self ignoreCase];
	for (NSUInteger i=0; i<count; i++) {
		if (!ignoreCaseValue && [[[_cache objectAtIndex:i] objectForKey:@"Keyword"] isEqualToString:key])
			return YES;
		if (ignoreCaseValue && [[[_cache objectAtIndex:i] objectForKey:@"Keyword"] caseInsensitiveCompare:key] == NSOrderedSame)
			return YES;
	}

	return NO;
}

- (NSArray *)allKeys {
	return _cache;
}

- (id)objectForKey:(NSString *)key {
	if(![self keyExists:key])
		return nil;
	return [self objectForKey:key keyName:@"Name" ignoreCase:NO];
}
- (id)objectForKeyword:(NSString *)key{
	if(![self keywordExists:key])
		return nil;
	return [self objectForKey:key keyName:@"Keyword" ignoreCase:[self ignoreCase]];
}
- (id)objectForKey:(NSString *)key keyName:(NSString*)keyName ignoreCase:(BOOL) ignoreCaseValue{
	NSUInteger count = [_cache count];
	for (NSUInteger i=0; i<count; i++) {
		id objectDict = [_cache objectAtIndex:i];
		if (!ignoreCaseValue && [[objectDict objectForKey:keyName] isEqualToString:key])
			return objectDict;

		if(ignoreCaseValue && [[objectDict objectForKey:keyName] caseInsensitiveCompare:key] == NSOrderedSame)
			return objectDict;
	}

	return nil;

}
- (void)updateKey:(NSString *)key withDictionary:(NSDictionary *)dict {
	NSUInteger i;
	for (i=0; i<[_cache count]; i++) {
		if ([[[_cache objectAtIndex:i] objectForKey:@"Name"] isEqualToString:key]) {
			[_cache replaceObjectAtIndex:i withObject:dict];
			goto write;
		}
	}

	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:dict];
	[d setObject:key forKey:@"Name"];
	[_cache addObject:d];

	write:
	[self _writeCacheToFile];
}

- (void)optimizedUpdateKey:(NSString *)key withDictionary:(NSDictionary *)dict {
	NSArray *keys = [dict allKeys];
	NSUInteger count = [keys count];

	NSDictionary *_tgt = [self objectForKey:key];
	if (!_tgt) return;

	NSMutableDictionary *tgt = [NSMutableDictionary dictionaryWithDictionary:_tgt];
	for (NSUInteger i=0; i<count; i++)
		[tgt setObject:[dict objectForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];

	[self updateKey:key withDictionary:tgt];
}

- (void)deleteKey:(NSString *)key {
	id obj = nil;
	NSUInteger count = [_cache count];
	for (NSUInteger i=0; i<count; i++) {
		if ([[[_cache objectAtIndex:i] objectForKey:@"Name"] isEqualToString:key]) {
			obj = [_cache objectAtIndex:i];
			break;
		}
	}
	if(obj)
		[_cache removeObject:obj];
	[self _writeCacheToFile];
}

- (void)_writeCacheToFile {
	NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithDictionary:CSALayoutDict()];

	[_dict setObject:_cache forKey:@"CSAFolderCache"];
	[_dict writeToFile:@CSALayoutPath atomically:YES];
}
- (void)updateCSASetting{
	[_cacheSetting release];
	_cacheSetting = nil;
	_cacheSetting = [CSALayoutDict() retain];
	debug_NSLog(@"CustomSpotlightAction:ignoreCase Setting change:%@", [self ignoreCase]?@"YES":@"NO");
}

- (BOOL)ignoreCase{
	if(_cacheSetting != nil){
		return [[_cacheSetting objectForKey:@"CSAIgnoreCase"] boolValue];
	}
	return NO;
}

@end