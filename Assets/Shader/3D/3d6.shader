Shader "Shader3D/Lesson63D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Toggle]
        NORMAL_MAP("Normal Mapping", float) = 0
        _NormalMap("Normal Map", 2D) = "white" {}


        [Toggle]
        SPEC("Specular", float) = 0
        _Gloss("Gloss", float) = 1
        _SpecIntensity("Spec Intensity", float) = 1

        [Toggle]
        REFLECTION("Reflection", float) = 0
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

            //Use when building shaders, will only take what is needed, can not be toggled at run time
            //#pragma shader_feature __ NORMAL_MAP_ON
            //#pragma shader_feature __ SPEC_ON
            //#pragma shader_feature __ REFLECTION_ON

            //Use when we want to turn off features from script, will sample all variations 2^X 
            #pragma multi_compile __ NORMAL_MAP_ON
            #pragma multi_compile __ SPEC_ON
            #pragma multi_compile __ REFLECTION_ON

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
                UNITY_INITIALIZE_OUTPUT(v2f, o)
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //Normal Maps
                o.normal = UnityObjectToWorldNormal(v.normal);

                #if NORMAL_MAP_ON
                    o.tangent = UnityObjectToWorldDir(v.tangent);
                    o.bitangent = cross(o.tangent, o.normal);
                #endif
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //Normal maps

                float3 finalNormal = i.normal;

                #if NORMAL_MAP_ON
                    fixed3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv)); //*2 - 1;
                    finalNormal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal;
                #endif

                //return fixed4(finalNormal * 0.5 + 0.5,1);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float ndotl = max(0, dot(finalNormal, _WorldSpaceLightPos0.xyz));
                float3 lighting = ndotl * _LightColor0 + ShadeSH9(float4(finalNormal, 1));


                //Spec
                float3 finalSpec = 0;

                #if SPEC_ON
                    float3 reflectedLight = reflect(_WorldSpaceLightPos0.xyz, finalNormal);
                    float spec = max(0, dot(reflectedLight, -i.viewDir));
                    finalSpec = pow(spec, _Gloss) * _SpecIntensity * _LightColor0;
                #endif

                    float3 reflectionSample = 1;

                #if REFLECTION_ON
                
                    float reflection = reflect(-i.viewDir, finalNormal);
                    reflectionSample = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflection);
                #endif

                float3 finalColor = col * lighting * reflectionSample + finalSpec;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}
