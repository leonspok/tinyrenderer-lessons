//
//  WFModel.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGAImage.h"
#import "GeometryHelpers.h"

typedef LPPoint WFVertex;

typedef struct {
	float u, v;
} WFTextureCoordinate;

typedef LPVector WFNormal;

typedef struct {
	NSUInteger vertexIx, textureCoordinateIx, normalIx;
} WFFaceElementPart;

typedef struct {
	WFFaceElementPart parts[3];
} WFFaceElement;

@interface WFModel : NSObject {
	WFVertex *vertices;
	WFTextureCoordinate *textureCoordinates;
	WFNormal *normals;
	WFFaceElement *faceElements;
}

- (void)loadFromFile:(NSString *)path;

@property (nonatomic, readonly) NSUInteger vCount;
@property (nonatomic, readonly) NSUInteger vtCount;
@property (nonatomic, readonly) NSUInteger vnCount;
@property (nonatomic, readonly) NSUInteger fCount;

@property (nonatomic, strong) TGAImage *diffuseTexture;
@property (nonatomic, strong) TGAImage *normalMap;
@property (nonatomic, strong) TGAImage *specularMap;

- (WFVertex *)vertexForIndex:(NSUInteger)index;
- (WFTextureCoordinate *)textureCoordinateForIndex:(NSUInteger)index;
- (WFNormal *)normalForIndex:(NSUInteger)index;
- (WFFaceElement *)faceElementForIndex:(NSUInteger)index;

@end
