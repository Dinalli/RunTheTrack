//
//  Global.h
//  Talking
//
//  Created by Tapha Media Ltd on 1/20/11.
//  Copyright (c) 2013 Tapha Media Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DEVICE_IPHONE_35INCH,
    DEVICE_IPHONE_40INCH,
    DEVICE_IPAD,
} DEVICE_TYPE;


DEVICE_TYPE gDeviceType;
CGSize gScreenSize;
BOOL gIsRetinaScreen;
UIInterfaceOrientation gDeviceOrientation;

#define STRDIC_MAIN	@"STRDIC_MAIN"
#define STRID_MAIN_BTN_FIND     @"BTN_FIND"
#define STRID_MAIN_BTN_MYFEED   @"BTN_MYFEED"
#define STRID_MAIN_BTN_BIGFEED  @"BTN_BIGFEED"

#define STRDIC_SEARCH @"STRDIC_SEARCH"
#define STRID_SEARCH_PLCFLD @"SEARCH_PLCFLD"


#define STRDIC_PROFILE @"STRDIC_PROFILE"
#define STRID_PROFILE_TITLE @"NAV_TITLE"
#define STRID_PROFILE_LBTN @"NAV_LBTN"
#define STRID_PROFILE_RBTN @"NAV_RBTN"


#define STRDIC_MYFEED @"STRDIC_MYFEED"


#define STRDIC_BIGFEED @"STRDIC_BIGFEED"
