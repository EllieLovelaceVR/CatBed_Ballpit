﻿
using UnityEngine;
using VRC.SDKBase;

#if UDON
using UdonSharp;
using VRC.Udon;

public class ballpit_stable_control : UdonSharpBehaviour
{

	[UdonSynced] public float gravityF = 9.8f;
	[UdonSynced] public float friction = .008f;
	public Material ballpitA;
	public Material ballpitB;

	void Start()
	{
		if (Networking.IsMaster)
		{
			gravityF = 9.8f;
			friction = .008f;
		}

	}
	void Update()
	{
		ballpitA.SetFloat( "_GravityValue", gravityF );
		ballpitB.SetFloat( "_GravityValue", gravityF );
		ballpitA.SetFloat( "_Friction", friction );
		ballpitB.SetFloat( "_Friction", friction );
	}
}

#else
public class ballpit_stable_control : MonoBehaviour { }
#endif