Shader "Custom/3DButtonTexture"
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

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
            #include "tanoise/tanoise.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _TextureDetail;
        half _Metallic;
        half _TextureAnimation;
        half _NoisePow, _RockAmbient;
		half4 _EmissionMux;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        float4 densityat( float3 calcpos )
        {
            float tim = glsl_mod(_Time.y,1000)*_TextureAnimation;
            
            float4 col =
                glsl_mod( abs( tanoise4( float4( calcpos*10., tim ) ) - 0.5 ) * 10., 1. ) * float4( 1., .5, 1., 1. ) +
				0;
            return col;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            float3 calcpos = IN.worldPos.xyz * _TextureDetail;
            
            float4 col = densityat( calcpos );
            c *= pow( col.xyzw, _NoisePow) + _RockAmbient;
            o.Normal = normalize( float3( col.x, col.y, 1.5 ) );
            
            o.Albedo = c.rgb;
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