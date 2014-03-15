//
//  Logging.h
//  spritecollision
//
//  Created by Joseph Bell on 2/18/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#ifndef spritecollision_Logging_h
#define spritecollision_Logging_h

#import "DDLog.h"

#define ENTRY_LOG      DDLogVerbose(@"%s ENTRY ", __PRETTY_FUNCTION__);
#define EXIT_LOG       DDLogVerbose(@"%s EXIT ", __PRETTY_FUNCTION__);
#define ERROR_EXIT_LOG DDLogError(@"%s ERROR EXIT", __PRETTY_FUNCTION__);


#endif
