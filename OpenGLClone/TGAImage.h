//
//  TGAImage.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 24/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGAColor.h"

typedef enum {
	TGAImageFormatGrayscale	= 1,
	TGAImageFormatRGB		= 3,
	TGAImageFormatRGBA		= 4
} TGAImageFormat;

@interface TGAImage : NSObject {
	uint8_t *data;
	int width;
	int height;
	int bytespp;
}

- (id)initWithWidth:(int)width height:(int)height bytesPerPixel:(int)bytesPerPixel;
- (id)initWithTGAImage:(TGAImage *)image;

- (BOOL)readTGAFileAtPath:(NSString *)path;
- (BOOL)writeTGAFileToPath:(NSString *)path rle:(BOOL)rle;

- (BOOL)flipHorizontally;
- (BOOL)flipVertically;
- (BOOL)scaleToWidth:(int)width height:(int)height;
- (TGAColor)getColorAtX:(int)x y:(int)y;
- (BOOL)setColor:(TGAColor)color toX:(int)x y:(int)y;
- (int)getWidth;
- (int)getHeight;
- (int)getBytesPerPixel;
- (uint8_t *)getBuffer;
- (void)clear;

@end
