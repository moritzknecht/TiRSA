//
//  Created by Patrick Hogan/Manuel Zamora 2012
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros
////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef DEBUG

#define BDDebugLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define BDDebugLog(...)

#endif

#define BDLog(fmt, ...) NSLog((@"%s [Line %d]" fmt @"\n\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)