//
//  PhongShader.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 03/02/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "PhongShader.h"

@interface PhongShader()
@property (nonatomic) LPTransform uniform;
@property (nonatomic) LPTransform uniformIT;
@property (nonatomic) LPTransform transform;
@property (nonatomic) LPVector lightDirection;
@property (nonatomic, weak) WFModel *model;
@end

@implementation PhongShader

- (id)initWithModel:(WFModel *)model
		 projection:(LPTransform)projection
		   viewPort:(LPTransform)viewPort
		  modelView:(LPTransform)modelView
	 lightDirection:(LPVector)lightDirection {
	self = [self init];
	if (self) {
		self.model = model;
		self.uniform = LPTransformMultiply(projection, modelView);
		self.uniformIT = LPTranformInverseTranspose(self.uniform);
		self.transform = LPTransformMultiply(viewPort, self.uniform);
		//self.lightDirection = lightDirection;
		self.lightDirection = LPVectorApplyTransform(lightDirection, self.uniform);
	}
	return self;
}

- (LP4DCoordinate)vertextForFaceElementAtIndex:(NSUInteger)faceElementIx part:(int)part {
	WFFaceElement *fPointer = [self.model faceElementForIndex:faceElementIx];
	if (fPointer == NULL) {
		return (LP4DCoordinate){ .v = {0, 0, 0, 0}};
	}
	WFVertex *vertex = [self.model vertexForIndex:fPointer->parts[part].vertexIx];
	if (vertex == NULL) {
		return (LP4DCoordinate){ .v = {0, 0, 0, 0}};
	}
	WFTextureCoordinate *textureCoordinate = [self.model textureCoordinateForIndex:fPointer->parts[part].textureCoordinateIx];
	if (textureCoordinate == NULL) {
		return (LP4DCoordinate){ .v = {0, 0, 0, 0}};
	}
	
	self->varyingTC[part] = *textureCoordinate;
	
	LP4DCoordinate coordinate = {
		.v = {
			vertex->x, vertex->y, vertex->z, 1
		}
	};
	coordinate = LP4DCoordinateApplyTransform(coordinate, self.transform);
	return coordinate;
}

- (BOOL)fragment:(LPBaricentricCoordinate)bar color:(TGAColor *)color {
	WFTextureCoordinate tc = { .u = 0, .v = 0};
	for (int i = 0; i < 3; i++) {
		tc.u += self->varyingTC[i].u*bar.v[i];
		tc.v += self->varyingTC[i].v*bar.v[i];
	}
	
	LPVector n = {};
	TGAColor cl = [self.model.normalMap getColorAtX:roundf(tc.u*[self.model.normalMap getWidth]) y:roundf(tc.v*[self.model.normalMap getHeight])];
	n.dx = cl.r-127;
	n.dy = cl.g-127;
	n.dz = cl.b-127;
	n = LPVectorApplyTransform(n, self.uniformIT);
	
	float coef = LPVectorDotProduct(n, self.lightDirection)*2.0f;
	LPVector vect = (LPVector) {
		.dx = n.dx*coef, .dy = n.dy*coef, .dz = n.dz*coef
	};
	for (int i = 0; i < 3; i++) {
		vect.v[i] -= self.lightDirection.v[i];
	}
	vect = LPVectorNormalize(vect);
	
	float spec = powf(MAX(0.0f, vect.dz), [self.model.specularMap getColorAtX:roundf(tc.u*[self.model.normalMap getWidth]) y:roundf(tc.v*[self.model.normalMap getHeight])].raw[0]);
	float diff = MAX(0.0f, LPVectorDotProduct(n, self.lightDirection));
	
	*color = [self.model.diffuseTexture getColorAtX:roundf(tc.u*[self.model.diffuseTexture getWidth])
												  y:roundf(tc.v*[self.model.diffuseTexture getHeight])];
	for (int i = 0; i < color->bytespp; i++) {
		color->raw[i] = MIN(255, 5+color->raw[i]*(diff+0.6f*spec));
	}
	return NO;
}

@end
