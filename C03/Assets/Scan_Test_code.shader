// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Scan_Test_code"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RimMin("RimMin",Range(-1,1) )=0.0
        _RimMax("RimMax",Range(0,2) )= 1.0
        _TexPower("_TexPower",float)=5
        _RimColor("_RimColor",Color) = (0.5,0.5,0.5,0.5)
        _InnerColor("_InnerColor",Color) = (0.5,0.5,0.5,0.5)
        _RimIntensity("_RimIntensity",float) = 5.0
        _InnerAlpha("_InnerAlpha",float)=0.7
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend SrcAlpha One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        

            #include "UnityCG.cginc"

            struct appdata
            {
               float4 vertex :POSITION;
               float2 texcoord:TEXCOORD0;
               float3 normal :NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXTCOORD0;
                float3 normal_world :TEXCOORD1;
                float3 pos_world :TEXCOORD2;

            };
            sampler2D _MainTex;
            float _RimMin;
            float _RimMax;
            float _TexPower;
            float4  _RimColor;
            float4 _InnerColor;
            float _RimIntensity;
            float _InnerAlpha;
            v2f vert (appdata v)
            {
                v2f  o;
                float3 normal_world = mul(float4(v.normal, 0.0), unity_WorldToObject).xyz;

                o.normal_world = normalize(normal_world);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
               half3 normal_world = normalize(i.normal_world);
               half3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
               half NodtV = saturate(dot(normal_world, view_world));
               half fresnel = 1 - NodtV;
               fresnel = smoothstep(_RimMin, _RimMax, fresnel);
               half emiss = tex2D(_MainTex, i.uv).r;
               half rim_aplha = saturate(pow(emiss, _TexPower) + fresnel);
               half3 rim_color = lerp(_InnerColor.xyz, _RimColor.xyz * _RimIntensity,rim_aplha);

               half2 pos_world= normalize(i.pos_world);
        

               return float4(rim_color,rim_aplha);
            }
            ENDCG
        }
    }
}
