﻿Shader "QuadProjection/Unlit Texture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
		[Enum(Both,0,Front,2,Back,1)] _Cull("Sidedness", Float) = 0.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "DisableBatching" = "true" }

		Pass
		{
			Cull [_Cull]
		
			CGPROGRAM
			#pragma geometry geom
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma target 4.0
			
			#include "UnityCG.cginc"

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			 
			struct v2g{
				float4 objPos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			 
			struct g2f{
				float4 worldPos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			
			float4 _MainTex_ST;
			
			float _Cutoff;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.objPos = v.vertex;
				o.uv = v.uv;
				
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			[maxvertexcount(6)]
			void geom (triangle v2g input[3], inout TriangleStream<g2f> tristream){
			
				float3 pos1 = input[0].objPos;
				float3 pos2 = input[1].objPos;
				
				float3 pos3 = float3(
					pos2.x,
					pos1.y,
					pos1.z
				);
			
				//First triangle
				g2f o;
				o.worldPos = UnityObjectToClipPos(pos1);
				o.uv = float2(1,0);
				o.uv = TRANSFORM_TEX(o.uv, _MainTex);
				tristream.Append(o);
				
				o.worldPos = UnityObjectToClipPos(pos3);
				o.uv = float2(0,0);
				o.uv = TRANSFORM_TEX(o.uv, _MainTex);
				tristream.Append(o);
			 
				o.worldPos = UnityObjectToClipPos(pos2);
				o.uv = float2(0,1);
				o.uv = TRANSFORM_TEX(o.uv, _MainTex);
				tristream.Append(o);
			 
				tristream.RestartStrip();
				
				//Second triangle				
				pos3 = float3(
					pos1.x,
					pos2.y,
					pos2.z
				);
			
				o.worldPos = UnityObjectToClipPos(pos1);
				o.uv = float2(1,0);
				o.uv = TRANSFORM_TEX(o.uv, _MainTex);
				tristream.Append(o);
			 
				o.worldPos = UnityObjectToClipPos(pos2);
				o.uv = float2(0,1);
				o.uv = TRANSFORM_TEX(o.uv, _MainTex);
				tristream.Append(o);
			 
				o.worldPos = UnityObjectToClipPos(pos3);
				o.uv = float2(1,1);
				o.uv = TRANSFORM_TEX(o.uv, _MainTex);
				tristream.Append(o);
			 
				tristream.RestartStrip();
			}
			
			fixed4 frag (g2f i, fixed facing : VFACE) : SV_Target
			{
				// Un-mirror texture on backside
				i.uv.x = facing > 0 ? i.uv.x : 1.0 - i.uv.x;
			
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				
				clip(col.a - _Cutoff);
				
				return col;
			}
			ENDCG
		}
	}
}
