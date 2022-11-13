//
//  PDDelegateProxy.h
//  vnvce
//
//  Created by Kerem Cesme on 10.11.2022.
//

#import <Foundation/Foundation.h>

@interface PDDelegateProxy : NSObject
- (nonnull instancetype)initWithDelegates:(NSArray<id> * __nonnull)delegates NS_REFINED_FOR_SWIFT;
@end
