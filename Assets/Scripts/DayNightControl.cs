﻿
using UnityEngine;
using VRC.SDKBase;
using UdonSharp;
using VRC.Udon;
using BrokeredUpdates;

public class DayNightControl : UdonSharpBehaviour
{
	[UdonSynced] public int LightMode = 0;
	const int NumLightModes = 3;
	public Light DirectionalLight;
	public Material SkyboxMaterial;
	public Material SkyboxMaterialNight;
	public Material SkyboxBlackMaterial;
	public Material WaterMaterial;
	public Material BallMaterial;
	public Camera rprobeRender;
	public Cubemap       ctcopy;
	public Texel.AccessControl ACL;
	
	private int iWasMaster = 0;
	private int LastLightMode = -1;

	// Start is called before the first frame update
	void UpdateLightMode()
	{
		if( LastLightMode != LightMode )
		{
			switch( LightMode )
			{
				case 0:
					RenderSettings.skybox = SkyboxMaterial;
					DirectionalLight.transform.rotation = Quaternion.Euler( 140.686f, -268.419f, -19.71997f );
					DirectionalLight.color = new Color( 1.0f, 0.9177405f, 0.6933962f, 1.0f );
					RenderSettings.ambientIntensity = 1.0f;
					SkyboxMaterial.SetFloat( "_AtmosphereThickness", 1.0f );
					WaterMaterial.SetFloat( "_Glossiness", 1.0f );
					BallMaterial.SetFloat( "_NightMode", 0 );
					BallMaterial.SetFloat( "_Smoothness", .77f );
					BallMaterial.SetFloat( "_Metallic", 0.0f );
					break;
				case 1:
					DirectionalLight.color = new Color( 0.1654503f, 0.1958628f, 0.245283f, 1.0f );
					//DirectionalLight.transform.rotation = Quaternion.Euler( 164.79f, -120.73f, -20.39f);
					DirectionalLight.transform.rotation = Quaternion.Euler( 70.0f, 0.0f, 0.0f );
					//SkyboxMaterial.SetFloat( "_AtmosphereThickness", 0.5f );
					RenderSettings.skybox = SkyboxMaterialNight;
					RenderSettings.ambientIntensity = 1.0f;
					WaterMaterial.SetFloat( "_Glossiness", 0.8f );
					BallMaterial.SetFloat( "_NightMode", 1 );
					BallMaterial.SetFloat( "_Smoothness", 1.0f );
					BallMaterial.SetFloat( "_Metallic", 0.0f );
					break;
				case 2:
					RenderSettings.skybox = SkyboxMaterial;
					DirectionalLight.color = new Color( 1.0f, 0.9177405f, 0.6933962f, 1.0f );
					DirectionalLight.transform.rotation = Quaternion.Euler( 0, 128, 0 );
					SkyboxMaterial.SetFloat( "_AtmosphereThickness", 1.0f );
					RenderSettings.ambientIntensity = 1.0f;
					WaterMaterial.SetFloat( "_Glossiness", 1.0f );
					BallMaterial.SetFloat( "_NightMode", 0 );
					BallMaterial.SetFloat( "_Smoothness", .77f );
					BallMaterial.SetFloat( "_Metallic", 0.0f );
					break;
				case 3:
					RenderSettings.skybox = SkyboxBlackMaterial;					
					break;
				default:
					break;
			}
#if !UNITY_EDITOR
			rprobeRender.enabled = true;
			rprobeRender.RenderToCubemap( ctcopy, 63 );
			rprobeRender.enabled = false;
#endif
			GetComponent<MeshRenderer> ().material.SetFloat( "_SelMode", LightMode+1 );
		}
		else
		{
		}
	}
	
	public override void OnDeserialization()
	{
		UpdateLightMode();
	}
	
	public void _SnailUpdate()
	{
		int master = Networking.IsMaster?1:0;
		
		if( Utilities.IsValid( ACL ) )
		{
			if( ACL._LocalHasAccess() )
				master = 1;
		}
		
		if( iWasMaster != master )
		{
			GetComponent<MeshRenderer> ().material.SetFloat( "_UserEnable", master );
			iWasMaster = master;
		}
		
		// In case the variable is changed by other means.
		UpdateLightMode();
	}
	
	void Start()
	{
		GameObject.Find( "BrokeredUpdateManager" ).GetComponent<BrokeredUpdateManager>()._RegisterSnailUpdate( this );
		iWasMaster = 5;
		LastLightMode = -1;
		if( Networking.IsMaster )
		{
			LightMode = 1;
			RequestSerialization();
		}
		UpdateLightMode();
	}

	// Update is called once per frame
	void Interact()
	{
		bool master = Networking.IsMaster;
		
		if( Utilities.IsValid( ACL ) )
		{
			if( ACL._LocalHasAccess() )
				master = true;
		}

		if( master )
		{
			Networking.SetOwner( Networking.LocalPlayer, gameObject );
			LightMode = ( LightMode + 1 ) % NumLightModes;
			RequestSerialization();
		}
		UpdateLightMode();
	}
}
