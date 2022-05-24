Shader "ShaderL9/ShaderLearn"
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

		_Rotation("Rotation" , Range(0, 6.3)) = 0


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
		};


		sampler2D _MainTex;
		float4 _MainTex_ST;

		sampler2D _SecondaryTex;
		float4 _SecondaryTex_ST;

		float _Rotation;

		float2 RotatedUVs(float2 uv)
		{
			float2 rotatedUV = uv;
			rotatedUV -= 0.5;
			float c = cos(_Rotation * _Time.xx);
			float s = sin(_Rotation * _Time.xx);

			float2x2 rotationMatrix = float2x2(c, -s, s, c);

			//Use mul as a operation to multiply the matrices
			rotatedUV = mul(rotationMatrix, rotatedUV);
			//rgba => xyzw can be used interchangeably
			rotatedUV += 0.5;
			return rotatedUV;
		}

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv1_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex);
			o.uv1_uv2.zw = RotatedUVs(v.uv);
			o.uv1_uv2.zw = TRANSFORM_TEX(o.uv1_uv2.zw, _MainTex);
			return o;
		}

		//run on every pixel
		//float4 is highest level of precision, like a regular float 32 bits
		//fixed has the lowest level of precision for data storage, Range (-2,2) accuracy 1/256 good enough for colour
		//half is 16 bits, Range -60000, 60000 Accuracy up to 3 decimal spaces
		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.zw);
			fixed3 color = mainTex.rgb;
			fixed alpha = mainTex.a;
			return fixed4(mainTex.rgb, 1);
		}
		ENDCG
	}
		}
}
