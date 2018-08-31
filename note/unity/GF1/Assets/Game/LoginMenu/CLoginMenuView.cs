using Core;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CLoginMenuView : CBean {

    private void Start() {
        isStart = false;
        isExit = false;
    }
    private void OnGUI() {
        float sw = Screen.width;
        float sh = Screen.height;
        float startY = (sh - (4*100 + 3 * 20)) * 0.5f;
        if (GUI.Button(new Rect(sw / 2 - 200, startY, 200, 100), "重新开始")) {
            isStart = true;
        }
        GUI.Button(new Rect(sw / 2 - 200, startY + 120, 200, 100), "继教");
        GUI.Button(new Rect(sw / 2 - 200, startY + 240, 200, 100), "配置");
        if (GUI.Button(new Rect(sw / 2 - 200, startY + 360, 200, 100), "退出")) {
            isExit = true;
        }
    }

    public bool isStart {
        get;
        private set;
    }
    public bool isExit {
        get;
        private set;
    }
}
