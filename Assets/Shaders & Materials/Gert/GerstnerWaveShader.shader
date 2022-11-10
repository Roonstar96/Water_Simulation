Shader "Custom/GerstnerWaveShader"
{
	Properties
	{
		_Color("Colour", Color) = (1, 1, 1, 1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0, 1)) = 0.5
		_Metallic("Metallic", Range(0, 10)) = 0.0

		_WaveA("Wave A (Dir, Amp, Wave)", Vector) = (1, 1, 0.25, 60)
		_WaveB("Wave B (Dir, Amp, Wave)", Vector) = (1, 0.6, 0.25, 31)
		_WaveC("Wave C (Dir, Amp, Wave)", Vector) = (1, 1.3, 0.25, 18)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float4 _WaveA, _WaveB, _WaveC;

		float3 GerstnerWave(float4 wave, float3 p, inout float3 tangent, inout float3 binormal)
		{
			float amplitude = wave.z;
			float waveLength = wave.w;

			float k = 2 * UNITY_PI / waveLength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, p.xz) - (c * _Time.y));
			float a = amplitude / k;

			tangent += float3 (-d.x * d.x * (amplitude * sin(f)), d.x * (amplitude * cos(f)), -d.x * d.y * (amplitude * sin(f)));

			binormal += float3 (-d.x * d.y * (amplitude * sin(f)), d.y * (amplitude * cos(f)), -d.y * d.y * (amplitude * sin(f)));

			return float3 ( d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)) );
		}


		void vert(inout appdata_full vertexData)
		{
			float3 gridPoint = vertexData.vertex.xyz;
			float3 tangent = 0;
			float3 binormal = 0;
			float3 p = gridPoint;

			p += GerstnerWave(_WaveA, gridPoint, tangent, binormal);
			p += GerstnerWave(_WaveB, gridPoint, tangent, binormal);
			p += GerstnerWave(_WaveC, gridPoint, tangent, binormal);

			float normal = normalize(cross(binormal, tangent));

			vertexData.vertex.xyz = p;
			vertexData.normal = normal;
		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}

	FallBack "Diffuse"
}
