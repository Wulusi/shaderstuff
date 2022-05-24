Shader "ShaderL1/ShaderLearn"
{
    Properties
    {
     
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        //Level of detail
        LOD 100

        Pass
        {
            CGPROGRAM
            //Run on vertices
            #pragma vertex vert

            //pixel shader
            #pragma fragment frag
            // make fog work shader feature
            // #pragma multi_compile_fog

            #include "UnityCG.cginc"

            //Object mesh data coming from mesh itself
            //Colour tangents and other types of data can be passed in
            //Vertices UV
            struct appdata
            {
                float4 vertex : POSITION;

                //Only used for texture sampling
                //float2 uv : TEXCOORD0;
            };

            //vert
            struct v2f 
            {
                //Some devices have limited data that could be passed into v2f
                //float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            //run on every vertices
            v2f vert (appdata v)
            {
                v2f o;
                //Matrix multiplier
                o.vertex = UnityObjectToClipPos(v.vertex);
                /*o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);*/
                return o;
            }

            //run on every pixel
            //float4 is highest level of precision, like a regular float 32 bits
            //fixed has the lowest level of precision for data storage, Range (-2,2) accuracy 1/256 good enough for colour
            //half is 16 bits, Range -60000, 60000 Accuracy up to 3 decimal spaces
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col = fixed4(0.5, 0.3, 1, 1);
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
