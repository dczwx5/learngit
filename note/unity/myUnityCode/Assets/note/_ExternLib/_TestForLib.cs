using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TestLib;
public class _TestForLib : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Debug.Log(TestMath.Lerp(10, 20, 0.4f));

    }
    /**
     * c#项目创建动态链接库
     * 建库项目, networkframe不能超过3.5
     * 编译导出dll
     * 
     * 将dll放到asset下.
     * using namespace
     * 
     */ 

    /**
    Assembly unity最后所有的目标代码。
    加载顺序。
    1.所有在assets下的dll 打包到assets.dll
    2.assets下，assetsStandard下的代码，打包到firstpass
    3.assets下其他代码，打包到csharp
    .assets下，assetsStandard/editor下的代码，打包到editor.firstpass.只在编辑器有用，不会打包出去
    .assets下，editor下的代码，打包到editor.csharp只在编辑器有用，不会打包出去
    Editor的代码不能和其他代码有引用，editor代码是为了扩展编辑器
    */
}
