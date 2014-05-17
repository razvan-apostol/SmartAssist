//
//  SADefines.h
//  SmartAssist
//
//  Created by Iulian Poenaru on 17/05/14.
//  Copyright (c) 2014 COM.SmartAssist. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define SALog(message, ...) NSLog((@"%s [Line %d] " message), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
// A block assert version
#define SAAssert(condition, desc, ...)      \
do {                                    \
if (!(condition)) {                 \
[[NSAssertionHandler currentHandler] handleFailureInFunction:NSStringFromSelector(_cmd) file:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; \
}                                   \
} while(0);
#else
#define SALog(...)
#define SAAssert(condition, desc, ...)
#endif


#define SALog_CONDITIONAL_RETURN(shortDescription) \
do {  \
SALog(@"Condition not met, description: %@", shortDescription);   \
return;  \
} while (0)
