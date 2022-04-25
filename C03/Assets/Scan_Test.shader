// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scan_Test"
{
	Properties
	{
		_MainTexture("MainTexture", 2D) = "white" {}
		_RinMin("RinMin", Range( -1 , 1)) = 0
		_RinMax("RinMax", Range( 0 , 2)) = 0
		_RimColor("RimColor", Color) = (0,0,0,0)
		_InnerColor("InnerColor", Color) = (0,0,0,0)
		_RimIntensity("RimIntensity", Float) = 0
		_FlowEmiss("FlowEmiss", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_FlowInstensity("FlowInstensity", Float) = 0
		_TexPower("TexPower", Float) = 0
		_InnerAlpha("InnerAlpha", Float) = 0
		_FlowTilling("FlowTilling", Vector) = (2,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _InnerColor;
		uniform float4 _RimColor;
		uniform float _RimIntensity;
		uniform float _RinMin;
		uniform float _RinMax;
		uniform sampler2D _MainTexture;
		SamplerState sampler_MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float _TexPower;
		uniform sampler2D _FlowEmiss;
		uniform float2 _FlowTilling;
		uniform float2 _Speed;
		uniform float _FlowInstensity;
		SamplerState sampler_FlowEmiss;
		uniform float _InnerAlpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float dotResult15 = dot( ase_worldNormal , i.viewDir );
			float clampResult16 = clamp( dotResult15 , 0.0 , 1.0 );
			float smoothstepResult19 = smoothstep( _RinMin , _RinMax , ( 1.0 - clampResult16 ));
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float clampResult53 = clamp( ( smoothstepResult19 + pow( tex2D( _MainTexture, uv_MainTexture ).r , _TexPower ) ) , 0.0 , 1.0 );
			float4 lerpResult23 = lerp( _InnerColor , ( _RimColor * _RimIntensity ) , clampResult53);
			float4 RimColor61 = lerpResult23;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult37 = (float2(ase_worldPos.x , ase_worldPos.y));
			float3 objToWorld41 = mul( unity_ObjectToWorld, float4( float4(0,0,0,0).xyz, 1 ) ).xyz;
			float2 appendResult42 = (float2(objToWorld41.x , objToWorld41.y));
			float4 tex2DNode26 = tex2D( _FlowEmiss, ( ( ( appendResult37 - appendResult42 ) * _FlowTilling ) + ( _Speed * _Time.y ) ) );
			float4 FlowColor57 = ( tex2DNode26 * _FlowInstensity );
			o.Emission = ( RimColor61 + FlowColor57 ).rgb;
			float RimAlpha64 = clampResult53;
			float FlowAlpha59 = ( _FlowInstensity * tex2DNode26.a );
			float clampResult46 = clamp( ( RimAlpha64 + FlowAlpha59 + _InnerAlpha ) , 0.0 , 1.0 );
			o.Alpha = clampResult46;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1920;0;1440;879;819.2813;552.3783;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;62;-1017.184,506.83;Inherit;False;2666.944;680.1244;流光效果;18;31;32;37;38;56;59;57;35;42;41;40;55;33;34;26;49;47;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;66;-738.37,-1013.205;Inherit;False;2334.342;1323.343;自发光;23;25;12;15;2;50;51;13;17;16;18;20;19;64;22;24;21;52;53;23;61;65;60;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;40;-967.184,792.8909;Inherit;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;12;-688.37,-441.0132;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-646.2805,-256.128;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-849.502,598.236;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;41;-725.4102,787.3148;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;37;-453.3557,624.3513;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;15;-278.3549,-440.0546;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-389.9816,799.6224;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;55;-116.8299,770.4461;Inherit;False;Property;_FlowTilling;FlowTilling;12;0;Create;True;0;0;False;0;False;2,0;2,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ClampOpNode;16;-53.97176,-446.8067;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;32;-182.7556,1075.954;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-108.4073,640.3088;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;31;-144.0606,926.4974;Inherit;False;Property;_Speed;Speed;8;0;Create;True;0;0;False;0;False;0,0;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;20;-50.47939,-165.3512;Inherit;False;Property;_RinMax;RinMax;3;0;Create;True;0;0;False;0;False;0;1.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-429.6287,-89.92769;Inherit;True;Property;_MainTexture;MainTexture;1;0;Create;True;0;0;False;0;False;-1;None;be8f19aec22965b418fd04de4f9f5f25;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;17;167.9703,-444.1173;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;147.1384,768.2093;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-407.1202,159.9951;Inherit;False;Property;_TexPower;TexPower;10;0;Create;True;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-29.93297,-278.2824;Inherit;False;Property;_RinMin;RinMin;2;0;Create;True;0;0;False;0;False;0;0.2;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;160.4644,638.0944;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;19;445.9435,-437.3069;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;50;439.1031,-34.07351;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;386.4713,634.0637;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;26;567.6091,602.9284;Inherit;True;Property;_FlowEmiss;FlowEmiss;7;0;Create;True;0;0;False;0;False;-1;None;adc10745c1b069148b3531cbd4dcab6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;-308.044,-861.444;Inherit;False;Property;_RimColor;RimColor;4;0;Create;True;0;0;False;0;False;0,0,0,0;0.1137255,0.2,0.7803922,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;52;653.8478,-436.2724;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-263.9551,-617.2414;Inherit;False;Property;_RimIntensity;RimIntensity;6;0;Create;True;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;933.8951,663.2512;Inherit;False;Property;_FlowInstensity;FlowInstensity;9;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;1134.968,729.1126;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;53;883.7134,-451.0723;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;137.8572,-767.3576;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;21;120.519,-963.2049;Inherit;False;Property;_InnerColor;InnerColor;5;0;Create;True;0;0;False;0;False;0,0,0,0;0,0.07058824,0.2352941,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;23;1074.877,-770.2766;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;1127.584,572.6015;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;1292.245,767.1859;Inherit;False;FlowAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;1123.793,-418.2094;Inherit;False;RimAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;1287.643,-781.3331;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;1425.76,556.83;Inherit;False;FlowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;1398.789,-204.5866;Inherit;False;64;RimAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;1443.691,220.9542;Inherit;False;Property;_InnerAlpha;InnerAlpha;11;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;1395.972,-67.12755;Inherit;False;59;FlowAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;1803.033,-320.9688;Inherit;False;61;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;1900.827,28.49533;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;1802.823,-226.6002;Inherit;False;57;FlowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;46;2049.182,-11.62896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;2096.876,-300.2037;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2237.296,-340.3021;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Scan_Test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;3;False;-1;4;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;41;0;40;0
WireConnection;37;0;35;1
WireConnection;37;1;35;2
WireConnection;15;0;12;0
WireConnection;15;1;13;0
WireConnection;42;0;41;1
WireConnection;42;1;41;2
WireConnection;16;0;15;0
WireConnection;38;0;37;0
WireConnection;38;1;42;0
WireConnection;17;0;16;0
WireConnection;33;0;31;0
WireConnection;33;1;32;0
WireConnection;56;0;38;0
WireConnection;56;1;55;0
WireConnection;19;0;17;0
WireConnection;19;1;18;0
WireConnection;19;2;20;0
WireConnection;50;0;2;1
WireConnection;50;1;51;0
WireConnection;34;0;56;0
WireConnection;34;1;33;0
WireConnection;26;1;34;0
WireConnection;52;0;19;0
WireConnection;52;1;50;0
WireConnection;49;0;47;0
WireConnection;49;1;26;4
WireConnection;53;0;52;0
WireConnection;25;0;22;0
WireConnection;25;1;24;0
WireConnection;23;0;21;0
WireConnection;23;1;25;0
WireConnection;23;2;53;0
WireConnection;48;0;26;0
WireConnection;48;1;47;0
WireConnection;59;0;49;0
WireConnection;64;0;53;0
WireConnection;61;0;23;0
WireConnection;57;0;48;0
WireConnection;45;0;65;0
WireConnection;45;1;60;0
WireConnection;45;2;54;0
WireConnection;46;0;45;0
WireConnection;43;0;63;0
WireConnection;43;1;58;0
WireConnection;0;2;43;0
WireConnection;0;9;46;0
ASEEND*/
//CHKSM=BC07DAD47350D1343CA857660392F981E09C8D72