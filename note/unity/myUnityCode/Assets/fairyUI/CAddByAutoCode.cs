using FairyGUI;
using System.Collections;
using System.Collections.Generic;
using Test3;
using UnityEngine;

public class CAddByAutoCode : MonoBehaviour {

    private UIPanel m_uiPanel;
    private UI_Test3_View m_ui;

	// Use this for initialization
	void Start () {
	    	
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    public void show() {
        if (null == m_uiPanel) {
            m_uiPanel = GetComponentInParent<UIPanel>();
        }
        if (m_ui == null) {
            string packagePath = "Test2/Test3";
            string packageName = "Test3";
            if (!string.IsNullOrEmpty(packagePath) && UIPackage.GetByName(packageName) == null) {
                UIPackage.AddPackage(packagePath);
            }
            Test3Binder.BindAll();
            m_ui = UI_Test3_View.CreateInstance();

            m_ui.m_btn.onClick.Add(_OnBtnClickHandler);
        }
        m_uiPanel.container.AddChildAt(m_ui.displayObject, 0);
    }

    public void hide() {
        if (null == m_ui || null == m_uiPanel || m_ui.displayObject.parent == null)
            return;

        m_uiPanel.container.RemoveChild(m_ui.displayObject);

    }

    private void _OnBtnClickHandler(EventContext e) {
        hide();
    }


}
