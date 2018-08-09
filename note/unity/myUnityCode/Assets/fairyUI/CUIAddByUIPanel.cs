using FairyGUI;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CUIAddByUIPanel : MonoBehaviour {

    // Use this for initialization
    private UIPanel m_uiPanel;
    void Start() {
        m_uiPanel = GetComponent<UIPanel>();
        m_ui = m_uiPanel.ui;

        m_btnOk = m_ui.GetChild("btn_ok") as GButton;
        m_btnCancel = m_ui.GetChild("btn_cancel") as GButton;
        m_txt = m_ui.GetChild("txt") as GTextField;

        m_btnShowAutoCodeUI = m_ui.GetChild("btn_show_auto_code_ui") as GButton;
        m_btnHideAutoCodeUI = m_ui.GetChild("btn_hide_auto_code_ui") as GButton;

        m_btnOk.onClick.Add(_OnOkClickHandler);
        m_btnCancel.onClick.Add(_OnCancleClickHandler);

        m_btnShowAutoCodeUI.onClick.Add(_onShowAutoCodeUIClickHandler);
        m_btnHideAutoCodeUI.onClick.Add(_onHideAutoCodeUIClickHandler);
    }

    private void _OnOkClickHandler(EventContext contex) {
        m_txt.text = m_btnOk.title;

        CAddByNormal view = GetComponentInChildren<CAddByNormal>();
        view.show();
    }
    private void _OnCancleClickHandler(EventContext contex) {
        m_txt.text = m_btnCancel.title;

        CAddByNormal view = GetComponentInChildren<CAddByNormal>();
        view.hide();
    }

    private void _onShowAutoCodeUIClickHandler(EventContext contex) {
        m_txt.text = m_btnShowAutoCodeUI.title;

        CAddByAutoCode view = GetComponentInChildren<CAddByAutoCode>();
        view.show();
    }
    private void _onHideAutoCodeUIClickHandler(EventContext contex) {
        m_txt.text = m_btnHideAutoCodeUI.title;

        CAddByAutoCode view = GetComponentInChildren<CAddByAutoCode>();
        view.hide();
    }
    private GComponent m_ui;
    private GButton m_btnOk;
    private GButton m_btnCancel;
    private GTextField m_txt;

    private GButton m_btnShowAutoCodeUI;
    private GButton m_btnHideAutoCodeUI;
	
	// Update is called once per frame
	void Update () {
		
	}
}
