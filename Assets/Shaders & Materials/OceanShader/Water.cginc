#if !defined (WATER_INCLUDED)
#define WATER_INCLUDED

float4 _WaveA, _WaveB, _WaveC, _WaveD;

float3 GerstnerWave(float4 wave, float3 p, inout float3 tangent, inout float3 binormal)
{
	float amplitude = wave.z;
	float waveLength = wave.w;

	float k = 2 * UNITY_PI / waveLength;
	float c = sqrt(9.8 / k);
	float2 d = normalize(wave.xy);
	float f = k * (dot(d, p.xz) - (c * _Time.y));
	float a = amplitude / k;
	 
	float dxy = -d.x * d.y;
	float dxx = -d.x * d.x;
	float dyy = -d.y * d.y;

	float x = amplitude * cos(f);
	float y = amplitude * sin(f);

	tangent += float3 ((dxx * y), (d.x * x), (dxy * y));
	binormal += float3 ((dxy * y), (d.y * x), (dyy * y));

	return float3 (d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)) );
}

void vert(inout appdata_full vertexData)
{
	float3 gridPoint = vertexData.vertex.xyz;
	float3 tangent = 0;
	float3 binormal = 0;

	gridPoint += GerstnerWave(_WaveA, gridPoint, tangent, binormal);
	gridPoint += GerstnerWave(_WaveB, gridPoint, tangent, binormal);
	gridPoint += GerstnerWave(_WaveC, gridPoint, tangent, binormal);
	gridPoint += GerstnerWave(_WaveD, gridPoint, tangent, binormal);

	float3 normal = normalize(cross(binormal, tangent));
 
	vertexData.vertex.xyz = gridPoint;
	vertexData.normal = normal;
}

#endif