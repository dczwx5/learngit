using UnityEngine;
using System.Collections;

public class UI_1 : MonoBehaviour {

    private int m_toolbarSelectIndex = 1;
    enum ToolBarIndex { 
        GUI, GUILAYEY, WINDOW
    };
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	    
	}

    
    void OnGUI() {
        _OnToggle();
        switch (m_toolbarSelectIndex) {
            case (int)ToolBarIndex.GUI:
                _OnGUI();
                break;
            case (int)ToolBarIndex.GUILAYEY:
                _OnGUILayer();
                break;
            case (int)ToolBarIndex.WINDOW:
                _OnWindowGUI();
                break;
        }
    }
    void _OnToggle() {
        string[] toolbarString = { "GUI", "GUILayer", "Window" };
        m_toolbarSelectIndex = GUI.Toolbar(new Rect(0, 0, 200, 20), m_toolbarSelectIndex, toolbarString);
    }

    private void _OnGUI() {
        float screenWidth = Screen.width;
        float screenHeight = Screen.height;
        Rect rect = new Rect(screenWidth*0.05f, screenHeight * 0.05f, screenWidth * 0.9f, screenHeight*0.9f);
        // 因为ｇｕｉ的布局要定ｒｅｃｔ，　所以这里不做其他组件和GUIContent GUIStyle的例子，在ＧｕｉＬａｙｅｒ中实现
        GUI.BeginGroup(rect);
        {
            // box
            rect.Set(0, 0, rect.width, rect.height);
            GUI.Box(rect, "box");

            // Button
            rect.Set(1, 1, 100, 60);
            bool isClickBtn = GUI.Button(rect, "GUI.Button");
            if (isClickBtn) {
                Debug.Log("click on BUI.Button");
            }
        }
        GUI.EndGroup();
    }

    // ===========================================================WINDOW
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

    // ======================================================GUILayer
    private string m_inputText = "input text";
    private bool m_toggle = true;
    public Texture2D tex;
    private void _OnGUILayer() {
        float screenWidth = Screen.width;
        float screenHeight = Screen.height;
        Rect rect = new Rect(screenWidth * 0.05f, screenHeight * 0.05f, screenWidth * 0.44f, screenHeight * 0.9f);

        GUILayout.BeginArea(rect, "box");
        {
            // GUILayout.Box("box");
            // 默认垂直布局
            // 按钮
            bool isClickButton = GUILayout.Button("GUILayout.Button");
            if (isClickButton) {
                Debug.Log("click on GUILayout.Button");
            }

            // label
            GUILayout.Label("Layout Label ");


            // 指定为水平布局
            GUILayout.BeginHorizontal();
            {
                // toggle 开关
                m_toggle = GUILayout.Toggle(m_toggle, "toggle");
                // 输入文本
                m_inputText = GUILayout.TextField(m_inputText);
            }
            GUILayout.EndHorizontal();

            // scrollerbar
            GUILayout.BeginScrollView(new Vector2(0, 0));
            GUILayout.Label("Layout Label ");
            GUILayout.Label("Layout Label ");
            GUILayout.Label("Layout Label ");

            GUILayout.EndScrollView();

            // texture
            // 所有的组件都可以使用texture, 充当内容
            // UI的TextureType 需要设置成Editor GUI and Legacy GUI
            GUILayout.Label(tex, GUILayout.Width(50), GUILayout.Height(50));

            // GUIContent
            GUIContent content = new GUIContent();
            content.text = "GUIContent";
            // content.image = tex; 避免遮挡其他
            content.tooltip = "abc"; // 
            GUILayout.Label(content);

            // GUIStyle 使用Button的样式, 显示label, 具体各种样式的表现, 在GUISkin中指定
            GUILayout.Label("GUIStyle", "Button");

            // GUISkin
            // GUILayoutOption -> param 不定参数
            GUILayout.Label("option", "Button", GUILayout.Width(100), GUILayout.Height(100));
        }
        GUILayout.EndArea();
    }
}

