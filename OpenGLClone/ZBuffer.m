//
//  ZBuffer.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "ZBuffer.h"

@implementation ZBuffer {
	float *buffer;
}

- (id)initWithWidth:(size_t)width height:(size_t)height {
	self = [super init];
	if (self) {
		_width = width;
		_height = height;
		self->buffer = malloc(sizeof(float)*width*height);
		for (size_t i = 0; i < width*height; i++) {
			self->buffer[i] = -HUGE_VALF;
		}
	}
	return self;
}

- (void)dealloc {
	free(self->buffer);
}

- (float)valueForX:(size_t)x y:(size_t)y {
	return self->buffer[x+y*self.width];
}
- (void)setValue:(float)value forX:(size_t)x y:(size_t)y {
	self->buffer[x+y*self.width] = value;
}

@end
