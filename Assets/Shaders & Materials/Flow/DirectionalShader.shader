Shader "Custom/DistortionShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        [NoScaleOffset] _MainTex ("Derive (AG) Height (B)", 2D) = "black" {}
		[NoScaleOffset] _FlowMap ("Flow (RG)", 2D) = "black" {}
		[Toggle (_DUAL_GRID)] _DualGrid ("Dual Grid", Int) = 0
		_Tiling ("Tiling, Constant", Float) = 1
		_TilingModulated ("Tiling, Modulated", Float) = 1
		_GridResolution ("Grid Resolution", Float) = 10
		_Speed ("Speed", Float) = 1
		_FlowStrength ("Flow Strength", Float) = 1
		_HeightScale ("Height Scale, Constant", Float) = 0.25
		_HeightScaleModulated ("Height Scale, Modulated", Float) = 0.75
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0f
		#pragma shader_feature _DUAL_GRID

		#include "Flow2.cginc"

        sampler2D _MainTex, _FlowMap;
		float _Tiling, _TilingModulated, _GridResolution, _Speed, _FlowStrength;
		float _HeightScale, _HeightScaleModulated;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

		float3 UnpackDerivativeHeight(float4 textureData)
		{
			float3 dh = textureData.agb;
			dh.xy = dh.xy * 2 - 1;
			return dh;
		}

		float3 FlowCell(float2 uv, float1 offset, float time, float gridB)
		{
			float2 shift = 1 - offset;
			shift *= 0.5;
			offset *= 0.5;

			if (gridB)
			{
				offset += 0.25;
				shift -= 0.25;
			}

			float2x2 deriveRotation;

			float2 uvTiled = (floor(uv * _GridResolution + offset) + shift) / _GridResolution;
			float3 flow = tex2D(_FlowMap, uvTiled).rgb;

			flow.xy = flow.xy * 2 - 1;
			flow.z *= _FlowStrength;
			float tiling = flow.z * _TilingModulated + _Tiling;

			float2 uvFlow = DirectionalFlowUV(uv + offset, flow, tiling, time, deriveRotation);
			float3 dh = UnpackDerivativeHeight(tex2D(_MainTex, uvFlow));

			dh.xy = mul(deriveRotation, dh.xy);
			dh *= flow.z * _HeightScaleModulated + _HeightScale;

			return dh;
		}

		float3 FlowGrid(float2 uv, float time, bool gridB)
		{
			float3 dhA = FlowCell(uv, float2 (0, 0), time, gridB);
			float3 dhB = FlowCell(uv, float2 (1, 0), time, gridB);
			float3 dhC = FlowCell(uv, float2 (0, 1), time, gridB);
			float3 dhD = FlowCell(uv, float2 (1, 1), time, gridB);

			float2 t = uv * _GridResolution;

			if (gridB)
			{
				t += 0.25;
			}

			t = abs(2 * frac(t) - 1);

			float wA = (1 - t.x) * (1 - t.y);
			float wB = t.x * (1 - t.y);
			float wC = (1 - t.x) * t.y;
			float wD = t.x * t.y;

			return (dhA * wA) + (dhB * wA) + (dhC * wC) + (dhD * wD);
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			float time = _Time.y * _Speed;
			float2 uv = IN.uv_MainTex;
			float3 dh = FlowGrid(uv, time, false);
			#if defined(_DUAL_GRID)
				dh = (dh + FlowGrid(uv, time, true)) * 0.5;
			#endif

            fixed4 c = dh.z * dh.z * _Color;
			o.Albedo = c.rgb;
			o.Normal = normalize(float3(-dh.xy, 1));
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}