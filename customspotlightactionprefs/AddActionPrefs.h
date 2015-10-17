// Settings -> CustomSpotlightAction Draft 2

#import <Preferences/PSListController.h>
#import <Preferences/PSTextFieldSpecifier.h>
#import <UIKit/UIKit.h>
#import <notify.h>
#import <objc/runtime.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
//#define DEBUG_HUCENT

@interface AddActionPrefsListController: PSListController 
{
	//BOOL _clickOnSave;
	//unsigned int _textFieldCount;
	NSString* _keyword;
	NSMutableDictionary *_pref_dict;
}
@property (retain, nonatomic) NSMutableDictionary *pref_dict;
//- (void)clickOnSaveBtn;
//- (void)saveAction;
//- (void)resetState;
- (id)init;

-(BOOL) checkUrlValid:(id)value;
-(BOOL) checkKeywordValid:(id)value;
-(BOOL) checkNameValid:(id)value;

-(id) formatKeywordValue:(id)value;

@end

