/*
 * Copyright (c) 2018-2021 The Forge Interactive Inc.
 *
 * This file is part of The-Forge
 * (see https://github.com/ConfettiFX/The-Forge).
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
*/

#version 450 core

precision highp float;
precision highp int; 
vec4 MulMat(mat4 lhs, vec4 rhs)
{
    vec4 dst;
	dst[0] = lhs[0][0]*rhs[0] + lhs[0][1]*rhs[1] + lhs[0][2]*rhs[2] + lhs[0][3]*rhs[3];
	dst[1] = lhs[1][0]*rhs[0] + lhs[1][1]*rhs[1] + lhs[1][2]*rhs[2] + lhs[1][3]*rhs[3];
	dst[2] = lhs[2][0]*rhs[0] + lhs[2][1]*rhs[1] + lhs[2][2]*rhs[2] + lhs[2][3]*rhs[3];
	dst[3] = lhs[3][0]*rhs[0] + lhs[3][1]*rhs[1] + lhs[3][2]*rhs[2] + lhs[3][3]*rhs[3];
    return dst;
}


layout(location = 0) in vec3 POSITION;
layout(location = 1) in vec3 NORMAL;
layout(location = 2) in vec2 TEXCOORD0;
layout(location = 0) out vec3 vertOutput_POSITION;
layout(location = 1) out vec3 vertOutput_NORMAL;
layout(location = 2) out vec2 vertOutput_TEXCOORD0;

struct VsIn
{
    vec3 position;
    vec3 normal;
    vec2 texCoord;
};
layout(row_major, set = 1, binding = 0) uniform cbPerPass
{
    mat4 projView;
    mat4 shadowLightViewProj;
    vec4 camPos;
    vec4 lightColor[4];
    vec4 lightDirection[3];
};

layout(row_major, push_constant) uniform cbRootConstants_Block
{
    uint nodeIndex;
} cbRootConstants;

layout(row_major, set = 0, binding = 0) buffer modelToWorldMatrices
{
    mat4 modelToWorldMatrices_Data[];
};

struct PsIn
{
    vec3 pos;
    vec3 normal;
    vec2 texCoord;
    vec4 position;
};

PsIn HLSLmain(VsIn In)
{
    mat4 modelToWorld = modelToWorldMatrices_Data[cbRootConstants.nodeIndex];
    PsIn Out;
    vec4 inPos = vec4(In.position.xyz, 1.0);
    vec3 inNormal = In.normal;
    vec4 worldPosition = MulMat(modelToWorld,inPos);
    ((Out).position = MulMat(projView,worldPosition));
    ((Out).pos = (worldPosition).xyz);
    ((Out).normal = normalize(MulMat(modelToWorld, vec4(inNormal, 0)).xyz));
    ((Out).texCoord = vec2(((In).texCoord).xy));
    return Out;
}
void main()
{
    VsIn In;
    In.position = POSITION;
    In.normal = NORMAL;
    In.texCoord = TEXCOORD0;
    PsIn result = HLSLmain(In);
    vertOutput_POSITION = result.pos;
    vertOutput_NORMAL = result.normal;
    vertOutput_TEXCOORD0 = result.texCoord;
    gl_Position = result.position;
}
