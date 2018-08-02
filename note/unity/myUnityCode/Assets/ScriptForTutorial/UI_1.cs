using UnityEngine;
using System.Collections;

public class UI_1 : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	    
	}

    void OnGUI() {
        _OnGUI();
        _OnGUILayer();

        _OnWindowGUI();
    }

    private void _OnGUI() {
        float screenWidth = Screen.width;
        float screenHeight = Screen.height;
        Rect rect = new Rect(0.0f, 0.0f, screenWidth * 0.49f, screenHeight*0.49f);

        GUI.BeginGroup(rect);
        {
            GUI.Box(rect, "box");
            rect.Set(1, 1, 100, 60);
            if (GUI.Button(rect, "GUI.Button")) {
                Debug.Log("click on BUI.Button");
            }
        }
        GUI.EndGroup();
    }

    private Rect _wndRect;
    private bool _isWindowInitialized = false;
    private void _OnWindowGUI() {

        if (!_isWindowInitialized) {
            _isWindowInitialized = true;
            float screenWidth = Screen.width;
            float screenHeight = Screen.height;
            _wndRect = new Rect(0.0f, screenHeight * 0.51f, screenWidth * 0.49f, screenHeight * 0.49f);
        }

        _wndRect = GUI.Window(0, _wndRect, _onWindowDraw, "this is a window");
    }
    private void _onWindowDraw(int winID) {
        Rect rect = new Rect();
        rect.Set(.0f, 100.0f, 100.0f, 50.0f);
        GUI.Label(rect, "static label");

        rect.Set(0.0f, 0.0f, 100, 50);
        GUI.DragWindow(rect);
    }

    private string inputText = "input text";
    private bool toggle = true;
    private void _OnGUILayer() {
        float screenWidth = Screen.width;
        float screenHeight = Screen.height;
        Rect rect = new Rect(screenWidth*0.51f, screenHeight*0.51f, screenWidth * 0.49f, screenHeight * 0.49f);

        GUILayout.BeginArea(rect, "box");
        {
            // GUILayout.Box("box");
            // 默认水平布局
            if (GUILayout.Button("GUILayout.Button")) {
                Debug.Log("click on GUILayout.Button");
            }
            GUILayout.Label("Layout Label ");


            // 指定为垂直布局
            GUILayout.BeginVertical();
            {
                toggle = GUILayout.Toggle(toggle, "toggle");
                inputText = GUILayout.TextField(inputText);
            }
            GUILayout.EndVertical();
        }
        GUILayout.EndArea();
    }
}

