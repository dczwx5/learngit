using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FairyGUI;
using TestBag;

public class CBagWindow : MonoBehaviour {

    // Use this for initialization
    void Start() {
        m_panel = gameObject.GetComponent<UIPanel>();
        Debug.Log(m_panel.name);
        m_bagView = (UI_Bag_BagWin)m_panel.ui;
        m_bagView.Center();

        m_bagView.m_frame.m_closeButton.onClick.Add(_OnClose);

    }

    // Update is called once per frame
    void Update() {

    }

    private void _OnClose(EventContext context) {
        m_bagView.RemoveFromParent();
    }

    private UIPanel m_panel;
    private UI_Bag_BagWin m_bagView;
}
