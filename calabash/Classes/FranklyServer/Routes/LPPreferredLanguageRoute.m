#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LPPreferredLanguageRoute.h"
NSString *const LPPreferredLanguageRouteName = @"preferred_language";

@interface LPPreferredLanguageRoute ()

@property(nonatomic, strong, readonly) NSArray *preferredLocalizations;

- (BOOL)canHandleGetForPath:(NSString *)path;
- (NSString *)applicationLanguageCode;
- (NSString *)deviceLanguageCode;
- (NSString *)displayNameForLanguageCode:(NSString *)languageCode;
- (NSLocale *)localeForLanguageCode:(NSString *)languageCode;
- (NSString *)displayNameForLocale:(NSLocale *)locale
                      languageCode:(NSString *)languageCode;

@end

@implementation LPPreferredLanguageRoute

@synthesize preferredLocalizations = _preferredLocalizations;

- (id) init {
  self = [super init];
  if (self) {
    _preferredLocalizations = [[NSBundle mainBundle] preferredLocalizations];
  }
  return self;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
  return [method isEqualToString:@"GET"];
}

- (BOOL)canHandleGetForPath:(NSString *)path {
  NSURL *url = [NSURL URLWithString:path];
  NSArray *components = [url pathComponents];
  return [[components lastObject] isEqualToString:LPPreferredLanguageRouteName];
}


- (NSDictionary *)JSONResponseForMethod:(NSString *)method
                                    URI:(NSString *)path
                                   data:(NSDictionary *)data {
  if (![self supportsMethod:method atPath:path]) {
    NSLog(@"Route does not support method '%@'", method);
    return nil;
  }

  if (![self canHandleGetForPath:path]) {
    NSLog(@"Route does not respond to path '%@'", path);
    return nil;
  }

  NSMutableDictionary *result = [@{} mutableCopy];

  NSString *appLangCode = [self applicationLanguageCode];
  if (appLangCode) {
    result[@"app_lang_code"] = appLangCode;
  } else {
    result[@"app_lang_code"] = [NSNull null];
  }

  result[@"app_lang_name"] = [self displayNameForLanguageCode:appLangCode];

  NSString *deviceLangCode = [self deviceLanguageCode];
  if (deviceLangCode) {
    result[@"device_lang_code"] = deviceLangCode;
  } else {
    result[@"device_lang_code"] = [NSNull null];
  }

  result[@"device_lang_name"] = [self displayNameForLanguageCode:deviceLangCode];

  if (self.preferredLocalizations) {
    result[@"app_localizations"] = self.preferredLocalizations;
  } else {
    result[@"app_localizations"] = @[];
  }

  NSArray *devicePreferredLanguages = [NSLocale preferredLanguages];
  if (devicePreferredLanguages) {
    result[@"device_languages"] = devicePreferredLanguages;
  } else {
    result[@"device_languages"] = @[];
  }

  return [NSDictionary dictionaryWithDictionary:result];
}

- (NSString *) applicationLanguageCode {
  return [self.preferredLocalizations objectAtIndex:0];
}

- (NSString *)deviceLanguageCode {
  return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (NSString *)displayNameForLanguageCode:(NSString *)languageCode {
  NSLocale *locale = [self localeForLanguageCode:languageCode];
  if (!locale) {
    NSLog(@"Could not create an NSLocale for language code '%@'",
          languageCode);
    NSLog(@"Returning the empty string");
    return @"";
  }

  NSString *name = [self displayNameForLocale:locale
                                 languageCode:languageCode];

  if (!name || [name isEqualToString:@""]) {
    NSLog(@"Could not create an NSLocale for language code '%@'",
          languageCode);
    NSLog(@"Returning the empty string");
    return @"";
  }

  return name;
}

// Pulled this out of #displayNameForLanguageCode: because it
// very difficult to test.
- (NSLocale *)localeForLanguageCode:(NSString *)languageCode {
  return [[NSLocale alloc] initWithLocaleIdentifier:languageCode];
}

// Pulled this out of #displayNameForLanguageCode: because it
// very difficult to test.  Mocking, for example, is not supported
// on NSLocale because of ARC toll-free bridging.
- (NSString *)displayNameForLocale:(NSLocale *)locale
                      languageCode:(NSString *)languageCode {
  return [locale displayNameForKey:NSLocaleIdentifier
                             value:languageCode];
}

@end
