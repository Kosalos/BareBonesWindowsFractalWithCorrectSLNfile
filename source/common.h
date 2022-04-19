// Control structure definition for HLSL

#ifdef SHADER
#define FLOAT4 float4
#define INTEGER4 int4
#define MULTIPLIER P0.x	// individual float names
#define FOAM P0.y
#define FOAM2 P0.z
#define BEND P0.w
#define XMIN P1.x
#define XMAX P1.y
#define YMIN P1.z
#define YMAX P1.w
#define DX   P2.x
#define DY   P2.y
#define POWER P2.z

#define XSIZE			I1.x
#define YSIZE			I1.y
#define MAXSTEPS		I1.z
#define FSTYLE			I1.w

cbuffer Control : register(b0)

#else
// Control structure definition for C++
#pragma once
#include "stdafx.h"

#define _CRT_SECURE_NO_WARNINGS
#pragma warning( disable : 4305 ) // double as float
#pragma warning( disable : 4244 ) // double as float
#pragma warning( disable : 4127 ) // constexpr

void abortProgram(const char* name, int line);
#define ABORT(hr) if(FAILED(hr)) { abortProgram(__FILE__,__LINE__); }

template <class T>
void SafeRelease(T** ppT) { if (*ppT) { (*ppT)->Release(); *ppT = NULL; } }

#define FLOAT4 XMFLOAT4
#define INTEGER4 XMINT4
#define MULTIPLIER control.P0.x
#define FOAM control.P0.y
#define FOAM2 control.P0.z
#define BEND control.P0.w
#define XMIN control.P1.x
#define XMAX control.P1.y
#define YMIN control.P1.z
#define YMAX control.P1.w
#define DX   control.P2.x
#define DY   control.P2.y
#define POWER control.P2.z

#define XSIZE			control.I1.x
#define YSIZE			control.I1.y
#define MAXSTEPS		control.I1.z
#define FSTYLE			control.I1.w

struct Control

#endif

// Control structure definition.  ensure 16 byte alighment
{
	FLOAT4 camera;
	FLOAT4 viewVector, topVector, sideVector;
	FLOAT4 P0, P1, P2;

	INTEGER4 I1;
};

#define APOLLONIAN 0
#define MANDELBROT 1