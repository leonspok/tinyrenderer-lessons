//
//  TGAImage.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 24/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "TGAImage.h"

#pragma pack(push,1)
typedef struct {
	int8_t idlength;
	int8_t colormaptype;
	int8_t datatypecode;
	int16_t colormaporigin;
	int16_t colormaplength;
	int8_t colormapdepth;
	int16_t x_origin;
	int16_t y_origin;
	int16_t width;
	int16_t height;
	int8_t  bitsperpixel;
	int8_t  imagedescriptor;
} TGA_Header;
#pragma pack(pop)

@implementation TGAImage

- (id)initWithWidth:(int)w height:(int)h bytesPerPixel:(int)bytesPerPixel {
	self = [self init];
	if (self) {
		self->bytespp = bytesPerPixel;
		self->width = w;
		self->height = h;
		uint64_t nbytes = w*h*bytesPerPixel;
		self->data = malloc(nbytes * sizeof(uint8_t));
		memset(self->data, 0, nbytes);
	}
	return self;
}

- (id)initWithTGAImage:(TGAImage *)image {
	self = [self initWithWidth:[image getWidth] height:[image getHeight] bytesPerPixel:[image getBytesPerPixel]];
	if (self) {
		uint64_t nbytes = self->width*self->height*self->bytespp;
		memcpy(self->data, image->data, nbytes);
	}
	return self;
}

- (void)dealloc {
	if (self->data != NULL) {
		free(self->data);
	}
}

#pragma mark Drawing

- (TGAColor)getColorAtX:(int)x y:(int)y {
	if (self->data == NULL || x < 0 || y < 0 || x >= self->width || y >= self->height) {
		return TGAColorCreate();
	}
	return TGAColorCreateWithComponents(self->data+(x+y*self->width)*self->bytespp, self->bytespp);
}

- (BOOL)setColor:(TGAColor)color toX:(int)x y:(int)y {
	if (self->data == NULL || x < 0 || y < 0 || x >= self->width || y >= self->height) {
		return NO;
	}
	memcpy(self->data+(x+y*self->width)*self->bytespp, color.raw, self->bytespp);
	return YES;
}

- (void)clear {
	memset((void *)self->data, 0, self->width*self->height*self->bytespp);
}

#pragma mark Transformations

- (BOOL)flipHorizontally {
	if (self->data == NULL) {
		return NO;
	}
	int half = self->width>>1;
	for (int i = 0; i < half; i++) {
		for (int j = 0; j < height; j++) {
			TGAColor c1 = [self getColorAtX:i y:j];
			TGAColor c2 = [self getColorAtX:(self->width-1-i) y:j];
			[self setColor:c2 toX:i y:j];
			[self setColor:c1 toX:(self->width-1-i) y:j];
		}
	}
	return YES;
}

- (BOOL)flipVertically {
	if (self->data == NULL) {
		return NO;
	}
	uint64_t bytesPerLine = self->width*self->bytespp;
	uint8_t *line = malloc(bytesPerLine*sizeof(uint8_t));
	int half = height>>1;
	for (int j = 0; j < half; j++) {
		uint64_t l1 = j*bytesPerLine;
		uint64_t l2 = (self->height-1-j)*bytesPerLine;
		memmove(line, self->data+l1, bytesPerLine);
		memmove(self->data+l1, self->data+l2, bytesPerLine);
		memmove(self->data+l2, line, bytesPerLine);
	}
	free(line);
	return YES;
}

- (BOOL)scaleToWidth:(int)w height:(int)h {
	if (w <= 0 || h <= 0 || self->data == NULL) {
		return NO;
	}
	uint8_t *tdata = malloc(w*h*self->bytespp);
	int nscanline = 0;
	int oscanline = 0;
	int erry = 0;
	uint64_t nlineBytes = w*self->bytespp;
	uint64_t olineBytes = h*self->bytespp;
	for (int j = 0; j < height; j++) {
		int errx = self->width - w;
		int nx = -self->bytespp;
		int ox = -self->bytespp;
		for (int i = 0; i < self->width; i++) {
			ox += self->bytespp;
			errx += w;
			while (errx >= (int)self->width) {
				errx -= self->width;
				nx += self->bytespp;
				memcpy(tdata+nscanline+nx, data+oscanline+ox, self->bytespp);
			}
		}
		erry += h;
		oscanline += olineBytes;
		while (erry >= (int)self->height) {
			if (erry >= (int)self->height<<1) {
				memcpy(tdata+nscanline+nlineBytes, tdata+nscanline, self->bytespp);
			}
			erry -= self->height;
			nscanline += nlineBytes;
		}
	}
	free(self->data);
	self->data = tdata;
	self->width = w;
	self->height = h;
	return YES;
}

#pragma mark Reading/Writing files

- (BOOL)readTGAFileAtPath:(NSString *)path {
	if (self->data) {
		free(self->data);
	}
	self->data = NULL;
	NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
	[inputStream open];
	if (inputStream.streamStatus != NSStreamStatusOpen) {
		[inputStream close];
		return NO;
	}
	
	TGA_Header header;
	[inputStream read:(uint8_t *)&header maxLength:sizeof(header)];
	if (inputStream.streamStatus == NSStreamStatusError) {
		[inputStream close];
		return NO;
	}
	
	self->width = header.width;
	self->height = header.height;
	self->bytespp = header.bitsperpixel>>3;
	
	if (self->width <= 0 || self->height <= 0 || (self->bytespp!=TGAImageFormatGrayscale && self->bytespp!=TGAImageFormatRGB && self->bytespp!=TGAImageFormatRGBA)) {
		[inputStream close];
		return NO;
	}
	
	uint64_t nBytes = self->bytespp*self->width*self->height;
	self->data = malloc(nBytes*sizeof(uint8_t));
	if (header.datatypecode == 3 || header.datatypecode == 2) {
		[inputStream read:self->data maxLength:nBytes];
		if (inputStream.streamStatus == NSStreamStatusError) {
			[inputStream close];
			return NO;
		}
	} else if (header.datatypecode == 10 || header.datatypecode == 11) {
		if (![self loadRLEDataFromStream:inputStream]) {
			[inputStream close];
			return NO;
		}
	} else {
		[inputStream close];
		return NO;
	}
	[inputStream close];
	
	if (!(header.imagedescriptor & 0x20)) {
		[self flipVertically];
	}
	if (header.imagedescriptor & 0x10) {
		[self flipHorizontally];
	}
	return YES;
}

- (BOOL)writeTGAFileToPath:(NSString *)path rle:(BOOL)rle {
	uint8_t developerAreaRef[4] = {0, 0, 0, 0};
	uint8_t extensionAreaRef[4] = {0, 0, 0, 0};
	uint8_t footer[18] = {'T','R','U','E','V','I','S','I','O','N','-','X','F','I','L','E','.','\0'};
	
	NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:path append:NO];
	[outputStream open];
	if (outputStream.streamStatus != NSStreamStatusOpen) {
		[outputStream close];
		return NO;
	}
	
	TGA_Header header;
	memset(&header, 0, sizeof(header));
	header.bitsperpixel = self->bytespp<<3;
	header.width  = self->width;
	header.height = self->height;
	if (rle) {
		if (self->bytespp == TGAImageFormatGrayscale) {
			header.datatypecode = 11;
		} else {
			header.datatypecode = 10;
		}
	} else {
		if (self->bytespp == TGAImageFormatGrayscale) {
			header.datatypecode = 3;
		} else {
			header.datatypecode = 2;
		}
	}
	header.imagedescriptor = 0x20;
	[outputStream write:(uint8_t *)&header maxLength:sizeof(header)];
	if (outputStream.streamStatus == NSStreamStatusError) {
		[outputStream close];
		return NO;
	}
	if (!rle) {
		[outputStream write:self->data maxLength:(self->width*self->height*self->bytespp)];
		if (outputStream.streamStatus == NSStreamStatusError) {
			[outputStream close];
			return NO;
		}
	} else {
		if (![self unloadRLEDataFromStream:outputStream]) {
			[outputStream close];
			return NO;
		}
	}
	[outputStream write:(uint8_t *)developerAreaRef maxLength:sizeof(developerAreaRef)];
	if (outputStream.streamStatus == NSStreamStatusError) {
		[outputStream close];
		return NO;
	}
	[outputStream write:(uint8_t *)extensionAreaRef maxLength:sizeof(extensionAreaRef)];
	if (outputStream.streamStatus == NSStreamStatusError) {
		[outputStream close];
		return NO;
	}
	[outputStream write:(uint8_t *)footer maxLength:sizeof(footer)];
	if (outputStream.streamStatus == NSStreamStatusError) {
		[outputStream close];
		return NO;
	}
	[outputStream close];
	return YES;
}

- (BOOL)loadRLEDataFromStream:(NSInputStream *)inputStream {
	uint64_t pixelCount = self->width*self->height;
	uint64_t currentPixel = 0;
	uint64_t currentByte = 0;
	TGAColor colorBuffer;
	uint8_t *chunkHeader = malloc(sizeof(uint8_t));
	do {
		[inputStream read:chunkHeader maxLength:1];
		if (inputStream.streamStatus == NSStreamStatusError) {
			free(chunkHeader);
			return NO;
		}
		if (chunkHeader[0] < 128) {
			for (int i = 0; i <= chunkHeader[0]; i++) {
				[inputStream read:colorBuffer.raw maxLength:self->bytespp];
				if (inputStream.streamStatus == NSStreamStatusError) {
					free(chunkHeader);
					return NO;
				}
				for (int t = 0; t < self->bytespp; t++) {
					self->data[currentByte] = colorBuffer.raw[t];
					currentByte++;
				}
				currentPixel++;
				if (currentPixel > pixelCount) {
					free(chunkHeader);
					return NO;
				}
			}
		} else {
			[inputStream read:colorBuffer.raw maxLength:self->bytespp];
			if (inputStream.streamStatus == NSStreamStatusError) {
				free(chunkHeader);
				return NO;
			}
			for (int i = 0; i < chunkHeader[0]-127; i++) {
				for (int t = 0; t < self->bytespp; t++) {
					self->data[currentByte] = colorBuffer.raw[t];
					currentByte++;
				}
				currentPixel++;
				if (currentPixel > pixelCount) {
					free(chunkHeader);
					return NO;
				}
			}
		}
	} while(currentPixel < pixelCount);
	return YES;
}

-  (BOOL)unloadRLEDataFromStream:(NSOutputStream *)outputStream {
	const uint8_t maxChunkLength = 128;
	uint64_t pixelsCount = self->width*self->height;
	uint64_t currentPixel = 0;
	while (currentPixel < pixelsCount) {
		uint64_t chunkStart = currentPixel*self->bytespp;
		uint64_t currentByte = currentPixel*self->bytespp;
		uint8_t runLength = 1;
		BOOL raw = YES;
		while(currentPixel+runLength < pixelsCount && runLength < maxChunkLength) {
			BOOL succEq = YES;
			for (int t = 0; succEq && t < self->bytespp; t++) {
				succEq = (self->data[currentByte+t] == self->data[currentByte+t+self->bytespp]);
			}
			currentByte += self->bytespp;
			if (runLength == 1) {
				raw = !succEq;
			}
			if (raw && succEq) {
				runLength--;
				break;
			}
			if (!raw && !succEq) {
				break;
			}
			runLength++;
		}
		currentPixel += runLength;
		
		uint8_t *buf = malloc(sizeof(uint8_t));
		if (raw) {
			buf[0] = runLength-1;
		} else {
			buf[0] = runLength+127;
		}
		[outputStream write:buf maxLength:1];
		free(buf);
		if (outputStream.streamStatus == NSStreamStatusError) {
			return NO;
		}
		
		if (raw) {
			[outputStream write:self->data+chunkStart maxLength:runLength*self->bytespp];
		} else {
			[outputStream write:self->data+chunkStart maxLength:self->bytespp];
		}
		
		if (outputStream.streamStatus == NSStreamStatusError) {
			return NO;
		}
	}
	return YES;
}

#pragma mark Public Getters

- (int)getWidth {
	return self->width;
}

- (int)getHeight {
	return self->height;
}

- (int)getBytesPerPixel {
	return self->bytespp;
}

- (uint8_t *)getBuffer {
	return self->data;
}

@end
