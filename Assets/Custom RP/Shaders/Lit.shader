Shader "Lit/Lit"
{
    	Properties {
			_BaseColor("Color", color) = (0.5, 0.5, 0.5, 1.0)
			_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
			_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
			_Glossiness("Glossiness", Float) = 32
			_RimColor("Rim Color", Color) = (1,1,1,1)
			_RimAmount("Rim Amount", Range(0, 1)) = 0.716
			_BaseMap("Texture", 2D) = "white" {}

			//[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 1
			//[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 0
		}
	
	SubShader {
		
		Pass {
			Tags {
				"LightMode" = "CustomLit"
			}
			HLSLPROGRAM
			#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment
			#include "LitPass.hlsl"

			ENDHLSL
		}
	}
}
