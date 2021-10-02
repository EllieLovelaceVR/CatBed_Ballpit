
using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;
using System;

/// <summary>
/// A Basic example class that demonstrates how to toggle a list of object on and off when someone interacts with the UdonBehaviour
/// This toggle only works locally
/// </summary>
[AddComponentMenu("Udon Sharp/Utilities/Interact Toggle")]
[UdonBehaviourSyncMode(BehaviourSyncMode.NoVariableSync)]
public class InteractToggleBallpit : UdonSharpBehaviour 
{
	[Tooltip("List of objects to toggle on and off")]
	public GameObject[] toggleObjects;
	public GameObject hideOnClickObject;

	void Start()
	{
		Debug.Log( "BallpitUtils IntearactToggleBallpit Start" );
	}

	public override void Interact()
	{
		Debug.Log( "BallpitUtils IntearactToggleBallpit Start Interact" );
		foreach (GameObject toggleObject in toggleObjects)
		{
			toggleObject.SetActive(!toggleObject.activeSelf);
		}
		if( Utilities.IsValid( hideOnClickObject ) )
			hideOnClickObject.SetActive( false );
	}
}
