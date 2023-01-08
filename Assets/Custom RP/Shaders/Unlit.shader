Shader "Unlit/Unlit"
{
    	Properties {
			_BaseColor("Color", color) = (1.0, 1.0, 0.0, 1.0)
			_BaseMap("Texture", 2D) = "white" {}

			//[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 1
			//[Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 0
		}
	
	SubShader {
		
		Pass {
			HLSLPROGRAM
			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment
			#include "UnlitPass.hlsl"
			ENDHLSL
		}
	}
}
