/**
 * @module renderer
 */
var renderer = renderer || {};

/**
 * @class ProgramLib
 */
renderer.ProgramLib = {

/**
 * @method getProgram
 * @param {String} arg0
 * @param {map_object} arg1
 * @return {cc.renderer::Program}
 */
getProgram : function (
str, 
map 
)
{
    return cc.renderer::Program;
},

/**
 * @method define
 * @param {String} arg0
 * @param {String} arg1
 * @param {String} arg2
 * @param {Array} arg3
 */
define : function (
str, 
str, 
str, 
array 
)
{
},

/**
 * @method getKey
 * @param {String} arg0
 * @param {map_object} arg1
 * @return {unsigned int}
 */
getKey : function (
str, 
map 
)
{
    return 0;
},

/**
 * @method ProgramLib
 * @constructor
 * @param {cc.renderer::DeviceGraphics} arg0
 * @param {Array} arg1
 */
ProgramLib : function (
devicegraphics, 
array 
)
{
},

};

/**
 * @class BaseRenderer
 */
renderer.Base = {

/**
 * @method getProgramLib
 * @return {cc.renderer::ProgramLib}
 */
getProgramLib : function (
)
{
    return cc.renderer::ProgramLib;
},

/**
 * @method init
* @param {cc.renderer::DeviceGraphics|cc.renderer::DeviceGraphics} devicegraphics
* @param {Array|Array} array
* @param {cc.renderer::Texture2D} texture2d
* @return {bool|bool}
*/
init : function(
devicegraphics,
array,
texture2d 
)
{
    return false;
},

/**
 * @method BaseRenderer
 * @constructor
 */
BaseRenderer : function (
)
{
},

};

/**
 * @class ForwardRenderer
 */
renderer.ForwardRenderer = {

/**
 * @method init
 * @param {cc.renderer::DeviceGraphics} arg0
 * @param {Array} arg1
 * @param {cc.renderer::Texture2D} arg2
 * @param {int} arg3
 * @param {int} arg4
 * @return {bool}
 */
init : function (
devicegraphics, 
array, 
texture2d, 
int, 
int 
)
{
    return false;
},

/**
 * @method ForwardRenderer
 * @constructor
 */
ForwardRenderer : function (
)
{
},

};

/**
 * @class View
 */
renderer.View = {

/**
 * @method View
 * @constructor
 */
View : function (
)
{
},

};

/**
 * @class Camera
 */
renderer.Camera = {

/**
 * @method getDepth
 * @return {float}
 */
getDepth : function (
)
{
    return 0;
},

/**
 * @method setFov
 * @param {float} arg0
 */
setFov : function (
float 
)
{
},

/**
 * @method getFrameBuffer
 * @return {cc.renderer::FrameBuffer}
 */
getFrameBuffer : function (
)
{
    return cc.renderer::FrameBuffer;
},

/**
 * @method setStencil
 * @param {int} arg0
 */
setStencil : function (
int 
)
{
},

/**
 * @method getOrthoHeight
 * @return {float}
 */
getOrthoHeight : function (
)
{
    return 0;
},

/**
 * @method getStencil
 * @return {int}
 */
getStencil : function (
)
{
    return 0;
},

/**
 * @method setFrameBuffer
 * @param {cc.renderer::FrameBuffer} arg0
 */
setFrameBuffer : function (
framebuffer 
)
{
},

/**
 * @method setFar
 * @param {float} arg0
 */
setFar : function (
float 
)
{
},

/**
 * @method setRect
 * @param {float} arg0
 * @param {float} arg1
 * @param {float} arg2
 * @param {float} arg3
 */
setRect : function (
float, 
float, 
float, 
float 
)
{
},

/**
 * @method setClearFlags
 * @param {unsigned char} arg0
 */
setClearFlags : function (
char 
)
{
},

/**
 * @method getFar
 * @return {float}
 */
getFar : function (
)
{
    return 0;
},

/**
 * @method getType
 * @return {cc.renderer::ProjectionType}
 */
getType : function (
)
{
    return 0;
},

/**
 * @method setNear
 * @param {float} arg0
 */
setNear : function (
float 
)
{
},

/**
 * @method setStages
 * @param {Array} arg0
 */
setStages : function (
array 
)
{
},

/**
 * @method setOrthoHeight
 * @param {float} arg0
 */
setOrthoHeight : function (
float 
)
{
},

/**
 * @method setDepth
 * @param {float} arg0
 */
setDepth : function (
float 
)
{
},

/**
 * @method getStages
 * @return {Array}
 */
getStages : function (
)
{
    return new Array();
},

/**
 * @method getFov
 * @return {float}
 */
getFov : function (
)
{
    return 0;
},

/**
 * @method setColor
 * @param {float} arg0
 * @param {float} arg1
 * @param {float} arg2
 * @param {float} arg3
 */
setColor : function (
float, 
float, 
float, 
float 
)
{
},

/**
 * @method setWorldMatrix
 * @param {mat4_object} arg0
 */
setWorldMatrix : function (
mat4 
)
{
},

/**
 * @method getNear
 * @return {float}
 */
getNear : function (
)
{
    return 0;
},

/**
 * @method getClearFlags
 * @return {unsigned char}
 */
getClearFlags : function (
)
{
    return 0;
},

/**
 * @method Camera
 * @constructor
 */
Camera : function (
)
{
},

};

/**
 * @class Effect
 */
renderer.EffectNative = {

/**
 * @method setDefineValue
 * @param {String} arg0
 * @param {cc.Value} arg1
 */
setDefineValue : function (
str, 
value 
)
{
},

/**
 * @method clear
 */
clear : function (
)
{
},

/**
 * @method Effect
 * @constructor
 */
Effect : function (
)
{
},

};

/**
 * @class Light
 */
renderer.Light = {

/**
 * @method getShadowScale
 * @return {float}
 */
getShadowScale : function (
)
{
    return 0;
},

/**
 * @method getRange
 * @return {float}
 */
getRange : function (
)
{
    return 0;
},

/**
 * @method setShadowResolution
 * @param {unsigned int} arg0
 */
setShadowResolution : function (
int 
)
{
},

/**
 * @method getFrustumEdgeFalloff
 * @return {unsigned int}
 */
getFrustumEdgeFalloff : function (
)
{
    return 0;
},

/**
 * @method setSpotExp
 * @param {float} arg0
 */
setSpotExp : function (
float 
)
{
},

/**
 * @method setShadowType
 * @param {cc.renderer::Light::ShadowType} arg0
 */
setShadowType : function (
shadowtype 
)
{
},

/**
 * @method setType
 * @param {cc.renderer::Light::LightType} arg0
 */
setType : function (
lighttype 
)
{
},

/**
 * @method getViewProjMatrix
 * @return {mat4_object}
 */
getViewProjMatrix : function (
)
{
    return cc.Mat4;
},

/**
 * @method getShadowBias
 * @return {float}
 */
getShadowBias : function (
)
{
    return 0;
},

/**
 * @method getShadowDarkness
 * @return {unsigned int}
 */
getShadowDarkness : function (
)
{
    return 0;
},

/**
 * @method getSpotAngle
 * @return {float}
 */
getSpotAngle : function (
)
{
    return 0;
},

/**
 * @method getSpotExp
 * @return {float}
 */
getSpotExp : function (
)
{
    return 0;
},

/**
 * @method getViewPorjMatrix
 * @return {mat4_object}
 */
getViewPorjMatrix : function (
)
{
    return cc.Mat4;
},

/**
 * @method getType
 * @return {cc.renderer::Light::LightType}
 */
getType : function (
)
{
    return 0;
},

/**
 * @method getIntensity
 * @return {float}
 */
getIntensity : function (
)
{
    return 0;
},

/**
 * @method getShadowMaxDepth
 * @return {float}
 */
getShadowMaxDepth : function (
)
{
    return 0;
},

/**
 * @method getWorldMatrix
 * @return {mat4_object}
 */
getWorldMatrix : function (
)
{
    return cc.Mat4;
},

/**
 * @method getShadowMap
 * @return {cc.renderer::Texture2D}
 */
getShadowMap : function (
)
{
    return cc.renderer::Texture2D;
},

/**
 * @method getColor
 * @return {cc.Color3F}
 */
getColor : function (
)
{
    return cc.Color3F;
},

/**
 * @method setIntensity
 * @param {float} arg0
 */
setIntensity : function (
float 
)
{
},

/**
 * @method getShadowMinDepth
 * @return {float}
 */
getShadowMinDepth : function (
)
{
    return 0;
},

/**
 * @method setShadowMinDepth
 * @param {float} arg0
 */
setShadowMinDepth : function (
float 
)
{
},

/**
 * @method update
 * @param {cc.renderer::DeviceGraphics} arg0
 */
update : function (
devicegraphics 
)
{
},

/**
 * @method setShadowDarkness
 * @param {unsigned int} arg0
 */
setShadowDarkness : function (
int 
)
{
},

/**
 * @method setWorldMatrix
 * @param {mat4_object} arg0
 */
setWorldMatrix : function (
mat4 
)
{
},

/**
 * @method setSpotAngle
 * @param {float} arg0
 */
setSpotAngle : function (
float 
)
{
},

/**
 * @method setRange
 * @param {float} arg0
 */
setRange : function (
float 
)
{
},

/**
 * @method setShadowScale
 * @param {float} arg0
 */
setShadowScale : function (
float 
)
{
},

/**
 * @method setColor
 * @param {float} arg0
 * @param {float} arg1
 * @param {float} arg2
 */
setColor : function (
float, 
float, 
float 
)
{
},

/**
 * @method setShadowMaxDepth
 * @param {float} arg0
 */
setShadowMaxDepth : function (
float 
)
{
},

/**
 * @method setFrustumEdgeFalloff
 * @param {unsigned int} arg0
 */
setFrustumEdgeFalloff : function (
int 
)
{
},

/**
 * @method getShadowType
 * @return {cc.renderer::Light::ShadowType}
 */
getShadowType : function (
)
{
    return 0;
},

/**
 * @method getShadowResolution
 * @return {unsigned int}
 */
getShadowResolution : function (
)
{
    return 0;
},

/**
 * @method setShadowBias
 * @param {float} arg0
 */
setShadowBias : function (
float 
)
{
},

/**
 * @method Light
 * @constructor
 */
Light : function (
)
{
},

};

/**
 * @class Pass
 */
renderer.PassNative = {

/**
 * @method getStencilTest
 * @return {bool}
 */
getStencilTest : function (
)
{
    return false;
},

/**
 * @method setStencilBack
 */
setStencilBack : function (
)
{
},

/**
 * @method setStencilTest
 * @param {bool} arg0
 */
setStencilTest : function (
bool 
)
{
},

/**
 * @method setCullMode
 * @param {cc.renderer::CullMode} arg0
 */
setCullMode : function (
cullmode 
)
{
},

/**
 * @method setBlend
 */
setBlend : function (
)
{
},

/**
 * @method setProgramName
 * @param {String} arg0
 */
setProgramName : function (
str 
)
{
},

/**
 * @method disableStencilTest
 */
disableStencilTest : function (
)
{
},

/**
 * @method setStencilFront
 */
setStencilFront : function (
)
{
},

/**
 * @method setDepth
 */
setDepth : function (
)
{
},

/**
 * @method Pass
 * @constructor
* @param {String} str
*/
Pass : function(
str 
)
{
},

};

/**
 * @class Scene
 */
renderer.Scene = {

/**
 * @method reset
 */
reset : function (
)
{
},

/**
 * @method getCameraCount
 * @return {unsigned int}
 */
getCameraCount : function (
)
{
    return 0;
},

/**
 * @method addCamera
 * @param {cc.renderer::Camera} arg0
 */
addCamera : function (
camera 
)
{
},

/**
 * @method removeCamera
 * @param {cc.renderer::Camera} arg0
 */
removeCamera : function (
camera 
)
{
},

/**
 * @method getLightCount
 * @return {unsigned int}
 */
getLightCount : function (
)
{
    return 0;
},

/**
 * @method getCamera
 * @param {unsigned int} arg0
 * @return {cc.renderer::Camera}
 */
getCamera : function (
int 
)
{
    return cc.renderer::Camera;
},

/**
 * @method getLight
 * @param {unsigned int} arg0
 * @return {cc.renderer::Light}
 */
getLight : function (
int 
)
{
    return cc.renderer::Light;
},

/**
 * @method getCameras
 * @return {Array}
 */
getCameras : function (
)
{
    return new Array();
},

/**
 * @method addView
 * @param {cc.renderer::View} arg0
 */
addView : function (
view 
)
{
},

/**
 * @method setDebugCamera
 * @param {cc.renderer::Camera} arg0
 */
setDebugCamera : function (
camera 
)
{
},

/**
 * @method removeView
 * @param {cc.renderer::View} arg0
 */
removeView : function (
view 
)
{
},

/**
 * @method addLight
 * @param {cc.renderer::Light} arg0
 */
addLight : function (
light 
)
{
},

/**
 * @method removeLight
 * @param {cc.renderer::Light} arg0
 */
removeLight : function (
light 
)
{
},

/**
 * @method Scene
 * @constructor
 */
Scene : function (
)
{
},

};
