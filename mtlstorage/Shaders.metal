//
//  Shaders.metal
//  mtlstorage
//
//  Created by Bulcsu Andrasi on 2019. 12. 12..
//  Copyright © 2019. Bulcsu Andrasi. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VS_IN {
	float4 position [[attribute(0)]];
	float4 color [[attribute(1)]];
};

struct VS_OUT {
	float4 position [[position]];
	float4 color;
};

vertex VS_OUT vs_main(VS_IN input [[stage_in]]) {
	VS_OUT output;
	output.position = input.position;
	output.color = input.color;
	return output;
}

fragment float4 fs_main(VS_OUT input [[stage_in]]) {
	return input.color;
}
