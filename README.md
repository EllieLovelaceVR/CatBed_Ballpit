# cnballpit-vrc

## Tools

Process:
 * Open Project, BUT NOT SCENE.

Import the following, in order:
 * World SDK
 * Udon Sharp
 * AudioLink v0.2.5
 * CyanEmu
 
Extra:
 * Kaj Unity Shaders (I'm trying to learn to use this)
 * VRWorldToolkit (V1.11.2 current) (This seemed to fix me once when I could no longer export)
 
Close Project (and don't save).

 * Open Project
 * Open Scene

Haven't gotten NeoFlight working yet.

## TODO
 * Figure out why shadow edge length too short.
 * Add shadows to the balls.
 * Make ball pit use SDF for boundary.
 * Make both cameras for combine pass be at the same position, only one piece of geometry, maybe?
 * Test out explicit CRT Rendering Orders https://docs.unity3d.com/Manual/class-CustomRenderTexture.html#custom-render-texture
 * Double up physics steps, and make them sensitive to time.
 * Cleanup shaders, leaving standard ones.
 * Re: CRT Testing: Try assigning material and updating, and cycling in one fell swoop.
 * Figure out why some users get inundated by warnings about adding a depth buffer.
 * Make textured ball effect.
 * Figure out ball nonshadows occasionally.
 * Option to draw video on side of balls.
 * Why is AudioLink weird when doing colors.
 * Fix fadeout not writing fadeout tile to depth in depth pass.
 * TODO: Add another 2 stages, and flag on/off
 * Make video player collide with player.
 * TODO: Fix greyed out time of day box.
 * Make better motion's IIR framerate agnostic.
 * Exchange frame/total for udon/frame
 * Smooth out ball colors when in vector motion mode.
 * Add SlowUpdate feature.
 * UNITY_GET_INSTANCE_ID

## 2.0 Release Notes (Morning of July 6)
 * Make balls look really beautiful, try to use D4rk's thing.
 * Added Yeeters
 * Added pickuppable bricks
 * Moved text monolith locations.
 * Reduced impact of palm trees.
 
## 3.0 Release Notes (Evening of July 7)
 * Reduced Yeeter Delay
 * Removed a few blocks
 * Added a few yeeters.
 * Make the text fake-AA'd
 * Tried switching to Walkthrough layer
 * Put everything in map in object to cull.
 * Switched back to an explicit render.
 * Switched away from an explicit render to SetReplacementShader.  I promise. It's better.
 * Mention Patreon Notice
 * Put light culling mask to be mutually exclusive to compute cameras.
 * Added some props.
 * Change bounding box for points two different sizes, so balls can be seen from farther, but computing balls does not slow down adjacent cameras.

## 4.0 Release Notes (1:30 AM July 8)
 * Shroom!
 * Fix wood texture.
 * Add day/night cycle.
 * Thick pens.
 
## 5.0 Release Notes (3:00 AM July 9)
 * Fixed Night Sky + Ball effects at night.
 * Palm tree make look better depth.
 * Moved everything to a "compute" layer.
 * Upgraded TXL's player.
 
## 6.0 Release Notes
 * Made render-probe-less reflection maps work.  This is a perf boost from 5.0
 * Switched to manual sync for day/night control.
 * Added more effect bubbles (worldspace, normal, depth)
 * Fixed a few shader's shadow casts
 * Cleanup YEET (Write to shadow cast)
 * Cleanup Text (Write to shadow cast)

## 7.0 Release Notes (6:30 PM PT July 11)
 * Made video player moveable.
 * Added video player ball mode.
 * Moved things to an environment layer to speed up perf of culled objects marginally.
 * Make fountain pick uppable.
 * Made palm tree in back pick uppable.
 * Added "freeze" mode to the video on balls effect.

## 7.0a Release Notes
 * Fix mirrors not reflecting the world.

## 8.0 11:30 PM PT / July 11, 2021
 * Made rock texture local space.
 * Disabled change of ownership on collision on all objects.
 * Made sure the ownership settings were uniform across all objects.
 * Fixed layers some things were on, i.e. remove sphere-player collision.
 * Make the balls emit preferentialy from the middle.
 
## 9.0 11:45 PM PT / July 13, 2021
 * Add 2 additional fans.
 * Reduce ball popping when in compression.
 * Removed some pens.
 * Little RGB Balls on video screen.
 * Synchronize aurora in night sky.
 * Make balls fade out when too close.
 * Increase Audio Reactivity on Kit's rainbow effect.
 * Detect too many balls to represent in one cell by lighting up white.

## 10.0 10:30 PM PT / July 16, 2021
 * Tweaked ball adjacency settings to reduce popping.
 * Updated kit's shaders.

## 11.0 12:30 AM PT / July 17, 2021
 * Implemented updated adjacency logic, reducing number of cameras.
 * Kit fixed some of their shrooms.
 * Added reference camrea.
 
## 12.0 7:00 PM PT / July 18, 2021
 * Set filter mode on top texture.
 * Added ability to make top and bottom textures also bind a color buffer using the explicit render buffer binding code.  NOTE: this is disabled because it behaves weird and doesn't let users do fun things with shaders.
 * Button statuses update.
 * Added velocity mode.

## 13.0 10:00 PM PT / July 18, 2021
 * Added attractor ball
 * Improved selection buttons.
 
## 14.0 12:00 AM PT / July 21, 2021
 * Fix Texel Player
 * Add AudioLink visual to idle animation on video player.
 * Adjusted attractor physics.
 * Update TXLPlayer
 * Add Playlist to TXLPlayer
 * Added ability to fly.
 * Added more attractors.
 * Make markers draw thicker lines.

## 15.0 12:48 AM PT / July 23, 2021
 * Fix frame rate limiting glitch issue. TIL; Time.deltaTime in FixedUpdate is Time.fixedDeltaTime.
 * Add new Subscription Update system for improved perf, by avoiding VRCObjectSync.

## 16.0 12:45 AM PT / August 6, 2021
 * Updated brokered object sync
 * Allowed for parameterization of ball pit area for other worlds.
 * Improved rock texture to allow instancing and every instance of the rocks be different. (Instancing preferred)
 * Updated to Unity 2019
 * Switched to Ben's SuperPalm Trees

## 17.0 3:50 AM PT / August 6, 2021
 * Improved batching situation to allow more things to batch.
 * Reattached pens scripts.
 
## 18.0 1:31 AM PT / August 7, 2021
 * Add some rocks

## 19.0 
 * Made screen made out of balls.
 * Smooth edges of various things in map.
 * Updated palms.
 * Updated slates.
 * Removed Spheres
 * Made frawns sway
 * Made ball pit more prefabbable

## Interesting
 * shader_billboardout modes.
 * Ben Code Catch.
 
 
```glsl
 
for( j = 0; j < 4; j++ )
{
	uint obid;
	if( j == 0 )      obid = _Adjacency0[hashed];
	else if( j == 0 ) obid = _Adjacency1[hashed];
	else if( j == 0 ) obid = _Adjacency2[hashed];
	else              obid = _Adjacency3[hashed];
```
 * Back and forth about rendering technique.
 * Render Probes vs Cameras
 * Reference Camera
 * Double-up the blending.
 
## Special Thanks
 * D4rkPl4y3r for the idea, and several pointers!  Also, the binning principle.
 * ERROR.mdl for the `SV_DepthLessEqual` trick to make unsorted high performance balls.
 * TCL for the multiple render texture trick + the explicit camera order trick.
 * Everyone on the VRC Shader Discord for the 50+ questions I had to ask to write this.

VR Computer RTX 2070, Ryzen 3900X; Index at 144 Hz, 122%. Numbers are minimum times, peak up to about .3ms higher... So, signal in data is pretty good, probably around +/- .2ms. 

Conclusion when doing camera shimshammery: ~~Put cameras and objects on `PickupNoEnvironment`.  Cull for all objects not on `PickupNoEnvironment`~~ Your layers don't matter. 

Numbers with quick menu closed / open / With AudioLink and basic video player
Same layers, PickupNoEnvironment: 7.6ms / 9.3ms
Camera on default, looking at PickupNoEnvironment: 8.2ms / 10.0ms
Camera on UiMenu, looking at UiMenu: 8.1ms / 10.1ms
Camera on default, looking at UiMenu: 8.1 / 10.1 ms
(repeat) Camera on PickupNoEnvironment, looking at PickupNoEnvironment: 7.6ms / 9.4ms
Control: Everything off:  7ms / 7ms (framecap) (1.6ms / 2.5ms)
Control: Only AudioLink: 7ms / 7ms (framecap) (1.8ms / 2.7ms)
(repeat) Camera on PickupNoEnvironment, looking at PickupNoEnvironment: 8.1ms / 9.4ms
Camera on UiMenu, looking at UiMenu: 7.6ms / 9.3ms


## Control Update Test
 * Running uncapped, baseline 5.505ms / 4.17MB
 * Adding 500 tiles, each has VRCObjectSync, A custom script to handle disabling interaction on moving and VRCPickup.
 * .5ms Udon time / 11.250ms / 4.19MB
 * Removing VRCObjectSync
 * .35ms Udon time / 6.3ms / 4.19MB
 * Deltas: 
 *   With VRCObjectSync:                 .15ms UDON Time / 5.75ms Frame Time
 *   Without VRCObjectSync:               0ms  UDON Time / 0.8ms Frame Time
 *   Switching my object to manual:       0ms  UDON Time / 0.6ms Frame Time
 *   Adding an Update() method with i=0: 1.5ms UDON Time / 2.2ms Frame Time
 *   Using a brokered update function   : .3ms UDON Time /  0.9ms Frame Time
 * BetterObjectSync -> Going back to original scene.
 *   5.261ms.
 * Took exact thing from TEST to Upload version and visit with --fps=0 and in RenderDoc, it was 4.757ms
 