using System.Collections;
using UnityEngine;

public class CApplication_ResLoad : MonoBehaviour {

	// Use this for initialization
	void Start () {

        //_path();

        // XElement result = LoadXML("Assets/xml-to-egg/xml-to-egg-test/Test.xml");//任性的地址
        // Debug.Log(result.ToString());

        // _loadFromResource();

        // StartCoroutine(_loadFromStreamAssets());
        // StartCoroutine(_loadFromStreamAssets_tex());

        // 
        // StartCoroutine(_loadBundle());

        _persistentDataPath();
    }

    // ============================================================Resource====================================================================================
    // Resources目录使用Resource.Load
    private void _loadFromResource() {
        string path = "Material/ballDiffuse";

        // 和prefab不同, load进来。是什么类型就是什么类型
        // Resource.Load是阻塞的, 主线程加载
        Material res = (Material)Resources.Load(path); 
        GameObject obj = GameObject.Find("_resource");
        MeshRenderer meshRender = obj.GetComponent<MeshRenderer>();
        meshRender.material = (Material)res;

        // 测试 加载文本
        string txtPath = "txt";
        Object txtObj = Resources.Load(txtPath); 
        string result = txtObj.ToString(); 
        Debug.Log(result);
    }

    // ========================================================streamingAssets && www=============================================================================
    // streamingAssets只能使用www来读取
    private IEnumerator _loadFromStreamAssets() {
        // 本地加载的话, 路径要加file://

        string path = "file://" + Application.streamingAssetsPath + "/aa";
        Debug.Log(path);
        // 异步
        WWW www = new WWW(path);
        yield return www;

        if (www.error != null) {
            Debug.LogError(www.error);
        } else {
            string strRet = www.text;
            Debug.Log(strRet);
        }
    }
    private IEnumerator _loadFromStreamAssets_tex() {
        string path = "file://" + Application.streamingAssetsPath + "/tex.jpg";
        WWW www = new WWW(path);
        yield return www;

        if (www.error != null) {
            Debug.LogError(www.error);
        } else {
            Texture2D tex = www.texture;
            Debug.Log("tex width : " + tex.width);

        }
    }

    // ========================================================bundle=============================================================================
    // 需要先整理bundle
    private IEnumerator _loadBundle() {
        Debug.Log("_loadBundle");
        // 只能加载bundle
        // WWW.LoadFromCacheOrDownload(path, 1);

        AssetBundle bundle = new AssetBundle();
        //读取放入StreamingAssets文件夹中的bundle文件
        string str = "file://" + Application.streamingAssetsPath + "/bundle/commoncfg.assetbundle";
        WWW www = new WWW(str);
        www = WWW.LoadFromCacheOrDownload(str, 0);
        yield return www;

        if (www.error != null) {
            Debug.Log(www.error);
        } else {
            bundle = www.assetBundle;
            string path = "Test";
            TextAsset test = bundle.LoadAsset(path, typeof(TextAsset)) as TextAsset;

            string ret = test.ToString();
            Debug.Log(ret);
        }
    }

    // ========================================================persistentDataPath=============================================================================
    // Application.persistentDataPath 此属性用于返回一个持久化数据存储目录的路径，可以在此路径下存储一些持久化的数据文件。 
    private void _persistentDataPath() {
        Debug.Log("_persistentDataPath");
        string path = System.IO.Path.Combine(Application.persistentDataPath, "myTxt");
        Debug.Log(path);
        string str = "aaa=1";
        str += "\nbbb=2";
        str += "\nccc=3";
        CFile.WriteFile(path, str, false);

        string rwText = CFile.ReadFile(path);
        Debug.Log(rwText);
    }

    private void _path() {
        // project direction -> F:\auto\autoGit\AssetbundleTool

        // 以下四个函数, 在andrio.iso . pc都适用. 但路径会不同
        // Application.dataPath 此属性用于返回程序的数据文件所在文件夹的路径。例如在Editor中就是Assets了。
        // F:/auto/autoGit/AssetbundleTool/Assets
        Debug.Log("Application.dataPath : \n" + Application.dataPath);

        // Application.streamingAssetsPath 此属性用于返回流数据的缓存目录，返回路径为相对路径，适合设置一些外部数据文件的路径。
        // F:/auto/autoGit/AssetbundleTool/Assets/StreamingAssets
        Debug.Log("Application.streamingAssetsPath : \n" + Application.streamingAssetsPath);

        // Application.persistentDataPath 此属性用于返回一个持久化数据存储目录的路径，可以在此路径下存储一些持久化的数据文件。 
        // C:/Users/Administrator/AppData/LocalLow/DefaultCompany/AssetbundleTool
        Debug.Log("Application.persistentDataPath : \n" + Application.persistentDataPath);

        // Application.temporaryCachePath 此属性用于返回一个临时数据的缓存目录
        // C:/Users/ADMINI~1/AppData/Local/Temp/DefaultCompany/AssetbundleTool
        Debug.Log("Application.temporaryCachePath : \n" + Application.temporaryCachePath);
    }
    private void _direction() {
        // Resources
        // 作为一个Unity3D的保留文件夹出现的，也就是如果你新建的文件夹的名字叫Resources，那么里面的内容在打包时都会被无条件的打到发布包中。它的特点简单总结一下就是：
        // 1.只读，即不能动态修改。所以想要动态更新的资源不要放在这里。
        // 2.会将文件夹内的资源打包集成到.asset文件里面。因此建议可以放一些Prefab，因为Prefab在打包时会自动过滤掉不需要的资源，有利于减小资源包的大小。
        // 3.主线程加载。
        // 4.资源读取使用Resources.Load()。

        // StreamingAssets
        // 要说到StreamingAssets，其实和Resources还是蛮像的。同样作为一个只读的Unity3D的保留文件夹出现。
        // 不过两者也有很大的区别，那就是Resources文件夹中的内容在打包时会被压缩和加密。
        // 而StreamingAsset文件夹中的内容则会原封不动的打入包中，因此StreamingAssets主要用来存放一些二进制文件。下面也同样做一个简单的总结：
        // 1.同样，只读不可写。
        // 2.主要用来存放二进制文件。
        // 3.只能用过WWW类来读取。

        // AssetBundle
        // 关于AssetBundle的介绍已经有很多了。简而言之就是把prefab或者二进制文件封装成AssetBundle文件（也是一种二进制）。但是也有硬伤，就是在移动端无法更新脚本。下面简单的总结下：
        // 1.是Unity3D定义的一种二进制类型。
        // 2.最好将prefab封装成AseetBundle，不过上面不是才说了在移动端无法更新脚本吗？那从Assetbundle中拿到的Prefab上挂的脚本是不是就无法运行了？也不一定，只要这个prefab上挂的是本地脚本，就可以。
        // 3.使用WWW类来下载。

        // PersistentDataPath
        // 看上去它只是个路径呀，可为什么要把它从路径里面单独拿出来介绍呢？因为它的确蛮特殊的，这个路径下是可读写。
        // 而且在IOS上就是应用程序的沙盒，但是在Android可以是程序的沙盒，也可以是sdcard。
        // 并且在Android打包的时候，ProjectSetting页面有一个选项Write Access，可以设置它的路径是沙盒还是sdcard。下面同样简单的总结一下：
        // 1.内容可读写，不过只能运行时才能写入或者读取。提前将数据存入这个路径是不可行的。
        // 2.无内容限制。你可以从StreamingAsset中读取二进制文件或者从AssetBundle读取文件来写入PersistentDataPath中。
        // 3.写下的文件，可以在电脑上查看。同样也可以清掉。

        // 好啦，小匹夫介绍到这里，各位看官们是不是也都清楚了一些呢？那么下面我们就开始最后一步了，也就是如何在移动平台如何读取外部文件。

    }
    /**private XElement LoadXML(string path) {
        XElement xml = XElement.Load(path);
        return xml;
    }
    private void LoadXML2(string path) {
        _result = Resources.Load(path).ToString();
        XmlDocument doc = new XmlDocument();
        doc.LoadXml(_result);
    }*/


    // Update is called once per frame
    void Update () {
		
	}
}
