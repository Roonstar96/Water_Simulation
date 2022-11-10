Shader "Custom/OceanShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
       

        _WaveA("Wave A (Dir, Amp, Wave)", Vector) = (0.8, 1, 0.25, 60)
        _WaveB("Wave B (Dir, Amp, Wave)", Vector) = (2.3, 0.6, 0.25, 31)
        _WaveC("Wave C (Dir, Amp, Wave)", Vector) = (-0.1, 1.3, 0.25, 18)
        _WaveD("Wave D (Dir, Amp, Wave)", Vector) = (-2, 0.9, 0.5, 8)

       // _WaveD("Wave E (Dir, Amp, Wave)", Vector) = (0.5, 2.1, 0.5, 5)
        //_WaveD("Wave F (Dir, Amp, Wave)", Vector) = (0.5, 1.3, 0.5, 1)
    }
    SubShader
    {
        //Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Tags { "RenderType" = "Opaque"}
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow 
        #pragma target 3.0

        #include "Water.cginc"

        sampler2D _MainTex; 

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
}
