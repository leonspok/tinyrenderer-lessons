//
//  CouraudShader.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 02/02/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "GouraudShader.h"

@interface GouraudShader()
@property (nonatomic) LPTransform uniform;
@property (nonatomic) LPTransform uniformIT;
@property (nonatomic) LPTransform transform;
@property (nonatomic) LPVector lightDirection;
@property (nonatomic, weak) WFModel *model;
@end

@implementation GouraudShader

- (id)initWithModel:(WFModel *)model
		 projection:(LPTransform)projection
		   viewPort:(LPTransform)viewPort
		  modelView:(LPTransform)modelView
	 lightDirection:(LPVector)lightDirection {
	self = [self init];
	if (self) {
		self.model = model;
		self.transform = LPTransformMultiply(LPTransformMultiply(viewPort, projection), modelView);
		self.uniform = LPTransformMultiply(projection, modelView);
		self.uniformIT = LPTranformInverseTranspose(self.uniform);
		self.lightDirection = lightDirection;
		//self.lightDirection = LPVectorApplyTransform(lightDirection, self.uniform);
	}
	return self;
}

- (LP4DCoordinate)vertextForFaceElementAtIndex:(NSUInteger)faceElementIx part:(int)part {
	WFFaceElement *fPointer = [self.model faceElementForIndex:faceElementIx];
	if (fPointer == NULL) {
		return (LP4DCoordinate){ .v = {0, 0, 0, 0}};
	}
	WFNormal *normal = [self.model normalForIndex:fPointer->parts[part].normalIx];
	if (normal == NULL) {
		return (LP4DCoordinate){ .v = {0, 0, 0, 0}};
	}
	WFVertex *vertex = [self.model vertexForIndex:fPointer->parts[part].vertexIx];
	if (vertex == NULL) {
		return (LP4DCoordinate){ .v = {0, 0, 0, 0}};
	}
	self->varyingIntensity[part] = MAX(0.0f, LPVectorDotProduct(*normal, self.lightDirection));
	
	LP4DCoordinate coordinate = {
		.v = {
			vertex->x, vertex->y, vertex->z, 1
		}
	};
	return LP4DCoordinateApplyTransform(coordinate, self.transform);
}

- (BOOL)fragment:(LPBaricentricCoordinate)bar color:(TGAColor *)color {
	float intensity = 0;
	for (int i = 0; i < 3; i++) {
		intensity += self->varyingIntensity[i]*bar.v[i];
	}
	*color = TGAColorCreateRGBA(255, 255, 255, 255);
	for (int i = 0; i < color->bytespp; i++) {
		color->raw[i] *= intensity;
	}
	return NO;
}

@end
