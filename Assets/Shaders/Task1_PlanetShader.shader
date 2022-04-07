Shader "Custom/Task1_PlanetShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Emission("Emission", Color) = (1,1,1,1)
        _Height("Height", Range(-1,1)) = 0
        _Mountains("Mountains", Range(0, 0.45)) = 0.25
        _Oceans("Oceans", Range(0, 0.45)) = 0.25
        _Seed("Seed", Range(0,10000)) = 10
        _MountCol("Mountains Color", Color) = (1,1,1,1)
        _PlainCol("Plains Color", Color) = (1,1,1,1)
        _OceanCol("Oceans Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM

        #pragma surface surf Lambert noforwardadd noshadow vertex:vert

        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 color: COLOR;
        };

        fixed4 _Color;
        float4 _Emission;
        float _Height;
        float _Seed;
        float _Mountains;
        float _Oceans;
        fixed4 _MountCol;
        fixed4 _PlainCol;
        fixed4 _OceanCol;
    
        float hash(float2 st)
        {
            return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
        }

        float noise(float2 p, float size)
        {
            float result = 0;
            p *= size;
            float2 i = floor(p + _Seed);
            float2 f = frac(p + _Seed / 739);
            float2 e = float2(0, 1);
            float z0 = hash((i + e.xx) % size);
            float z1 = hash((i + e.yx) % size);
            float z2 = hash((i + e.xy) % size);
            float z3 = hash((i + e.yy) % size);
            float2 u = smoothstep(0, 1, f);
            result = lerp(z0, z1, u.x) + (z2 - z0) * u.y * (1.0 - u.x) + (z3 - z1) *
            u.x * u.y;
            return result;
        }

        void vert(inout appdata_full v)
        {
            float height = noise(v.texcoord, 5) * 0.75 + noise(v.texcoord, 30) *
            0.125 + noise(v.texcoord, 50) * 0.125;
            v.color.r = height + _Height;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 color = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            float height = IN.color.r;

            if (height < _Oceans)
            {
                color *= _OceanCol;
            }
            else if (height < 1 - _Mountains)
            {
                color *= _PlainCol;
            }
            else
            {
                color *= _MountCol;
            }

            o.Albedo = color.rgb;
            o.Emission = _Emission.xyz;
            o.Alpha = color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
