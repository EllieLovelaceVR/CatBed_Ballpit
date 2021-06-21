﻿//XXX TODO: Remember to credit d4kpl4y3r with the bucketing tech.
//XXX TODO: ACTUALLY_DO_COMPLEX_HASH_FUNCTION and try it.

Shader "cnballpit/shaderCalcPrimary"
{
	Properties
	{
		_BallRadius( "Default Ball Radius", float ) = 0.1
		_PositionsIn ("Positions", 2D) = "white" {}
		_VelocitiesIn ("Velocities", 2D) = "white" {}
		_AdjacencyMapIn ("Adjacencies", 2D) = "white" {}
		_AdjacencyMapInSecond ("AdjacenciesSecond", 2D) = "white" {}
        _DepthMapAbove ("Above Depth", 2D) = "white" {}
        _DepthMapBelow ("Below Depth", 2D) = "white" {}
		_DebugFloat("Debug", float) = 0
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

			#include "UnityCG.cginc"
			#include "/Assets/hashwithoutsine/hashwithoutsine.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			
			struct f2a
			{
				float4 Pos : COLOR0;
				float4 Vel : COLOR1;
			};

			#include "cnballpit.cginc"
			float _BallRadius, _DebugFloat;
			texture2D<float> _DepthMapAbove;
			float4 _DepthMapAbove_TexelSize;
			texture2D<float> _DepthMapBelow;
			float4 _DepthMapBelow_TexelSize;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			f2a frag ( v2f i )
			{
				f2a ret;
				int2 screenCoord = i.vertex.xy;
				uint ballid = screenCoord.y * 1024 + screenCoord.x;

				float dt = 0.006;//unity_DeltaTime.x;
				
				float4 Position = GetPosition( ballid );
				float4 Velocity = GetVelocity( ballid );
				if( _Time.y < 3 || Position.w == 0 || _DebugFloat > 0 )
				{
					ret.Pos = float4( hash33( ballid.xxx ) * 10., _BallRadius );
					ret.Vel = float4( 0., 0., 0., ballid );
					return ret;
				}
				
				Position.w = _BallRadius;
				int did_find_self = 0;
				//Collide with other balls
				{
					const float cfmVelocity = 10.0;
					const float cfmPosition = .01;
					
					// Step 1 find collisions.
					const int3 neighborhood = int3( 3, 3, 3 );
					int3 ballneighbor;
					int3 ballhashcell = int3(Position.xyz * HashCellRange);
					for( ballneighbor.x = -neighborhood.x; ballneighbor.x <= neighborhood.x; ballneighbor.x++ )
					for( ballneighbor.y = -neighborhood.y; ballneighbor.y <= neighborhood.y; ballneighbor.y++ )
					for( ballneighbor.z = -neighborhood.z; ballneighbor.z <= neighborhood.z; ballneighbor.z++ )
					{
						int3 ab = ballneighbor + ballhashcell;
						
						int j;
						for( j = 0; j < 2; j++ )
						{
							uint obid;
							if( j == 0 )
								obid = _AdjacencyMapIn[Hash3ForAdjacency(ab)] - 1;
							else
								obid = _AdjacencyMapInSecond[Hash3ForAdjacency(ab)] - 1;
							if( obid == 0 ) break;
							if( obid == ballid )
							{
								did_find_self = 1;
								continue;
								//Do something?
							}
							//XXX NOTE CHARLES DIV 65k?
							float4 otherball = GetPosition( obid );
							float len = length( Position.xyz - otherball.xyz );
							
							//Do we collide AND are we NOT the other ball?
							if( len < otherball.w + Position.w && len > 0.01 )
							{
								// Collision! (Todo, smarter)
								// We only edit us, not the other ball.
								float penetration = ( otherball.w + Position.w ) - len;
								float3 vectortome = normalize(Position.xyz - otherball.xyz);
								Velocity.xyz += penetration * vectortome * cfmVelocity;
								Position.xyz += penetration * vectortome * cfmPosition;
								Velocity.xyz *= 1;
							}
						}
					}

				}

				if( !did_find_self )
				{
					//Velocity.w = 1;
				}


				//Collide with edges.
				
				static const float edgecfm = 1.5;
				static const float edgecfmv = 3.5;
				
				// A bowl (not in use right now)
				if( 0 )
				{
					//Bowl Collision.
					float3 bowlcenter = float3( 0., 31., 0. );
					float bowlradius = 30;				
					float exitlength = length( Position.xyz - bowlcenter ) - bowlradius;
					if( exitlength > 0 )
					{
						float3 enterdir = Position.xyz - bowlcenter;
						Velocity.xyz -= (normalize( enterdir ) * exitlength) * edgecfmv;
						Position.xyz -= (normalize( enterdir ) * exitlength)*edgecfm;
					}
				}

				const float2 WorldSize = float2( 10, 10 );
				const float2 HighXZ = float2( 5, 5 );
				const float2 LowXZ = float2( -5, -5 );
				
				// World Edges
				if( 1 )
				{
					float protrudelen;
					protrudelen = Position.x - HighXZ.x + Position.w;
					if( protrudelen > 0 )
					{
						Velocity.xyz -= float3( 1, 0, 0 ) * protrudelen * edgecfmv;
						Position.xyz -= float3( 1, 0, 0 ) * protrudelen * edgecfm;
					}

					protrudelen = LowXZ.x-Position.x + Position.w;
					if( protrudelen > 0 )
					{
						Velocity.xyz -= float3( -1, 0, 0 ) * protrudelen * edgecfmv;
						Position.xyz -= float3( -1, 0, 0 ) * protrudelen * edgecfm;
					}

					protrudelen = -Position.y + Position.w;
					if( protrudelen > 0 )
					{
						Velocity.xyz -= float3( 0, -1, 0 ) * protrudelen * edgecfmv;
						Position.xyz -= float3( 0, -1, 0 ) * protrudelen * edgecfm;
					}
					protrudelen = Position.z - HighXZ.y + Position.w;
					if( protrudelen > 0 )
					{
						Velocity.xyz -= float3( 0, 0, 1 ) * protrudelen;
						Position.xyz -= float3( 0, 0, 1 ) * protrudelen * edgecfm;
					}

					protrudelen = LowXZ.y-Position.z + Position.w;
					if( protrudelen > 0 )
					{
						Velocity.xyz -= float3( 0, 0, -1 ) * protrudelen;
						Position.xyz -= float3( 0, 0, -1 ) * protrudelen * edgecfm;
					}
				}

				//Use depth cameras.
				if(1) 
				{
					float heightcfm = 1.8;
					float heightcfmv = 100.;
					float4 StorePos = Position;
					float4 StoreVel = Velocity;
					//Collision with depth map.
					int2 DepthMapCoord = ( (Position.xz) / WorldSize + 0.5 ) * _DepthMapAbove_TexelSize.zw;
					float2 DepthMapDeltaMeters = WorldSize * _DepthMapAbove_TexelSize.xy;
					int2 neighborhood = ceil( Position.w / DepthMapDeltaMeters );
					int2 ln;
					for( ln.x = -neighborhood.x; ln.x < neighborhood.x; ln.x++ )
					for( ln.y = -neighborhood.y; ln.y < neighborhood.y; ln.y++ )
					{
						int2 coord = ln + DepthMapCoord;

						if( coord.x < 0 || coord.y < 0 || coord.x >= _DepthMapAbove_TexelSize.z || coord.y >= _DepthMapAbove_TexelSize.w )
							continue;

							
						float topY = (_DepthMapAbove[coord])*20;
						int2 bottomcoord = int2( coord.x, coord.y );
						float bottomY = ((_DepthMapAbove[bottomcoord])*20);

						float2 xzWorldPos = ((coord * _DepthMapAbove_TexelSize.xy) - 0.5 ) * WorldSize;
						float3 CollisionPosition = float3( xzWorldPos.x, topY, xzWorldPos.y );
						
						//Tricky: If we are above the bottom part and below the top, we are "inside" so zero the Y.
						if( StorePos.y < topY && StorePos.y > bottomY )
						{
							CollisionPosition.y = StorePos.y;
						}


						float3 deltap = StorePos.xyz - CollisionPosition;

						float penetration = StorePos.w - length(deltap);
						if( penetration > 0 )
						{
							float neighborderate = neighborhood.x *neighborhood.y;
							deltap = normalize( deltap );
							Velocity.xyz += deltap * penetration * heightcfmv / neighborderate;
							Position.xyz += deltap * penetration * heightcfm / neighborderate;
						}
					}
				}
				
				//Fountain
				if( 1 )
				{
					if( Position.x < -4.5 && Position.z < -4.5 && Position.y < 3 )
					{
						Velocity.xyz += float3( -.01, .13, 0 );
					}
				}
				
				//Velocity.w = 0.5;

	//			texture2D<float> _DepthMapAbove;
	//			float4 _DepthMapAbove_TexelSize;
	//			texture2D<float> _DepthMapBelow;
	//			float4 _DepthMapBelow_TexelSize;



				// Step 2: Actually perform physics.
				Velocity.y -= 9.8*dt;
				
				Position.xyz = Position.xyz + Velocity.xyz * dt;
				
				Velocity.xyz = Velocity.xyz * .995;

				ret.Pos = Position;
				ret.Vel = Velocity;

				return ret;
			}
			ENDCG
		}
	}
}
