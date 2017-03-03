//
//  BLLog.h
//  SXS_BL
//
//  Created by 解梁 on 2016/10/25.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#ifndef BLLog_h
#define BLLog_h

#ifdef DEBUG

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#else

static const DDLogLevel ddLogLevel = DDLogLevelOff;

#endif

#ifndef BLLogError
#define BLLogError(format, ...) \
{ \
    DDLogError((@"%@.m:%d Err:" format), NSStringFromClass([self class]), __LINE__, ## __VA_ARGS__); \
}
#endif

#ifndef BLLogWarn
#define BLLogWarn(format, ...) \
{ \
    DDLogWarn((@"%@.m:%d Warn:" format), NSStringFromClass([self class]), __LINE__, ## __VA_ARGS__); \
}
#endif

#ifndef BLLogInfo
#define BLLogInfo(format, ...) \
{ \
    DDLogInfo((@"%@.m:%d Info:" format), NSStringFromClass([self class]), __LINE__, ## __VA_ARGS__); \
}

#endif

#ifndef BLLogDebug
#define BLLogDebug(format, ...) \
{ \
    DDLogDebug((@"%@.m:%d Debug:" format), NSStringFromClass([self class]), __LINE__, ## __VA_ARGS__); \
}

#endif

#ifndef BLLogVerbose
#define BLLogVerbose(format, ...) \
{ \
    DDLogVerbose((@"%@.m:%d Verbose:" format), NSStringFromClass([self class]), __LINE__, ## __VA_ARGS__); \
}
#endif

#endif /* BLLog_h */
