#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LPUIALocalizationRoute.h"

SpecBegin(LPUIALocalizationRoute)

describe(@"LPUIALocalizationRoute", ^{

  __block LPUIALocalizationRoute *route;

  before(^{
    route = [LPUIALocalizationRoute new];
  });

  describe(@"#supportsMethod:atPath:", ^{
    it(@"supports POST", ^{
      BOOL actual = [route supportsMethod:@"POST" atPath:nil];
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

    it(@"returns the UIA localized label", ^{

    });
  });
});

SpecEnd
