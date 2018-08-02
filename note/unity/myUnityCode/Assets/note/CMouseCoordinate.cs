using UnityEngine;
using System.Collections;

public class CMouseCoordinate : MonoBehaviour {



	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    private Rect m_rect = new Rect();
    void OnGUI() {
        m_rect.Set(Screen.width - 110, 0, 110, 40);
        GUI.Label(m_rect, Input.mousePosition.ToString());
    }
}
