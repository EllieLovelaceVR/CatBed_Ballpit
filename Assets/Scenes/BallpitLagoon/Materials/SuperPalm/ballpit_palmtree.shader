﻿Shader "SuperPalm/ballpit_palmtree"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_TextureDetail ("Detail", float)=1.0
		_TextureAnimation ("Animation Speed", float)=1.0
		_TANoiseTex ("TANoise", 2D) = "white" {}
		_NoisePow ("Noise Power", float ) = 1.8
		_RockAmbient ("Rock Ambient Boost", float ) = 0.1
		_EmissionMux( "Emission Mux", Color) = (.3, .3, .3, 1. )
		_BarkColor( "Bark Color", Color ) = (1., 1., 1. ,1. )
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Cull Off

		// shadow caster rendering pass, implemented manually
		// using macros from UnityCG.cginc
		Pass
		{
			Tags {"LightMode"="ShadowCaster"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			struct v2f { 
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}


        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 4.0
		#include "/Assets/Shaders/tanoise/tanoise.cginc"

        sampler2D _MainTex;

   
		struct Input
		{
			float2 uv_MainTex;
			float2 uv2_MainTex;
			float3 worldPos;
			float3 objPos;
		};

		half _TextureDetail;
		half _TextureAnimation;
		half _NoisePow, _RockAmbient;
		half4 _EmissionMux;
		half4 _BarkColor;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)



        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
		    float3 worldScale = float3(
				length(float3(unity_ObjectToWorld[0].x, unity_ObjectToWorld[1].x, unity_ObjectToWorld[2].x)), // scale x axis
				length(float3(unity_ObjectToWorld[0].y, unity_ObjectToWorld[1].y, unity_ObjectToWorld[2].y)), // scale y axis
				length(float3(unity_ObjectToWorld[0].z, unity_ObjectToWorld[1].z, unity_ObjectToWorld[2].z))  // scale z axis
				);
            o.objPos = v.vertex*worldScale;
        }

		float densityat( float3 calcpos )
		{
			float tim = _Time.y*_TextureAnimation;
		   // calcpos.y += tim * _TextureAnimation;
			float4 col =
				tanoise4_1d( float4( float3( calcpos*10. ), tim ) ) * 0.5 +
				tanoise4_1d( float4( float3( calcpos.xyz*30.1 ), tim ) ) * 0.3 +
				tanoise4_1d( float4( float3( calcpos.xyz*90.2 ), tim ) ) * 0.2 +
				tanoise4_1d( float4( float3( calcpos.xyz*320.5 ), tim ) ) * 0.1 +
				tanoise4_1d( float4( float3( calcpos.xyz*641. ), tim ) ) * .08 +
				0;
			return col;
		}
		
		#define SIGMOID(x) ( 1./(1.+exp(-(x))))


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float3 calcpos = IN.objPos.xyz * _TextureDetail;
			float4 col = 0.;
			float2 normpert;
			
			if( IN.uv_MainTex.y <= 0.00 )
			{
				float2 uvoffset = .36;
				float segmentuv = glsl_mod( IN.uv_MainTex.y*8+uvoffset, 1. );
				float segmentno = floor( IN.uv_MainTex.y*8+uvoffset );
				
				float3 compos = float3( IN.uv_MainTex.x*1.5, SIGMOID( segmentuv*10.-5 )*.101 + segmentno*.1, 0 );
				
				float4 nrv = tanoise4( float4( compos.xyz*90.2, _Time.y*_TextureAnimation ) ) * .3;
				nrv = smoothstep( 0, 1, nrv );
				c = _BarkColor;
				c = c * (floor( (nrv.x + .9)*8 )/8 + nrv.y*.6);
				
				//Add some noise to the normal.
				normpert = tanoise4( float4( compos.xyz*200.5, _Time.y*_TextureAnimation ) ) * .4 +
					tanoise4( float4( compos.xyz*90.2, _Time.y*_TextureAnimation ) ) * .3;
				
			}
			else
			{
				//col = densityat( calcpos );
				col = saturate( pow( sin( IN.uv_MainTex.x*100. +IN.uv_MainTex.y*20. )* .2 + 1.0, 10. ) );
				c *= pow( col.xxxx, _NoisePow) + _RockAmbient;
				normpert = tanoise4( float4( calcpos.xyz*10.2, _Time.y*_TextureAnimation ) ) * .1;

			}
			

			o.Normal = normalize( float3( normpert.xy-.35, 1.5 ) );

			o.Albedo = c.rgb * 1.2;
			o.Emission = c * _EmissionMux;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;// * clamp( col.z*10.-7., 0, 1 );
			o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
