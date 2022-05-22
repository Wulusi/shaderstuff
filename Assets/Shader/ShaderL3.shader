Shader "ShaderL3/ShaderLearn"
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

        _Cutoff("Cutoff" , Range(0.0,1.0)) = 0
        _Feather("Feather" , Range(0.0,0.1)) = 0

        _Ember("Ember Color", Color) = (1,1,1,1)
        _EmberBoost("Ember Boost", Float) = 0
        _Char("Char Color", Color) = (1,1,1,1)

        _SecondaryTex("Secondary Texture", 2D) = "white" {}
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

            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;

            float _Cutoff;
            float _Feather;

            float4 _Ember;
            float4 _Char;
            float4 _EmberBoost;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1_uv2.xy = TRANSFORM_TEX(v.uv, _MainTex);

                //rgba => xyzw can be used interchangeably
                //o.uv1 = (o.uv1 - 0.5) * 1 + 0.5;
                o.uv1_uv2.zw = TRANSFORM_TEX(v.uv, _SecondaryTex);
                //o.uv1_uv2.zw += _Time.xx * 10;

                return o;
            }

            //run on every pixel
            //float4 is highest level of precision, like a regular float 32 bits
            //fixed has the lowest level of precision for data storage, Range (-2,2) accuracy 1/256 good enough for colour
            //half is 16 bits, Range -60000, 60000 Accuracy up to 3 decimal spaces
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainTex = tex2D(_MainTex, i.uv1_uv2.xy);
                fixed4 secondaryTex = tex2D(_SecondaryTex, i.uv1_uv2.zw);
                fixed3 emberArea = step(secondaryTex.r - _Feather, _Cutoff);
                fixed3 burntArea = smoothstep(secondaryTex.r - _Feather, secondaryTex.r + _Feather, _Cutoff);
                fixed3 emberColor = lerp(mainTex, _Ember * _EmberBoost, emberArea);
                fixed3 color = lerp(emberColor, _Char, burntArea);
                //colour
                //fixed3 color = mainTex;

                //float _AnimatedCutoff = 0.5 * sin(_Time.x * 40) + 0.5;
                //alpha
                fixed alpha = saturate(mainTex.a - step(secondaryTex.r + _Feather, _Cutoff));
                //smoothstep(secondaryTex.r - _Feather, secondaryTex.r + _Feather, _AnimatedCutoff);

                return fixed4(color, alpha);
            }
            ENDCG
        }
    }
}
