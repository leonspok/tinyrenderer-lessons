//
//  ZBuffer.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBuffer : NSObject

@property (nonatomic, readonly) size_t width;
@property (nonatomic, readonly) size_t height;

- (id)initWithWidth:(size_t)width height:(size_t)height;

- (float)valueForX:(size_t)x y:(size_t)y;
- (void)setValue:(float)value forX:(size_t)x y:(size_t)y;

@end
