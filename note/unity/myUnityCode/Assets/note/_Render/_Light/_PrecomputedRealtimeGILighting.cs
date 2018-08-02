﻿using UnityEngine;
using System.Collections;

public class _PrecomputedRealtimeGILighting : MonoBehaviour {

	// Use this for initialization
	void Start () {
        /**
        这方式不太适合移动端

        Whilst traditional,
        static lightmaps are unable to react to changes in lighting conditions within the scene, 
        Precomputed Realtime GI does offer us a technique for updating complex scene lighting interactively.
        With this approach it is possible to create lit environments featuring rich global illumination
        with bounced light which responds,
        in realtime, to lighting changes.
        A good example of this would be a time of day system - 
        where the position and color of the light source changes over time.
        With traditional baked lighting, this is not possible.

        A simple example of time of day using Precomputed Realtime GI.
        In order to deliver these effects at playable framerates, 
        we need to shift some of the lengthy number - crunching from being a realtime process,
        to one which is ‘precomputed’.
        Precomputing shifts the burden of calculating complex light behaviour from something 
        that happens during gameplay, to something which can be calculated when time is no longer so critical.
        We refer to this as an ‘offline’ process.
        So how does this work?
        Most frequently it is indirect (bounced)light that
        we want to store in our lightmaps when trying to create realism in our scene lighting.
        Fortunately, this tends to be soft with few sharp, or 'high frequency’ changes in color. 
        Unity’s Precomputed Realtime GI solution exploits these ‘diffuse’ characteristics of indirect light to our advantage.
        Finer lighting details, such as crisp shadowing,
        are usually better generated with realtime lights rather than baking them into lightmaps.
        By assuming we don’t need to capture these intricate details 
        we can greatly reduce the resolution of our global illumination solution.
        By making this simplification during the precompute, 
        we effectively reduce the number of calculations we need to make in order to update our GI lighting during gameplay. 
        This is important if we were to change properties of our lights - such as color,
        rotation or intensity, or even make change to surfaces in the scene.
        To speed up the precompute further Unity doesn’t directly work on lightmaps texels,
        but instead creates a low resolution approximation of the static geometry in the world, called ‘clusters’.
        Left: 
            With scene view set to ‘Albedo’ the texels generated by Unity’s Precomputed Realtime GI can clearly be seen. 
            By default a texel in this view is roughly the size of a cluster. 
        Right: 
            The scene as it appears in-game once the lighting has been calculated and 
            the results converted to lightmap textures and applied.
            Traditionally when calculating global illumination, 
            we would ‘ray trace’ light rays as they bounce around the static scene.
            This is very processing intensive and therefore too demanding to be updated in realtime.Instead,
            Unity uses ray tracing to calculate the relationships between
            these surface clusters beforehand - during the 'Light Transport' stage of the precompute.

        By simplifying the world into a network of relationships,
        we remove the need for expensive ray tracing during the performance - critical gameplay processes.
        We have effectively created a simplified mathematical model of the world
        which can be fed different input during gameplay.This means we can make modifications to lights,
        or surface colors within the scene and quickly see the effects of GI in scene lighting update at interactive framerates.
        The resulting output from our lighting model can then be turned into lightmap textures for rendering on the GPU,
        blended with other lighting and surface maps, processed for effects and finally output to the screen.
    */
    }
	
	// Update is called once per frame
	void Update () {
	
	}
}