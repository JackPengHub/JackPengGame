Shader "Custom/TankeEditor" 
{
	Properties 
	{
		_Cutoff 	 ("Alpha cutoff", Range(0,1)) = 0.5
		_EmissivePower( "EmissPower (float)", Range(0,10)) = 1.0
		_SpecularPower("SpecularPower (float)", Range(0,1)) = 0.10
		_MainTex	 ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_BumpMap	 ("Normalmap", 2D) = "bump" {}
		_EmissiveTex ("Emissive (RGB)", 2D) = "white" {}
		_Specular 	 ("Specular (RGB)", 2D) = "white" {}
		_OpacityTex  ("Opacity (RGBA)", 2D) = "white" {}
		_GlossTex    ("Gloss (RGB)", 2D) = "white" {}
		_AOTex       ("AO (RGB)", 2D) = "white" {}
	}

	SubShader 
	{
		Tags {"Queue"="Opaque" "IgnoreProjector"="True" "RenderType"="Opaque"}
		LOD 200

		CGPROGRAM
		#pragma surface surf TankeEditor alphatest:_Cutoff

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _Specular;
		sampler2D _EmissiveTex;
		sampler2D _OpacityTex;
		sampler2D _GlossTex;
		sampler2D _AOTex;
		
		float _EmissivePower;
		float _SpecularPower;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};
		
		inline half4 LightingTankeEditor(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half diff = max (0, dot ( lightDir, s.Normal ));

			half4 res;
			res.rgb = _LightColor0.rgb * diff;
			res.w = Luminance(_LightColor0.rgb);
			res *= atten * 2.0;
			
			float4 c;
			c.rgb = (s.Albedo + s.Emission ) * res + s.Specular; 
			c.a = s.Alpha;
			return c;
		}
		
		void surf (Input IN, inout SurfaceOutput o) 
		{
			float4 cDiffuse=tex2D(_MainTex,(IN.uv_MainTex.xyxy).xy);
			float4 cNormal=tex2D(_BumpMap,(IN.uv_BumpMap.xyxy).xy);
			float4 cEmissive = tex2D (_EmissiveTex, IN.uv_MainTex);
			float4 cSpecular = tex2D (_Specular, IN.uv_MainTex);
			float4 cOpacity = tex2D (_OpacityTex, IN.uv_MainTex);
			float4 cGloss = tex2D (_GlossTex, IN.uv_MainTex);
			float4 cAO = tex2D (_AOTex, IN.uv_MainTex);
					
			o.Albedo = cDiffuse.rgb * cAO.rgb;
			
			o.Normal = UnpackNormal(cNormal);
			o.Emission = _EmissivePower * cEmissive;
			o.Normal = normalize(o.Normal);
			o.Specular = (cSpecular + cGloss.rgba) * _SpecularPower;
			o.Alpha = cOpacity.a;
		}
		ENDCG
	}
}
