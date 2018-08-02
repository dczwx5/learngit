using UnityEngine;
using System.Collections;
using System.IO;
using System;

public class CFile : MonoBehaviour {

	// Use this for initialization
	void Start () {
        // _test();
    }

    void _test() {
        string path = "d:/a.txt";
        Debug.Log(path);

        WriteFile(path, "abc", true);

        string readText = ReadFile(path);
        Debug.Log(readText);
    }
	
	// Update is called once per frame
	void Update () {
	
	}

    // 写文件, isAppend是否追回, false, 则会新建文件
    public static void WriteFile(string path, string content, bool isAppend) {
        // 因为在 StreamWriter 语句中已声明并实例化 using 对象，所以会调用自动刷新并关闭流的 Dispose 方法。 
        using (StreamWriter outputFile = new StreamWriter(path, isAppend)) {
            outputFile.Write(content);
        }
    }
    // 
    public static string ReadFile(string path) {
        string ret = null;
        try {
            using (StreamReader sr = new StreamReader(path)) {
                String line = sr.ReadToEnd();
                ret = line;
            }
        } catch (Exception e) {
            Debug.LogError(e.Message);
        }
        return ret;

    }
    /**
    public static void Main() {
        string path = @"c:\temp\MyTest.txt";
        if (!File.Exists(path)) {
            // Create a file to write to.
            using (StreamWriter sw = File.CreateText(path)) {
                sw.WriteLine("Hello");
                sw.WriteLine("And");
                sw.WriteLine("Welcome");
            }
        }

        // Open the file to read from.
        using (StreamReader sr = File.OpenText(path)) {
            string s = "";
            while ((s = sr.ReadLine()) != null) {
                Console.WriteLine(s);
            }
        }
    }*/

}
