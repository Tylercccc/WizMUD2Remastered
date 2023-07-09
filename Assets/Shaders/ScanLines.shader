Shader "Unlit/Scanlines" {

     Properties {
         _MainTex("_Color", 2D) = "white" {}
         _MaskTex("_Mask", 2D) = "white" {}
         _LineWidth("Line Width", Float) = 4
         _Hardness("Hardness", Float) = 0.9
         _Speed("Displacement Speed", Range(0,1)) = 0.1
         _CutoutColor("Cutout Color", Color) = (1,1,1,1)
         _Threshold("Threshold", Float) = .1
     }
 
     SubShader {

         Tags {"IgnoreProjector" = "True" "Queue" = "Transparent"}
         Blend SrcAlpha OneMinusSrcAlpha 

         Pass {
         	ZTest Always 
         	Cull Off 
         	ZWrite Off 

         	Fog{ Mode off }
 
         CGPROGRAM
 
 		 #pragma vertex vert
 		 #pragma fragment frag
 		 #pragma fragmentoption ARB_precision_hint_fastest
 		 #include "UnityCG.cginc"
 		 #pragma target 3.0
 
	     struct v2f {
	         float4 pos      : POSITION;
	         float2 uv       : TEXCOORD0;
	         float4 scr_pos : TEXCOORD1;
	     };
	 
	     uniform sampler2D _MainTex;
	     uniform sampler2D _MaskTex;
	     uniform float _LineWidth;
	     uniform float _Hardness;
	     uniform float _Speed;
	     uniform half4 _CutoutColor;
	     uniform float _Threshold;
	 
	     v2f vert(appdata_img v) {
	         v2f o;
	         o.pos = UnityObjectToClipPos(v.vertex);
	         o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.texcoord);
	         o.scr_pos = (o.pos);
	         
	         return o;
	     }
	 
	     half4 frag(v2f i) : COLOR {
	         half4 color = tex2D(_MainTex, i.uv);
	         half4 maskColor = tex2D(_MaskTex, i.uv);
	         color.a = maskColor.a;
	         //color = color * (1-maskColor.a) + half4(1,0,0,maskColor.a) * (maskColor.a);
             if(color.r > _CutoutColor.r - _Threshold
             && color.r < _CutoutColor.r + _Threshold
             && color.g < _CutoutColor.g + _Threshold
             && color.g > _CutoutColor.g - _Threshold
             && color.b < _CutoutColor.b + _Threshold
             && color.b > _CutoutColor.b - _Threshold) {
             	color.a = 0;
             }



	         fixed lineSize = _ScreenParams.y*0.005;
	         float displacement = ((_Time.y*1000)*_Speed)%_ScreenParams.y;
	         float ps = displacement+(i.uv.y * _ScreenParams.y );

	         return color * ((cos(ps / _LineWidth)+1) * .5*(1.0 - _Hardness) + _Hardness);
	     }
	 
	     ENDCG
	     }
     }
     FallBack "Diffuse"
 }