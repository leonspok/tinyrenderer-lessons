//
//  TGAColor.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 24/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	union {
		struct {
			uint8_t b, g, r, a;
		};
		uint8_t raw[4];
		uint32_t val;
	};
	int bytespp;
} TGAColor;

extern TGAColor TGAColorCreate();
extern TGAColor TGAColorCreateRGBA(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
extern TGAColor TGAColorCreateWithValue(uint32_t value, int bytespp);
extern TGAColor TGAColorCopy(TGAColor color);
extern TGAColor TGAColorCreateWithComponents(uint8_t *p, int bytespp);
extern void TGAColorCopyValues(TGAColor from, TGAColor to);
