// Copyright (c) 2019 @Feyris77
// Released under the MIT license
// https://opensource.org/licenses/mit-license.php
Shader "Unlit/Trochoid"
{
	Properties
	{
		[Header(Line Setting)]
		_Line_Size("Line Size  [線の太さ]", float) = 0.1
		[Toggle] _Sync_Object_Scale("Sync Object Scale to Line Scale  [Transformに同期]", float) = 1
		[Header(Color Setting)]
		_Hue_Shift("Hue [色相]", Range(0, 1)) = 0.6
		_Hue_Range("Hue Range  [色相範囲]", Range(0, 1)) = 0.6
		_Saturation("Saturation  [彩度]", Range(0, 1)) = 0.6
		_Brightness("Brightness  [明度]", Range(0, 1)) = 0.6
		_Hue_Shift_Speed("Auto Hue Shift Speed  [自動色相変化速度]", Range(0, 1)) = 0
		[Header(Shape Setting)]
		_Speed("Change Speed  [変形速度]", Range(0, 1)) = 1
		rz("Thickness  [厚み]", float) = 0
		ro("Parameter 0", Range(0, 10)) = 0
		[IntRange]rc("Parameter 1", Range(0, 32)) = 0
		rm("Parameter 2", Range(0, 4)) = 0
		rd("Parameter 3", Range(-8, 8)) = 0
		rr("Parameter 4", Range(0, 16)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
		LOD 100
		Blend One One
		ZWrite off
		Pass
		{
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geo

			#include "UnityCG.cginc"

			#pragma shader_feature _SYNC_OBJECT_SCALE_ON

			struct v2g
			{
				float4 pos : TEXCOORD0;
				uint   id  : TEXCOORD1;
				float4 col : COLOR;
			};

			struct g2f
			{
				float4 pos : POSITION;
				float4 col : COLOR;
			};

			uniform float _Line_Size, _Speed;
			uniform float _Hue_Shift, _Hue_Shift_Speed, _Hue_Range, _Saturation, _Brightness;
			uniform float ro, rc, rm, rd, rz, rr;

			float3 hsv2rgb(float h, float s, float v)
			{
				return ((clamp(abs(frac(h+float3(0,2,1)/3)*6-3)-1,0,1)-1)*s+1)*v;
			}

			float getObjectScale()
			{
				float4x4 o2w = unity_ObjectToWorld;
				return (length(o2w._m00_m10_m20) + length(o2w._m01_m11_m21) + length(o2w._m02_m12_m22)) / 3;
			}

			v2g vert (uint ID : SV_VertexID)
			{
				v2g o;
				float id = float(ID);

				float t = fmod(_Speed * _Time.y * 0.2 + id*ro , UNITY_PI * 2);
				float r = rc + rm;

				o.pos.x = r * cos(t) - rd * cos(r / rm * t) * rr;
				o.pos.y = r * sin(t) - rd * sin(r / rm * t) * rr;
				o.pos.z = cos(r / rm * t * 2) * sin(r / rm * t * 2) * rz;
				o.pos.xyz *= 0.01;

				float h = _Hue_Shift + UNITY_PI * sin(_Time.y * _Hue_Shift_Speed + id * .02) * _Hue_Range;
				o.col = float4(hsv2rgb(h, _Saturation, _Brightness), 1);
				o.id = id;
				return o;
			}


			[maxvertexcount(4)]
			void geo(line v2g v[2], inout TriangleStream<g2f> ts)
			{
				g2f o;
				o.col = (v[0].col + v[1].col)*.5;

				float4 posA = UnityObjectToClipPos(v[0].pos);
				float4 posB = UnityObjectToClipPos(v[1].pos);

				float2 dir = normalize(posB.xy - posA.xy);
				float2 normal = float2(-dir.y, dir.x);

				#ifdef _SYNC_OBJECT_SCALE_ON
					_Line_Size *= getObjectScale();
				#endif

				float4 offset = float4(normal * _Line_Size, 0, 0);

				if(v[0].id)
				{
					o.pos = posA + offset;
					ts.Append(o);
					o.pos = posA - offset;
					ts.Append(o);
					o.pos = posB + offset;
					ts.Append(o);
					o.pos = posB - offset;
					ts.Append(o);
					ts.RestartStrip();
				}
			}

			float4 frag (g2f i) : SV_Target
			{
				return i.col;
			}
			ENDCG
		}
	}
}