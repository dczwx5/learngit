using Core;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CLobbyView : CBean {

	// Use this for initialization
	void Start () {
        isExit = false;

    }

    private void OnGUI() {
        GUI.Button(new Rect(0, 0, 200, 100), "这是头像");
        GUI.Button(new Rect(0, Screen.height - 300, 300, 300), "聊天");
        GUI.Button(new Rect(Screen.width - 200, 0, 200, 100), "这是功能图标");
        GUI.Button(new Rect(Screen.width - 200, Screen.height - 100, 200, 100), "这是下面的功能图标");

        if (GUI.Button(new Rect(Screen.width/2 - 100, Screen.height/2 - 100, 200, 200), "退出")) {
            isExit = true;
        }
    }

    public bool isExit {
        get;
        private set;
    }
}
