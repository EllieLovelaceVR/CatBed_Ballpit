
#ifndef WATER_FUNCTIONS_INCLUDED
#define WATER_FUNCTIONS_INCLUDED

float2 ScaleUV(float2 uv, float2 scale, float2 scroll){
	return (uv + scroll * _Time.y * 0.1) * scale;
}


float3 BoxProjection(float3 dir, float3 pos, float4 cubePos, float3 boxMin, float3 boxMax){
	#if UNITY_SPECCUBE_BOX_PROJECTION
		UNITY_BRANCH
		if (cubePos.w > 0){
			float3 factors = ((dir > 0 ? boxMax : boxMin) - pos) / dir;
			float scalar = min(min(factors.x, factors.y), factors.z);
			dir = dir * scalar + (pos - cubePos);
		}
	#endif
	return dir;
}

float3 GetWorldReflections(float3 reflDir, float3 worldPos, float roughness){
	roughness *= 1.7-0.7*roughness;
	float4 envSample0 = texCUBElod(_EnvironmentCube, float4(reflDir, roughness * UNITY_SPECCUBE_LOD_STEPS));
	return DecodeHDR(envSample0, _EnvironmentCube_HDR);
}

float SpecularTerm(float NdotL, float NdotV, float NdotH, float roughness){
	float visibilityTerm = 0;
	if (NdotL > 0){
		float rough = roughness;
		float rough2 = roughness * roughness;

		float lambdaV = NdotL * (NdotV * (1 - rough) + rough);
		float lambdaL = NdotV * (NdotL * (1 - rough) + rough);

		visibilityTerm = 0.5f / (lambdaV + lambdaL + 1e-5f);
		float d = (NdotH * rough2 - NdotH) * NdotH + 1.0f;
		float dotTerm = UNITY_INV_PI * rough2 / (d * d + 1e-7f);

		visibilityTerm *= dotTerm * UNITY_PI;
	}
	return visibilityTerm;
}

float FadeShadows (float3 worldPos, float atten) {
	#if HANDLE_SHADOWS_BLENDING_IN_GI
		float viewZ = dot(_WorldSpaceCameraPos - worldPos, UNITY_MATRIX_V[2].xyz);
		float shadowFadeDistance = UnityComputeShadowFadeDistance(worldPos, viewZ);
		float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
		atten = saturate(atten + shadowFade);
	#endif
	return atten;
}

float GetDepth(v2f i, float2 screenUV){
	#if UNITY_UV_STARTS_AT_TOP
		if (_CameraDepthTexture_TexelSize.y < 0) {
			screenUV.y = 1 - screenUV.y;
		}
	#endif
	float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV));
	float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.uvGrab.z);
	float depthDifference = backgroundDepth - surfaceDepth;
	return depthDifference / 20;
}

float2 AlignWithGrabTexel(float2 uv) {
	#if UNITY_UV_STARTS_AT_TOP
		if (_CameraDepthTexture_TexelSize.y < 0) {
			uv.y = 1 - uv.y;
		}
	#endif
	return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs(_CameraDepthTexture_TexelSize.xy);
}

float3 FlowUV (float2 uv, float2 flowVector, float time, float phase) {
	float progress = frac(time + phase);
	float3 uvw;
	uvw.xy = uv - flowVector * progress;
	uvw.xy += phase;
	uvw.xy += (time - progress) * jump;
	uvw.z = 1 - abs(1 - 2 * progress);
	return uvw;
}

float3 GerstnerWave(float4 wave, float3 vertex, float speed){
	float k = 2 * UNITY_PI / wave.w;
	float c = sqrt(9.8/k);
	float2 dir = normalize(wave.xy);
	float f = k * (dot(dir,vertex.xz) - c * _Time.y*0.2*speed);
	float a = wave.z / k;
	return float3(0, a * sin(f), dir.y * (a*cos(f)));
}

#endif // WATER_FUNCTIONS_INCLUDED