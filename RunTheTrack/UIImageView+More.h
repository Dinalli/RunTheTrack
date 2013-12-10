//
//  UIImageView+More.h
//  EventManage
//
//  Created by Cristian Ronaldo on 8/8/13.
//  Copyright (c) 2013 Cristian Ronaldo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    IMAGE_OPTION_NONE = 0,
    IMAGE_OPTION_RETINA = (1 << 0),
    IMAGE_OPTION_ORIENTATION = (1 << 1),
    IMAGE_OPTION_DEVICE = (1 << 2),
} IMAGE_OPTION_TYPE;

typedef int ImageOptionUnit;

@interface UIImageView(More) {
    ;
}

- (void) setImageWithOptions:(NSString *)imgfileName options:(ImageOptionUnit)options use568h:(BOOL)use568h;
- (void) setResizableImageWithOptions:(NSString *)imgfileName
                              options:(ImageOptionUnit)options
                              use568h:(BOOL)use568h
                            capInsets:(UIEdgeInsets)capInsets;

@end
