Shader "Shader3D/Lesson33D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss("Gloss", float) = 1
        _SpecIntensity("Spec Intensity", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss, _SpecIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float ndotl = max(0, dot(i.normal, _WorldSpaceLightPos0.xyz));
                float3 lighting = ndotl * _LightColor0 + ShadeSH9(float4(i.normal, 1));

                float3 reflectedLight = reflect(_WorldSpaceLightPos0.xyz, i.normal);
                float spec = max(0, dot(reflectedLight, -i.viewDir));
                float3 finalSpec = pow(spec, _Gloss) * _SpecIntensity * _LightColor0;

                float3 finalColor = col * lighting + finalSpec;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}
