#ifndef CUSTOM_LIT_PASS_INCLUDED
#define CUSTOM_LIT_PASS_INCLUDED

#include "../ShaderLibrary/Common.hlsl"
#include "../ShaderLibrary/Surface.hlsl"
#include "../ShaderLibrary/Light.hlsl"
#include "../ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
	UNITY_DEFINE_INSTANCED_PROP(float4, _AmbientColor)
    UNITY_DEFINE_INSTANCED_PROP(float4, _SpecularColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _Glossiness)
    UNITY_DEFINE_INSTANCED_PROP(float4, _RimColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _RimAmount)


UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

inline float3 UnityWorldSpaceViewDirz(in float3 worldPos)
{
    return _WorldSpaceCameraPos.xyz - worldPos;
}

struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 baseUV : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 normalWS : NORMAL;
    float2 baseUV : VAR_BASE_UV;
    float3 viewDir : TEXCOORD1;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};


Varyings LitPassVertex(Attributes input)
{
    Varyings output;
    
	UNITY_SETUP_INSTANCE_ID(input);
	UNITY_TRANSFER_INSTANCE_ID(input, output);

    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.viewDir = UnityWorldSpaceViewDirz(input.positionOS);    

    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseMap_ST);
    output.baseUV = input.baseUV * baseST.xy + baseST.zw;
    return output;
}

float4 LitPassFragment(Varyings input) : SV_TARGET
{
	UNITY_SETUP_INSTANCE_ID(input);
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.baseUV);
    float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
    float4 base = baseMap * baseColor;
    
#if defined(_CLIPPING)
		clip(base.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff));
#endif
    
    // Cell Shading
    float3 normal = normalize(input.normalWS);
    
    float NdotL = dot(_WorldSpaceLightPos0, normal);
    
    float lightIntensity = smoothstep(0, 0.01, NdotL);
    
    Light l = GetDirectionalLight();
    
    float4 light = lightIntensity * float4(l.color, 1000);

    float3 viewDir = normalize(input.viewDir);
    
    float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
    
    float NdotH = dot(normal, halfVector);
    
    float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
    
    float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
    
    float4 specular = specularIntensitySmooth * _SpecularColor;
    
    float4 rimDot = 1 - dot(viewDir, normal);
    
    float rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimDot);
    
    float4 rim = rimIntensity * _RimColor;
    
    return _BaseColor * (_AmbientColor + light + specular);
}


#endif

