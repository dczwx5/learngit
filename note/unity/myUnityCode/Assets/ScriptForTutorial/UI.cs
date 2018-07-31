using UnityEngine;
using System.Collections;

public class UI : MonoBehaviour {

	// Use this for initialization
	void Start () {
        // 资源目录必须在Resources下
        m_2dTex = Resources.Load<Texture2D>("texture/a"); // 不需要加后缀
        m_2dTexList = Resources.LoadAll("texture"); // 加载整个目录 
    }
	
	// Update is called once per frame
	void Update () {
	
	}

    private Texture2D m_2dTex;
    private Object[] m_2dTexList;
    private void OnGUI() {
        // 创建一个按钮
        if (GUI.Button(new Rect(0, 100, 100, 60), "OnClick")) {
            // 点击按钮回调
            Debug.LogWarning("onClick");
        }

        
        if (m_2dTex) {
            GUI.DrawTexture(new Rect(120, 100, 120, 120), m_2dTex, ScaleMode.StretchToFill, true, 0);
        }
        if (m_2dTexList != null) {
            for (int i = 0; i < m_2dTexList.Length; i++) {
                Texture2D tex = (Texture2D)(m_2dTexList[i]);
                GUI.DrawTexture(new Rect(130*i, 300, 120, 120), tex, ScaleMode.StretchToFill, true, 0);
            }
        }
    }
}
