// apollonian: https://www.shadertoy.com/view/4ds3zn

#define SHADER
#include "common.h"

#define MAX_MARCHING_STEPS 255
#define MIN_DIST 0.00002 
#define MAX_DIST 60.0
#define PI 3.1415926

struct DEResult {
	float3 pos;
	float dist, iter;
};

DEResult resultInit() {
	DEResult ans;
	ans.dist = 0;
	ans.iter = 0;
	return ans;
}

DEResult DE(float3 pos) {
	DEResult result = resultInit();
	float k, t = FOAM2 + 0.25 * cos(BEND * PI * MULTIPLIER * (pos.z - pos.x));
	float scale = 1;

	for (int i = 0; i < MAXSTEPS; ++i) {
		pos = -1.0 + 2.0 * frac(0.5 * pos + 0.5);
		k = FOAM * t / dot(pos, pos);
		pos *= k;
		scale *= k;
	}

	result.dist = 1.5 * (0.25 * abs(pos.y) / scale);
	return result;
}

// -----------------------------------------------------------

float3 calcNormal(float3 pos) {
	float2 e = float2(1.0, -1.0) * 0.057;
	return normalize(
		e.xyy * DE(pos + e.xyy).dist +
		e.yyx * DE(pos + e.yyx).dist +
		e.yxy * DE(pos + e.yxy).dist +
		e.xxx * DE(pos + e.xxx).dist);
}

// -----------------------------------------------------------

DEResult shortest_dist(float3 eye, float3 dir) {
	DEResult result;
	float hop = 0;
	float dist = MIN_DIST;
	int i = 0;

	for (; i < MAX_MARCHING_STEPS; ++i) {
		result = DE(eye + dist * dir);

		if (result.dist < MIN_DIST) break;

		dist += result.dist;
		if (dist >= MAX_DIST) break;
	}

	result.dist = dist;
	result.iter = float(i);

	return result;
}

// -----------------------------------------------------------

float2 complexPower(float2 value, float power) {
	float rr = dot(value, value); // value.x* value.x + value.y * value.y; // radius squared
	if (rr == 0) return 0.0001;

	float p1 = pow(rr, power / 2);
	float arg = atan2(value.y, value.x);
	float2 p2 = float2(cos(power * arg), sin(power * arg));
	return p1 * p2;
}

// -----------------------------------------------------------

Texture2D<float4>   InputMap  : register(t0);
RWTexture2D<float4> OutputMap : register(u0);

[numthreads(12, 12, 1)]
void CSMain(
	uint3 p:SV_DispatchThreadID)
{
	if (p.x >= uint(XSIZE) || p.y >= uint(YSIZE)) return;

	float3 color = float3(0, 0, 0);

	if (FSTYLE == APOLLONIAN) {
		float den = float(YSIZE);
		float dx = 1.5 * (float(p.x) / den - 0.5);
		float dy = -1.5 * (float(p.y) / den - 0.5);
		float3 direction = normalize((sideVector * dx) + (topVector * dy) + viewVector).xyz;
		DEResult result = shortest_dist(camera.xyz, direction);

		if (result.dist <= MAX_DIST - 0.0001) {
			float3 position = camera.xyz + result.dist * direction;
			float3 cc, normal = calcNormal(position);

			color = float3(1 - (normal / 10 + sqrt(result.iter / 80.0)));
		}
	}
	else { // Mandelbrot
		float2 c = float2(XMIN + DX * float(p.x), YMIN + DY * float(p.y));
		float2 z = float2(0, 0);
		int i;

		for (i = 0; i < MAXSTEPS; ++i) {
			z = complexPower(z, POWER) + c;

			if (dot(z, z) > 4) break;
		}

		float ratio = float(i) / float(MAXSTEPS);
		color.x = 1.0 - ratio * 3;
		color.y = color.x;
		color.z = color.x;
	}

	OutputMap[p.xy] = float4(color, 1);
}
