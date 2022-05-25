Shader "Shader3D/Lesson53D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "white" {}
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
                //comes from appdata
                float3 tangent : TANGENT;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir: TEXCOORD2;
                float3 tangent: TEXCOORD3;
                float3 bitangent: TEXCOORD4;
            };

            sampler2D _MainTex, _NormalMap;
            float4 _MainTex_ST;
            float _Gloss, _SpecIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.tangent, o.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv)); //*2 - 1;
                float3 finalNormal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal;

                //return fixed4(finalNormal * 0.5 + 0.5,1);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float ndotl = max(0, dot(finalNormal, _WorldSpaceLightPos0.xyz));
                float3 lighting = ndotl * _LightColor0 + ShadeSH9(float4(finalNormal, 1));

                float3 reflectedLight = reflect(_WorldSpaceLightPos0.xyz, finalNormal);
                float spec = max(0, dot(reflectedLight, -i.viewDir));
                float3 finalSpec = pow(spec, _Gloss) * _SpecIntensity * _LightColor0;
                
                float3 reflection = reflect(-i.viewDir, finalNormal);
                float3 reflectionSample = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflection);

                float3 finalColor = col * lighting * reflectionSample + finalSpec;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}
