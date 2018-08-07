using FairyGUI;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CUILang : MonoBehaviour {

    // Use this for initialization
    void Start() {

    }

    // Update is called once per frame
    void Update() {

    }

    public void SetLang(string fileContent) {
        // string fileContent; //自行载入语言文件，这里假设已载入到此变量
        FairyGUI.Utils.XML xml = new FairyGUI.Utils.XML(fileContent);
        UIPackage.SetStringsSource(xml);

    }
}
