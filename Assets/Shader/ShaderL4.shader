Shader "ShaderL4/ShaderLearn"
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
        _UVTex("UV Texture", 2D) = "white" {}

        _Distortion("Distortion Intensity" , Float) = 0
        _DistortionAnimation("Distortion Animation", Vector) = (0,0,0,0)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

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

     /*       float _Cutoff;
            float _Feather;

            float4 _Ember;
            float4 _Char;
            float4 _EmberBoost;*/

            sampler2D _UVTex;
            float4 _UVTex_ST;

            float _Distortion;
            float4 _DistortionAnimation;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex);

                //rgba => xyzw can be used interchangeably
                //o.uv1 = (o.uv1 - 0.5) * 1 + 0.5;
                o.uv1_uv2.zw = TRANSFORM_TEX(v.uv, _UVTex);
                //o.uv1_uv2.zw += _Time.xx * 10;

                return o;
            }

            //run on every pixel
            //float4 is highest level of precision, like a regular float 32 bits
            //fixed has the lowest level of precision for data storage, Range (-2,2) accuracy 1/256 good enough for colour
            //half is 16 bits, Range -60000, 60000 Accuracy up to 3 decimal spaces
            fixed4 frag(v2f i) : SV_Target
            {
                //Sample UV Texture
                fixed4 uvTex = tex2D(_UVTex, i.uv1_uv2.zw);
                
                //Sample Main Texture (Grass)
                fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.xy + _Time.xx * _DistortionAnimation.xy + uvTex * _Distortion);

                //Applying UV animation
                //mainTexUV += float2(0, _Time.x * 10);

                //float _AnimatedCutoff = 0.5 * sin(_Time.x * 40) + 0.5;
                //alpha
                fixed3 color = mainTex.rgb;
                fixed alpha = 1; 

                return fixed4(color, alpha);
            }
            ENDCG
        }
    }
}
