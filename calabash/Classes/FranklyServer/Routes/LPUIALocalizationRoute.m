#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LPUIALocalizationRoute.h"

@implementation LPUIALocalizationRoute

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
  return [method isEqualToString:@"POST"];
}

- (BOOL)canHandlePostForPath:(NSArray *)path {
  return [@"uia_localization" isEqualToString:[path lastObject]];
}

- (NSDictionary *)JSONResponseForMethod:(NSString *)method
                                     URI:(NSString *)path
                                    data:(NSDictionary *)data {
  return nil;
}

@end
