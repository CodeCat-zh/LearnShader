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
        _FlowTilling("_Flow Tilling",Vector)=(1,1,0,0)
        _FlowSpeed("Flow Spedd",Vector) = (1,1,0,0)
        _FlowTex("Flow Tex",2D)="white"{}
        _FlowInstensity("_FlowInstensity",float)=0.5
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
                float3 pivot_world:TEXCOORD3;

            };
            sampler2D _MainTex;
            float _RimMin;
            float _RimMax;
            float _TexPower;
            float4  _RimColor;
            float4 _InnerColor;
            float _RimIntensity;
            float _InnerAlpha;
            float  _FlowInstensity;
            float4  _FlowTilling;
            float4  _FlowSpeed;
            sampler2D  _FlowTex;

            v2f vert (appdata v)
            {
                v2f  o;
                float3 normal_world = mul(float4(v.normal, 0.0), unity_WorldToObject).xyz;

                o.normal_world = normalize(normal_world);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pivot_world = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)).xyz;
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

               half3 pos_world= normalize(i.pos_world);
               half2 uv_flow = (i.pos_world.xy - i.pivot_world.xy) * _FlowTilling.xy;
               uv_flow = uv_flow + _Time.y * _FlowSpeed.xy;
               float4 flow_rgba = tex2D(_FlowTex, uv_flow) * _FlowInstensity;

               float3 final_col = rim_color + flow_rgba.xyz;
               float final_aphla = saturate(rim_aplha + flow_rgba.w + _InnerAlpha);
               return float4(final_col,final_aphla);
            }

            ENDCG
        }
    }
}
