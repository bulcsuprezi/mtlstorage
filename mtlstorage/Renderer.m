//
//  Renderer.m
//  mtlstorage
//
//  Created by Bulcsu Andrasi on 2019. 12. 12..
//  Copyright © 2019. Bulcsu Andrasi. All rights reserved.
//

#import "Renderer.h"

#define MANAGED 0
#define INTEGRATED_GPU 0
#define USE_PIXEL_SHADER 01
#define COMPLETION_HANDLER 01

#define rows 512
#define cols 512
#define verts (2*rows*cols)

typedef struct {
	float pos[3];
	uint32_t color;
} Vertex;

@implementation Renderer {
	id<MTLDevice> _device;
	id<MTLLibrary> _shaderLib;
	id<MTLRenderPipelineState> _pipelineState;
	id<MTLBuffer> _vertexBuffer;
	id<MTLCommandQueue> _commandQueue;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {

}

- (void)drawInMTKView:(MTKView *)view {
	id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
	id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:view.currentRenderPassDescriptor];
	[encoder setRenderPipelineState:_pipelineState];
	[encoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
	[encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:verts];
	[encoder endEncoding];
	[commandBuffer presentDrawable:view.currentDrawable];
#if COMPLETION_HANDLER
	[commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> cmdBuf) {
		NSLog(@"%f", cmdBuf.GPUEndTime - cmdBuf.GPUStartTime);
	}];
#endif
	[commandBuffer commit];
}

- (void)awakeFromNib {
#if INTEGRATED_GPU
	NSArray* devices = MTLCopyAllDevices();
	for (id<MTLDevice> device in devices) {
		if (device.isLowPower) {
			_device = device;
			break;
		}
	}
#else
	_device = MTLCreateSystemDefaultDevice();
#endif
	NSLog(@"%@", _device);
	_shaderLib = [_device newDefaultLibrary];

	_view.delegate = self;
	_view.device = _device;

	MTLRenderPipelineDescriptor *pipelineDesc = [MTLRenderPipelineDescriptor new];
	pipelineDesc.vertexFunction = [_shaderLib newFunctionWithName:@"vs_main"];
	MTLVertexDescriptor *vertexDesc = [MTLVertexDescriptor new];
	vertexDesc.attributes[0].format = MTLVertexFormatFloat3;
	vertexDesc.attributes[0].offset = offsetof(Vertex, pos);
	vertexDesc.attributes[1].format = MTLVertexFormatUChar4Normalized;
	vertexDesc.attributes[1].offset = offsetof(Vertex, color);
	vertexDesc.layouts[0].stride = sizeof(Vertex);
	pipelineDesc.vertexDescriptor = vertexDesc;
#if USE_PIXEL_SHADER
	pipelineDesc.fragmentFunction = [_shaderLib newFunctionWithName:@"fs_main"];
#endif
	pipelineDesc.colorAttachments[0].pixelFormat = _view.colorPixelFormat;
	_pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDesc error:NULL];

	static Vertex vertexData[verts];

	float rowHeight = 2.0f / rows;
	float colWidth = 2.0f / cols;
	int cnt = 0;
	float y = -1;
	for (int i=0; i<rows; i++) {
		float x = -1;
		for (int j=0; j<cols; j++) {
			Vertex *v0 = vertexData + cnt++;
			v0->pos[0] = x;
			v0->pos[1] = y;
			v0->pos[2] = 0;
			v0->color = rand();

			Vertex *v1 = vertexData + cnt++;
			v1->pos[0] = x;
			v1->pos[1] = y + rowHeight;
			v1->pos[2] = 0;
			v1->color = rand();

			x += colWidth;
		}
		y += rowHeight;
	}

	MTLResourceOptions options = 0;
#if MANAGED
	options |= MTLResourceStorageModeManaged;
#endif
	_vertexBuffer = [_device newBufferWithLength:sizeof(vertexData) options:options];

	memcpy(_vertexBuffer.contents, vertexData, sizeof(vertexData));
#if MANAGED
	[_vertexBuffer didModifyRange: NSMakeRange(0, sizeof(vertexData))];
#endif

	_commandQueue = [_device newCommandQueue];
}

@end
