using UnityEngine;
using System.Collections;

public class _RealTimeLight : MonoBehaviour {

	// Use this for initialization
	void Start () {
        // By default, lights in Unity - directional, spot and point, are realtime.
        // 方向光, 聚光, 点光 : 属于实时光照
        // This means that they contribute direct light to the scene and update every frame. 
        // 他们给场景提供直接的光照, 并每帧更新
        // As lights and GameObjects are moved within the scene, lighting will be updated immediately.
        // 光照和物体在场景里移动时, 光照会马上更新
        // This can be observed in both the scene and game view  
        // 在scene和game都可以看的到

        // The effect of realtime light alone. 
        // Note that shadows are completely black as there is no bounced light. 
        // Only surfaces falling within the cone of the Spotlight are affected.
        // 实时光的阴影是全黑的, 因为没有反射光. 其他是废话

        // Realtime lighting is the most basic way of lighting objects within the scene 
        // and is useful for illuminating characters or other movable geometry.
        // 实时光照是照亮场景物体最基本的方式, 并且在照亮人物或者其他可移动几何物体时很有作用

        // Unfortunately, the light rays from Unity’s realtime lights do not bounce 
        // when they are used by themselves.
        // In order to create more realistic scenes using techniques such as global illumination 
        // we need to enable Unity’s precomputed lighting solutions.
        // 实时光照不会反射, 所以为了使场景更真实, 需要启用unity的预计算光照, 使用类似全局光照等技术
    }

    // Update is called once per frame
    void Update () {
	
	}
}
