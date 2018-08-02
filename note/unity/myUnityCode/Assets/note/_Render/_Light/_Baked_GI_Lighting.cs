﻿using UnityEngine;
using System.Collections;

public class _Baked_GI_Lighting : MonoBehaviour {

	// Use this for initialization
	void Start () {
        /**
        When 'baking’ a ‘lightmap', 
        the effects of light on static objects in the scene are calculated and the results are written to textures 
        which are overlaid on top of scene geometry to create the effect of lighting.
        烘照一个光照图时, 计算光对场景中静态物体的影响, 并将结果写入到纹理(场景上的几何体), 以创建光照效果

        Left: 
            A simple lightmapped scene. 
        Right: 
            The lightmap texture generated by Unity. 
            Note how both shadow and light information is captured.
        左：一个简单的光照场景。右：由统一产生的光照贴图纹理。注意如何捕获阴影和光信息。 

        These ‘lightmaps’ can include both the direct light which strikes a surface and also the ‘indirect’ light 
        that bounces from other objects or surfaces within the scene.
        This lighting texture can be used together with surface information like color(albedo) and relief(normals) 
        by the ‘Shader’ associated with an object’s material.
        这些“光照图”既可以包括撞击表面的直射光，也可以包括从场景中的其他物体或表面反弹的“间接”光。
        光照纹理可以和物体材质相关的表面信息(（如反光）和浮雕（法线）)一起使用

        With baked lighting, these light textures(lightmaps) cannot change during gameplay and so are referred to as ‘static’. 
        Realtime lights can be overlaid and used additively on top of a lightmapped scene 
        but cannot interactively change the lightmaps themselves.
        在烘焙灯光下，这些轻质纹理（光照图）在游戏过程中不能改变，因此被称为“静态”。
        实时光可以叠加并在光照场景的顶部叠加使用，但不能交互式地改变光照图本身。 

        With this approach, we trade the ability to move our lights at gameplay for a potential increase in performance,
        suiting less powerful hardware such as mobile platforms.
        这种方式, 适用于提高光照的性能, 适用于硬件较弱的平台，如移动平台
    */
        /**
        Per - Light Settings
        The default baking mode for each light is ‘Realtime’. 
        This means that the selected light(s) will still contribute direct light to your scene, 
        with indirect light handled by Unity’s Precomputed Realtime GI system.
        However, if the baking mode is set to ‘Baked’ 
        then that light will contribute lighting solely to Unity’s Baked GI system.
        Both direct and indirect light from those lights selected 
        will be ‘baked’ into lightmaps and cannot be changed during gameplay.
        Point light with the per - light Baking mode set to ‘Realtime’.
        Selecting the ‘Mixed’ baking mode, 
        GameObjects marked as static will still include this light in their Baked GI lightmaps.
        However, unlike lights marked as ‘Baked’, 
        Mixed lights will still contribute realtime, 
        direct light to non -static GameObjects within your scene. 
        This can be useful in cases where you are using lightmaps in your static environment,
        but you still want a character to use these same lights to cast realtime shadows onto lightmapped geometry.

        默认的烘培模式为 RealTime, 这种模式下, 灯光会对场景产生直射光, 而反射光由unity的预计算生成
        如果烘培模式为 Baked, 则光照只会影响unity的烘培系统, 直射和反射光都会烘培在光照图中, 并不会在游戏过程中改变
        点光的模式要设为RealTime(?)
        混合模式下, 在游戏中, 光照会对非static 物体产生影响
        */
    }

    // Update is called once per frame
    void Update () {
	
	}
}
