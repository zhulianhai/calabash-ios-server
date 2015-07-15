#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LPPreferredLanguageRoute.h"

@interface LPPreferredLanguageRoute (LPXCTEST)

- (BOOL)canHandleGetForPath:(NSString *)path;
- (NSArray *)preferredLocalizations;
- (NSString *)applicationLanguageCode;
- (NSString *)deviceLanguageCode;
- (NSString *)displayNameForLanguageCode:(NSString *)languageCode;
- (NSLocale *)localeForLanguageCode:(NSString *)languageCode;
- (NSString *)displayNameForLocale:(NSLocale *)locale
                      languageCode:(NSString *)languageCode;

@end

SpecBegin(LPPreferredLanguageRoute)

describe(@"LPPreferredLanguageRoute", ^{

  __block LPPreferredLanguageRoute *route;
  __block NSString *invalidPath;
  __block NSString *validPath;
  before(^{
    route = [LPPreferredLanguageRoute new];
    invalidPath = @"http://host/api/version/other_route";
    validPath = [@"http://host/api/version" stringByAppendingPathComponent:LPPreferredLanguageRouteName];
  });

  describe(@"#supportsMethod:atPath:", ^{
    it(@"supports GET", ^{
      BOOL actual = [route supportsMethod:@"GET" atPath:nil];
      expect(actual).to.equal(YES);
    });

    it(@"does not support anything else", ^{
      BOOL actual = [route supportsMethod:@"BAR" atPath:nil];
      expect(actual).to.equal(NO);
    });
  });

  describe(@"#canHandleGetForPath", ^{
    it(@"handles the preferred language route", ^{
      BOOL actual = [route canHandleGetForPath:validPath];
      expect(actual).to.equal(YES);
    });

    it(@"doesn't handle any other route", ^{
      BOOL actual = [route canHandleGetForPath:invalidPath];
      expect(actual).to.equal(NO);
    });
  });

  it(@"#stringForApplicationLanguage", ^{
    id mock = OCMPartialMock(route);
    [[[mock expect] andReturn:@[@"ack!"]] preferredLocalizations];

    expect([mock applicationLanguageCode]).to.equal(@"ack!");
    [mock verify];
  });

  it(@"#stringForDeviceLanguage", ^{
    id mock = [OCMockObject mockForClass:[NSLocale class]];
    [[[mock expect] andReturn:@[@"!kca"]] preferredLanguages];

    expect([route deviceLanguageCode]).to.equal(@"!kca");
    [mock verify];
  });

  describe(@"#displayNameForLanguageCode:", ^{
    describe(@"unhappy paths", ^{

      __block id mock;

      before(^{
        mock = OCMPartialMock(route);
      });

      it(@"returns '' when cannot create a locale", ^{
        [[[mock expect] andReturn:nil] localeForLanguageCode:@"en"];

        NSString *actual = [route displayNameForLanguageCode:@"en"];
        expect(actual).to.equal(@"");
        [mock verify];
      });

      describe(@"returns '' when cannot find a display name", ^{
        it(@"looking up key returns nil", ^{
          [[[mock expect] andReturn:nil] displayNameForLocale:OCMOCK_ANY languageCode:OCMOCK_ANY];

          NSString *actual = [route displayNameForLanguageCode:@"en"];
          expect(actual).to.equal(@"");
          [mock verify];
        });

        it(@"looking up key returns ''", ^{
          [[[mock expect] andReturn:@""] displayNameForLocale:OCMOCK_ANY languageCode:OCMOCK_ANY];

          NSString *actual = [route displayNameForLanguageCode:@"en"];
          expect(actual).to.equal(@"");
          [mock verify];
        });
      });
    });

    it(@"returns a display name", ^{
      NSString *actual = [route displayNameForLanguageCode:@"da"];
      expect(actual).to.equal(@"dansk");
    });
  });

  describe(@"#JSONResponseForMethod:URI:data:", ^{
    describe(@"handling the unhappy path", ^{

    });

    it(@"returns the preferred language code", ^{
      NSDictionary *actual = [route JSONResponseForMethod:@"GET"
                                                      URI:validPath
                                                     data:nil];

      expect(actual[@"app_lang_code"]).to.equal(@"en");
      expect(actual[@"device_lang_code"]).to.equal(@"en");
      expect(actual[@"app_lang_name"]).to.equal(@"English");
      expect(actual[@"device_lang_name"]).to.equal(@"English");
      expect(actual[@"device_languages"]).notTo.equal(nil);
      expect(actual[@"app_localizations"][0]).to.equal(@"en");
      expect(actual.count).to.equal(6);
    });
  });
});

SpecEnd
