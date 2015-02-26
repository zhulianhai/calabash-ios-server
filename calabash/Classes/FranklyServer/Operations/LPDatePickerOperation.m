//
//  ScrollOperation.m
//  Calabash
//
//  Created by Karl Krukow on 18/08/11.
//  Copyright (c) 2011 LessPainful. All rights reserved.
//

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LPDatePickerOperation.h"

@implementation LPDatePickerOperation

- (NSString *) description {
  return [NSString stringWithFormat:@"DatePicker: %@", _arguments];
}

/*
 args << options[:is_timer] || false
 args << options[:notify_targets] || true
 args << options[:animate] || true
 */


//                        required =========> |     optional
// _arguments ==> [target date str, format str, notify targets, animated]
- (id) performWithTarget:(UIView *) _view error:(NSError *__autoreleasing*) error {
  if ([_view isKindOfClass:[UIDatePicker class]] == NO) {
    NSLog(@"Warning view: %@ should be a date picker", _view);
    return nil;
  }

  UIDatePicker *picker = (UIDatePicker *) _view;

  NSString *dateStr = _arguments[0];
  if (dateStr == nil || [dateStr length] == 0) {
    NSLog(@"Warning: date str: '%@' should be non-nil and non-empty", dateStr);
    return nil;
  }

  NSUInteger argcount = [_arguments count];

  NSString *dateFormat = nil;
  if (argcount > 1) {
    dateFormat = _arguments[1];
  } else {
    NSLog(@"Warning: date format is required as the second argument");
    return nil;
  }


  BOOL notifyTargets = YES;
  if (argcount > 2) {
    notifyTargets = [_arguments[2] boolValue];
  }

  BOOL animate = YES;
  if (argcount > 3) {
    animate = [_arguments[3] boolValue];
  }

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:dateFormat];
  NSDate *date = [formatter dateFromString:dateStr];
  if (date == nil) {
    NSLog(@"Warning: could not create date from '%@' and format '%@'", dateStr,
            dateFormat);
    return nil;
  }

  NSDate *minDate = picker.minimumDate;
  if (minDate != nil && [date compare:minDate] == NSOrderedAscending) {
    NSLog(@"Warning: could not set the date to '%@' because is earlier than the minimum date '%@'",
            date,
            [minDate descriptionWithLocale:[NSLocale autoupdatingCurrentLocale]]);
    return nil;
  }

  NSDate *maxDate = picker.maximumDate;
  if (maxDate != nil && [date compare:maxDate] == NSOrderedDescending) {
    NSLog(@"Warning: could not set the date to '%@' because is later than the maximum date '%@'",
            date,
            [maxDate descriptionWithLocale:[NSLocale autoupdatingCurrentLocale]]);
    return nil;
  }

  [picker setDate:date animated:animate];

  if (notifyTargets) {
    NSSet *targets = [picker allTargets];
    NSLog(@"targets = %@", targets);
    for (id target in targets) {
      NSLog(@"target = %@ => %@", target, NSStringFromClass([target class]));
      NSArray *actions = [picker actionsForTarget:target
                                  forControlEvent:UIControlEventValueChanged];

      NSLog(@"actions = %@", actions);
      for (NSString *action in actions) {
        SEL sel = NSSelectorFromString(action);

        /* BEGIN DEBUGGING */
        NSLog(@"performing selector: %@", NSStringFromSelector(sel));
        NSLog(@"responds to selector: %@", [target respondsToSelector:sel] ? @"YES" : @"NO");

        NSMethodSignature *ms = [[target class] instanceMethodSignatureForSelector:sel];


        NSString *encoding = [NSString stringWithCString:[ms methodReturnType]
                                                encoding:NSASCIIStringEncoding];
        NSLog(@"encoding = %@", encoding);

        NSLog(@"# args = %@", @([ms numberOfArguments]));

        NSString *firstEncoding = [NSString stringWithCString:[ms getArgumentTypeAtIndex:0]
                                                     encoding:NSASCIIStringEncoding];

        NSLog(@"first encoding = %@", firstEncoding);
        NSString *secondEncoding = [NSString stringWithCString:[ms getArgumentTypeAtIndex:1]
                                                     encoding:NSASCIIStringEncoding];
        NSLog(@"second encoding = %@", secondEncoding);

        NSInvocation *invocation;
        invocation = [NSInvocation invocationWithMethodSignature:ms];
        [invocation setTarget:target];
        [invocation setSelector:sel];

        // Calling this produces the same crash as performSelector:withObject: below
        // [invocation invoke];
        /* END DEBUGGING */


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:sel withObject:picker];
#pragma clang diagnostic pop
      }
    }
  }

  return _view;
}
@end
