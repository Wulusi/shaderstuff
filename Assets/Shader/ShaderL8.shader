Shader "ShaderL8/ShaderLearn"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Color("Tint Color", COLOR) = (1,1,1,1)
		[Enum(UnityEngine.Rendering.BlendMode)]
		_SrcFactor("Src Factor" , Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]
		_DstFactor("Dst Factor" , Float) = 10
		[Enum(UnityEngine.Rendering.BlendOp)]
		_Opp("Opp Factor" , Float) = 0

		_MidPoint("MidPoint", Range(0,1)) = 0.5
		_Thickness("Thickness", Range(0,0.2)) = 0.1
			_ShineTint("ShineTint", Color) = (1,1,1,1)
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Blend[_SrcFactor][_DstFactor]
			BlendOp[_Opp]

			Pass
			{
				CGPROGRAM
				//Run on vertices
				#pragma vertex vert

				//pixel shader
				#pragma fragment frag
				#include "UnityCG.cginc"

				//Object mesh data coming from mesh itself
				//Colour tangents and other types of data can be passed in
				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv: TEXCOORD0;
				};

		//vert
		struct v2f
		{
			float4 vertex : SV_POSITION;
			float4 uv1_uv2: TEXCOORD0;
			float4 screenSpaceCoords : TEXCOORD1;
		};


		sampler2D _MainTex;
		float4 _MainTex_ST;

		sampler2D _SecondaryTex;
		float4 _SecondaryTex_ST;

		float _MidPoint;
		float _Thickness;
		float4 _ShineTint;

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv1_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex);

			//rgba => xyzw can be used interchangeably
			//o.uv1 = (o.uv1 - 0.5) * 1 + 0.5;
			o.uv1_uv2.zw = TRANSFORM_TEX(v.uv, _SecondaryTex);
			//o.uv1_uv2.zw += _Time.xx * 10;

			//From clip space to screen space
			o.screenSpaceCoords = ComputeScreenPos(o.vertex);

			return o;
		}

		//run on every pixel
		//float4 is highest level of precision, like a regular float 32 bits
		//fixed has the lowest level of precision for data storage, Range (-2,2) accuracy 1/256 good enough for colour
		//half is 16 bits, Range -60000, 60000 Accuracy up to 3 decimal spaces
		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.xy);
			
		    float animatedMidpoint = frac(_Time.x * 10);
			float shine = step(mainTex.a, _MidPoint + _Thickness) - step(mainTex.a, animatedMidpoint - _Thickness);
			fixed3 color = mainTex.rgb  * (1 - shine) + _ShineTint.rgb * shine;
			fixed alpha = mainTex.a;
			return fixed4(color, 1);
		}
		ENDCG
	}
		}
}
