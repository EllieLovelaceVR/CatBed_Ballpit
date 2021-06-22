﻿//XXX TODO: Remember to credit d4rkpl4y3r with the bucketing tech.
//XXX TODO: Switch this back to uints from floats.

Shader "cnballpit/shaderAdjacency"
{
	Properties
	{
		_PositionsIn ("Positions", 2D) = "black" {}
		_VelocitiesIn ("Velocities", 2D) = "black" {}
		_Adjacency0 ("Adjacencies0", 2D) = "black" {}
		_Adjacency1 ("Adjacencies1", 2D) = "black" {}
		_Adjacency2 ("Adjacencies2", 2D) = "black" {}
		_wpass ("WPass", int) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geo

			#include "UnityCG.cginc"
			#include "cnballpit.cginc"

			int _wpass;

			struct appdata
			{
			};

			struct v2g
			{
			};

			struct g2f
			{
				float idplus1 : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			
			v2g vert (appdata v)
			{
				v2g o;
				return o;
			}

			[maxvertexcount(8)]
			void geo(point v2g p[1], inout PointStream<g2f> oStream, uint id : SV_PrimitiveID )
			{
				if( _ScreenParams.x != 1024 || _ScreenParams.y != 1024 ) return;				
				int transadd;
				for( transadd = 0; transadd < 8; transadd++ )
				{
					//based on https://github.com/MarekKowalski/LiveScan3D-Hololens/blob/master/HololensReceiver/Assets/GS%20Billboard.shader

					// Set based on data
					uint ballid = id * 8 + transadd;
					float4 DataPos = GetPosition(ballid);
					float4 DataVel = GetVelocity(ballid);
					
					g2f outval;
					outval.idplus1 = ballid+1;
					
					uint2 coordout = Hash3ForAdjacency( DataPos.xyz );
						
					coordout.y = 1023-coordout.y;
					outval.vertex = float4( (coordout+uint2(1,0))/_ScreenParams.xy*2.-1.,0.1,1 );
					oStream.Append( outval );
					//oStream.RestartStrip();
				}
			}


			float frag (g2f i ) : SV_Target
			{
				//Clever @d4rkpl4y3r trick: Handle collisions correctly!
				uint idplus1norm = i.idplus1;
				int2 screenCoord = i.vertex.xy;

				//DEBUGGING -> Verify blocks are where they ought to be.
				#if 0
					//This has been verified C.L. 20210620195100
					float4 DataPos = GetPosition(idplus1norm-1);
					uint2 coordout = Hash3ForAdjacency( DataPos.xyz );
				#else
					uint2 coordout = screenCoord;
					coordout.y = coordout.y;
				#endif
				
				float fault = 0;
				
				if( (int)(_Adjacency0[coordout].x) == idplus1norm ) discard;
				if( (int)(_Adjacency1[coordout].x) == idplus1norm ) discard;
				if( (int)(_Adjacency2[coordout].x) == idplus1norm ) discard;
				
				return idplus1norm;
			}
			ENDCG
		}
	}
}