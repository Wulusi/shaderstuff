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
        _Speed("Speed", Range(0.0, 10)) = 0 
        _Scale("Scale", Range(0.0, 10)) = 0
        _Amplitude("Amplitude", Range(0.0, 10)) = 0
        _Interval("Interval", Range(0.0, 10)) = 0
        _Offset("Offset", Range(0.0, 10)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        //Level of detail
        LOD 100

        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]
        //BlendOp Sub
        //Blend SrcAlpha OneMinusSrcAlpha

        //Blend formula
        //FinalValue = SrcFactor * SrcValue +(OPP) DstFactor * DstValue


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
                float2 uv: TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Speed;
            float _Scale;
            float _Interval;
            float _Amplitude;
            float _Offset;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = v.uv * float2(6,6) + float2(0.4,0);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //Sliding UVs
                //o.uv += float2(_Time.x * _Speed, _Time.x * _Speed) * _MainTex_ST.xy;
                float scale = sin(_Interval * _Time.x * _Speed)/ _Amplitude + _Offset;
                o.uv = (o.uv - 0.5) * 1/scale + 0.5;
                return o;
            }

            //run on every pixel
            //float4 is highest level of precision, like a regular float 32 bits
            //fixed has the lowest level of precision for data storage, Range (-2,2) accuracy 1/256 good enough for colour
            //half is 16 bits, Range -60000, 60000 Accuracy up to 3 decimal spaces
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(i.uv, 0, 1);
                fixed4 tex = tex2D(_MainTex, i.uv);
                return tex * fixed4(1,1,1,1);
            }
            ENDCG
        }
    }
}
