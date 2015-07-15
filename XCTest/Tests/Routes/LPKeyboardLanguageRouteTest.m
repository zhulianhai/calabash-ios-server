#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LPKeyboardLanguageRoute.h"

SpecBegin(LPKeyboardLanguageRoute)

describe(@"LPKeyboardLanguageRoute", ^{

  __block LPKeyboardLanguageRoute *route;

  before(^{
    route = [LPKeyboardLanguageRoute new];
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

  describe(@"#JSONResponseForMethod:URI:data:", ^{
    describe(@"handling the unhappy path", ^{

    });

    it(@"returns the current keyboard langauge code", ^{

    });
  });
});

SpecEnd
