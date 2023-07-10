Shader "Roystan/Toon"
{
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MidTone("MidTone", Color) = (0,0,0,1)
		_Shadow("Shadow", Color) = (0,0,0,1)
		_MainTex("Main Texture", 2D) = "white" {}
		_RampRange("Ramp Range", Range(0,0.5)) = 0.2
		_DitherPattern ("Dithering Pattern", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
				"PassFlags" = "OnlyDirectional"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DitherPattern;
			float4 _DitherPattern_TexelSize;

			struct appdata
			{
				float4 vertex : POSITION;				
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float4 screenPosition : TEXCOORD1;
				float3 worldNormal : NORMAL;
			};


			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.screenPosition = ComputeScreenPos(o.pos);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			float4 _Color;
			float4 _MidTone;
			float4 _Shadow;
			float _RampRange;
	

			float4 frag (v2f i) : SV_Target
			{
				float3 normal = normalize(i.worldNormal);
				float NdotL = dot(_WorldSpaceLightPos0, normal);
				//Dithering
				float2 screenPos = i.screenPosition.xy / clamp(i.screenPosition.w,0,5);
				float2 ditherCoordinate = screenPos * _ScreenParams.xy * _DitherPattern_TexelSize.xy;
				float ditherValue = tex2D(_DitherPattern, ditherCoordinate).r;

				//change to function
				float4 lightIntensity = NdotL >= 0 + _RampRange * ditherValue ? _Color : NdotL > -0.5 *_RampRange && NdotL < 0 +_RampRange ? lerp(_MidTone, _Shadow, saturate(ditherValue*i.screenPosition.w) ) : _Shadow;

				//return _Color * sample * lightIntensity;
				//float4 shadowDither = lerp(_MidTone, _Shadow, ditherValue);
				return lightIntensity;
			}
			ENDCG
		}
	}
}