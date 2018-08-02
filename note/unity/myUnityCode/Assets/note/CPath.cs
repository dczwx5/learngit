using UnityEngine;
using System.Collections;
using System;

public class CPath : MonoBehaviour {

	// Use this for initialization
	void Start () {
        // 获得我的文档路径
        string myDocPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments); 
        string path = myDocPath + "/WriteLines.txt";
        Debug.Log(path);
       
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

    // Update is called once per frame
    void Update () {
	
	}
}
