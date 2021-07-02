// MIT License
// Copyright (c) 2021 Merlin

using UdonSharp;
using UnityEngine;

using VRC.SDK3.Components;
using VRC.SDKBase;
using VRC.Udon;

[DefaultExecutionOrder(1000000000)]
public class GlobalProfileHandler : UdonSharpBehaviour
{
    UnityEngine.UI.Text timeText;
    GlobalProfileKickoff kickoff;

    private void Start()
    {
        kickoff = GetComponent<GlobalProfileKickoff>();
        timeText = GetComponentInChildren<UnityEngine.UI.Text>();
    }

    int currentFrame = -1;
    float elapsedTime = 0f;
	int frame400count  = 0;
	float elapsed400total = 0f;
	float lastframe400 = 0f;

    private void FixedUpdate()
    {
        if (currentFrame != Time.frameCount)
        {
            elapsedTime = 0f;
            currentFrame = Time.frameCount;
        }

        if (kickoff)
            elapsedTime += (float)kickoff.stopwatch.Elapsed.TotalSeconds * 1000f;
    }

    private void Update()
    {
        if (currentFrame != Time.frameCount) // FixedUpdate didn't run this frame, so reset the time
            elapsedTime = 0f;

        elapsedTime += (float)kickoff.stopwatch.Elapsed.TotalSeconds * 1000f;
    }

    private void LateUpdate()
    {
        elapsedTime += (float)kickoff.stopwatch.Elapsed.TotalSeconds * 1000f;
		elapsed400total += Time.deltaTime;
		frame400count ++;
		if( frame400count >= 400 )
		{
			lastframe400 = elapsed400total / .4f;
			frame400count = 0;
			elapsed400total = 0;
		}
		
		VRCPlayerApi owner = Networking.GetOwner(gameObject);
        timeText.text = $"Frame: {elapsedTime:F3}ms\nTotal:{lastframe400:F3}\n{owner.displayName}";
    }
}