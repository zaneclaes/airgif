//
//  Defines.h
//  AirGif
//
//  Created by Zane Claes on 5/5/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#ifndef AirGif_Defines_h
#define AirGif_Defines_h

#define URL_HOME @"http://AirGif.com"
#define URL_API(__page__) [NSString stringWithFormat:@"%@/api/%@.php",URL_HOME,__page__]
#define URL_GIF(__hash__) [NSString stringWithFormat:@"%@/g/%@",URL_HOME,__hash__]
#define URL_SHARE_GIF(__hash__) [NSString stringWithFormat:@"%@/%@",URL_HOME,__hash__]
#define URL_THUMBNAIL(__hash__,__size__) [NSString stringWithFormat:@"%@/t/%@/%lu",URL_HOME,__hash__,__size__]

#endif
