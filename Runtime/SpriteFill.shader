// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "DimaTi/Sprites/Filled"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_ColorSecond ("Second Color", Color) = (1,1,1,1)
		_ColorFon ("Fon Color", Color) = (0.2,0.2,0.2,0.2)
		[HideInInspector]_Color ("Tint", Color) = (1,1,1,1)
		//_FillMask ("Fill mask", 2D) = "white" {}
		_FillTarget ("FillTarget value", Range(0,1)) = 1
		_Fill ("Fill value", Range(0,1)) = 1
		_XCorrectStart ("Atlas correct X start", Range(-1,1)) = 1
		_XCorrectEnd ("Atlas correct X end", Range(0,1)) = 1
		
		
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
			"DisableBatching" = "True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 uv  : TEXCOORD0;
			};
			
			fixed4 _Color;
			

			sampler2D _MainTex;
			//float4 _MainTex_ST;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				// billboard mesh towards camera
			/*	float3 vpos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
				float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);
				float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);
				float4 outPos = mul(UNITY_MATRIX_P, viewPos);*/

				float3 scale = float3(
					length(unity_ObjectToWorld._m00_m10_m20),
					length(unity_ObjectToWorld._m01_m11_m21),
					length(unity_ObjectToWorld._m02_m12_m22)
				);
			
				o.vertex = mul(UNITY_MATRIX_P,
				mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0))
				+ float4(v.vertex.x, v.vertex.y, 0.0, 0.0)
				* float4(scale, 1.0));
			


				//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv = v.texcoord;
				o.color = v.color * _Color;
				#ifdef PIXELSNAP_ON
				o.vertex = UnityPixelSnap (o.vertex);
				#endif
				return o;
			}

			
		//	sampler2D _FillMask;
			sampler2D _AlphaTex;
			float _AlphaSplitEnabled;
			float _Fill;
			float _FillTarget;
			float _XCorrectStart;
			float _XCorrectEnd;
			fixed3 _ColorSecond;
			fixed4 _ColorFon;

			fixed4 SampleSpriteTexture (float2 uv, sampler2D target)
			{
				fixed4 color = tex2D (target, uv);

#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
				if (_AlphaSplitEnabled)
					color.a = tex2D (_AlphaTex, uv).r;
#endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED

				return color;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = SampleSpriteTexture (i.uv, _MainTex);
			//	fixed4 mask = SampleSpriteTexture (i.uv, _FillMask);
				fixed4 c = col * i.color;
				//clip(mask.r - _Fill);

			//	if (mask.b > _Fill)
           //         c.rgb = 0;

				fixed value = step(i.uv.x + _XCorrectStart, _FillTarget * _XCorrectEnd)-0.1; //* _MainTex_ST.x
				fixed value2 = step(i.uv.x + _XCorrectStart, _Fill  * _XCorrectEnd)-0.1; //* _MainTex_ST.x

				//clip(step(i.uv.x, _Fill * _MainTex_ST.x)-0.1);
				//clip(step(_Fill, i.uv.x)-0.1);
				//c.rgb *= mask.r * _Fill;
				c.rgb *= value;
				c.rgb += ((_ColorSecond + col.rgb * 0.8) * (1 - value));
				//clip(value2);
				c.a *= value2;
				c.rgb *= c.a;
				c.rgb += _ColorFon.rgb * (1-value2) * col.a;
				c.a += _ColorFon.a * col.a;
				
				return c;
			}
		ENDCG
		}
	}
}
