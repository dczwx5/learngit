using FairyGUI;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CAddByNormal : MonoBehaviour {

    // Use this for initialization
    private UIPanel m_uiPanel;
    private GComponent m_ui;

	void Start () {
        m_uiPanel = GetComponentInParent<UIPanel>();
        
        
	}

    public void show() {
        if (null == m_ui) {
            m_ui = UIPackage.CreateObject("Test2", "Test2_OpenByClick") as GComponent;
        }
        m_uiPanel.container.AddChildAt(m_ui.displayObject, 0);
    }
    public void hide() {
        if (null == m_ui || null == m_uiPanel || m_ui.displayObject.parent == null)
            return;

        m_uiPanel.container.RemoveChild(m_ui.displayObject);
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
