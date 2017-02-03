//
//  TextureShader.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 03/02/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Shader.h"

@interface TextureShader : NSObject<Shader> {
	float varyingIntensity[3];
	WFTextureCoordinate varyingTC[3];
}

- (id)initWithModel:(WFModel *)model
		 projection:(LPTransform)projection
		   viewPort:(LPTransform)viewPort
		  modelView:(LPTransform)modelView
	 lightDirection:(LPVector)lightDirection;

@end
