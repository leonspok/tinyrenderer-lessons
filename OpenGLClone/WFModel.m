//
//  WFModel.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "WFModel.h"

@implementation WFModel

@synthesize vCount = _vCount, vnCount = _vnCount, vtCount = _vtCount, fCount = _fCount;

- (void)dealloc {
	if (self->vertices != NULL) {
		free(self->vertices);
	}
	if (self->textureCoordinates != NULL) {
		free(self->textureCoordinates);
	}
	if (self->normals != NULL) {
		free(self->normals);
	}
	if (self->faceElements != NULL) {
		free(self->faceElements);
	}
}

#pragma mark Public methods and getters

- (NSUInteger)vCount {
	if (_vCount == 0) {
		if (self->vertices == NULL) {
			return 0;
		} else {
			_vCount = sizeof(self->vertices)/sizeof(WFVertex);
			return _vCount;
		}
	} else {
		return _vCount;
	}
}

- (NSUInteger)vtCount {
	if (_vtCount == 0) {
		if (self->textureCoordinates == NULL) {
			return 0;
		} else {
			_vtCount = sizeof(self->textureCoordinates)/sizeof(WFTextureCoordinate);
			return _vtCount;
		}
	} else {
		return _vtCount;
	}
}

- (NSUInteger)vnCount {
	if (_vnCount == 0) {
		if (self->normals == NULL) {
			return 0;
		} else {
			_vnCount = sizeof(self->normals)/sizeof(WFNormal);
			return _vnCount;
		}
	} else {
		return _vnCount;
	}
}

- (NSUInteger)fCount {
	if (_fCount == 0) {
		if (self->faceElements == NULL) {
			return 0;
		} else {
			_fCount = sizeof(self->faceElements)/sizeof(WFFaceElement);
			return _fCount;
		}
	} else {
		return _fCount;
	}
}

- (WFVertex *)vertexForIndex:(NSUInteger)index {
	if (self->vertices == NULL || index == 0 || index > self.vCount) {
		return NULL;
	}
	return &self->vertices[index-1];
}

- (WFTextureCoordinate *)textureCoordinateForIndex:(NSUInteger)index {
	if (self->textureCoordinates == NULL || index == 0 || index > self.vtCount) {
		return NULL;
	}
	return &self->textureCoordinates[index-1];
}

- (WFNormal *)normalForIndex:(NSUInteger)index {
	if (self->normals == NULL || index == 0 || index > self.vnCount) {
		return NULL;
	}
	return &self->normals[index-1];
}

- (WFFaceElement *)faceElementForIndex:(NSUInteger)index {
	if (self->faceElements == NULL || index == 0 || index > self.fCount) {
		return NULL;
	}
	return &self->faceElements[index-1];
}

#pragma mark Parsing

- (void)loadFromFile:(NSString *)path {
	FILE *fp;
	char *line = NULL;
	size_t len = 0;
	size_t read;
	
	fp = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "r");
	if (fp == NULL) {
		return;
	}
	
	@autoreleasepool {
		NSMutableArray *vs = [NSMutableArray array];
		NSMutableArray *vts = [NSMutableArray array];
		NSMutableArray *vns = [NSMutableArray array];
		NSMutableArray *fs = [NSMutableArray array];
		
		while ((read = getline(&line, &len, fp)) != -1) {
			if (read < 3) {
				continue;
			}
			
			switch (line[0]) {
				case '#':
					continue;
					break;
				case 'v': {
					switch (line[1]) {
						case ' ': {
							WFVertex *vertex = malloc(sizeof(WFVertex));
							if ([self parseVertex:vertex fromLine:line length:read]) {
								[vs addObject:[NSValue valueWithPointer:vertex]];
							}
						}
							break;
						case 't': {
							WFTextureCoordinate *coordinate = malloc(sizeof(WFTextureCoordinate));
							if ([self parseTextureCoordinate:coordinate fromLine:line length:read]) {
								[vts addObject:[NSValue valueWithPointer:coordinate]];
							}
						}
							break;
						case 'n': {
							WFNormal *normal = malloc(sizeof(WFNormal));
							if ([self parseNormal:normal fromLine:line length:read]) {
								[vns addObject:[NSValue valueWithPointer:normal]];
							}
						}
							break;
					}
				}
					break;
				case 'f': {
					WFFaceElement *faceElement = malloc(sizeof(WFFaceElement));
					if ([self parseFaceElement:faceElement fromLine:line length:read]) {
						[fs addObject:[NSValue valueWithPointer:faceElement]];
					}
				}
					break;
			}
		}
		
		if (self->vertices != NULL) {
			free(self->vertices);
		}
		self->vertices = malloc(sizeof(WFVertex)*vs.count);
		_vCount = vs.count;
		for (NSUInteger i = 0; i < vs.count; i++) {
			NSValue *value = [vs objectAtIndex:i];
			WFVertex *vertex = (WFVertex *)value.pointerValue;
			self->vertices[i] = *vertex;
			free(vertex);
		}
		
		if (self->textureCoordinates != NULL) {
			free(self->textureCoordinates);
		}
		self->textureCoordinates = malloc(sizeof(WFTextureCoordinate)*vts.count);
		_vtCount = vts.count;
		for (NSUInteger i = 0; i < vts.count; i++) {
			NSValue *value = [vts objectAtIndex:i];
			WFTextureCoordinate *coordinate = (WFTextureCoordinate *)value.pointerValue;
			self->textureCoordinates[i] = *coordinate;
			free(coordinate);
		}
		
		if (self->normals != NULL) {
			free(self->normals);
		}
		self->normals = malloc(sizeof(WFNormal)*vns.count);
		_vnCount = vns.count;
		for (NSUInteger i = 0; i < vns.count; i++) {
			NSValue *value = [vns objectAtIndex:i];
			WFNormal *normal = (WFNormal *)value.pointerValue;
			self->normals[i] = *normal;
			free(normal);
		}
		
		if (self->faceElements != NULL) {
			free(self->faceElements);
		}
		self->faceElements = malloc(sizeof(WFFaceElement)*fs.count);
		_fCount = fs.count;
		for (NSUInteger i = 0; i < fs.count; i++) {
			NSValue *value = [fs objectAtIndex:i];
			WFFaceElement *faceElement = (WFFaceElement *)value.pointerValue;
			self->faceElements[i] = *faceElement;
			free(faceElement);
		}
	}
	
	fclose(fp);
}

- (BOOL)parseVertex:(WFVertex *)vertex fromLine:(char *)line length:(size_t)length {
	NSString *str = [[[NSString alloc] initWithCString:line encoding:NSUTF8StringEncoding] substringWithRange:NSMakeRange(0, length-1)];
	NSArray<NSString *> *components = [str componentsSeparatedByString:@" "];
	if (components.count < 4) {
		return NO;
	}
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setLocalizesFormat:NO];
	float (^parseNumber)(NSString *str) = ^float(NSString *str){
		return [[numberFormatter numberFromString:[str stringByReplacingOccurrencesOfString:@"," withString:@"."]] floatValue];
	};
	
	(*vertex).x = parseNumber(components[1]);
	(*vertex).y = parseNumber(components[2]);
	(*vertex).z = parseNumber(components[3]);
	
	return YES;
}

- (BOOL)parseTextureCoordinate:(WFTextureCoordinate *)coordinate fromLine:(char *)line length:(size_t)length {
	NSString *str = [[[NSString alloc] initWithCString:line encoding:NSUTF8StringEncoding] substringWithRange:NSMakeRange(0, length-1)];
	NSArray<NSString *> *components = [str componentsSeparatedByString:@" "];
	if (components.count < 3) {
		return NO;
	}
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setLocalizesFormat:NO];
	float (^parseNumber)(NSString *str) = ^float(NSString *str){
		return [[numberFormatter numberFromString:[str stringByReplacingOccurrencesOfString:@"," withString:@"."]] floatValue];
	};
	
	(*coordinate).u = parseNumber(components[1]);
	(*coordinate).v = parseNumber(components[2]);
	
	return YES;
}

- (BOOL)parseNormal:(WFNormal *)normal fromLine:(char *)line length:(size_t)length {
	NSString *str = [[[NSString alloc] initWithCString:line encoding:NSUTF8StringEncoding] substringWithRange:NSMakeRange(0, length-1)];
	NSArray<NSString *> *components = [str componentsSeparatedByString:@" "];
	if (components.count < 4) {
		return NO;
	}
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setLocalizesFormat:NO];
	float (^parseNumber)(NSString *str) = ^float(NSString *str){
		return [[numberFormatter numberFromString:[str stringByReplacingOccurrencesOfString:@"," withString:@"."]] floatValue];
	};
	
	(*normal).dx = parseNumber(components[1]);
	(*normal).dy = parseNumber(components[2]);
	(*normal).dz = parseNumber(components[3]);
	
	return YES;
}

- (BOOL)parseFaceElement:(WFFaceElement *)faceElement fromLine:(char *)line length:(size_t)length {
	NSString *str = [[[NSString alloc] initWithCString:line encoding:NSUTF8StringEncoding] substringWithRange:NSMakeRange(0, length-1)];
	NSArray<NSString *> *components = [str componentsSeparatedByString:@" "];
	if (components.count < 4) {
		return NO;
	}
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setLocalizesFormat:NO];
	NSUInteger (^parseNumber)(NSString *str) = ^NSUInteger(NSString *str){
		return [[numberFormatter numberFromString:[str stringByReplacingOccurrencesOfString:@"," withString:@"."]] unsignedIntegerValue];
	};
	
	for (NSUInteger i = 1; i <= 3; i++) {
		NSArray<NSString *> *numbersComponents = [components[i] componentsSeparatedByString:@"/"];
		switch (numbersComponents.count) {
			case 3:
				(*faceElement).parts[i-1].normalIx = parseNumber(numbersComponents[2]);
			case 2:
				(*faceElement).parts[i-1].textureCoordinateIx = parseNumber(numbersComponents[1]);
			case 1:
				(*faceElement).parts[i-1].vertexIx = parseNumber(numbersComponents[0]);
				break;
			default:
				return NO;
		}
	}
	
	return YES;
}

@end
