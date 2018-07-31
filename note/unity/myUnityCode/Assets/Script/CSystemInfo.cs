using UnityEngine;
using System.Collections;

public class CSystemInfo : MonoBehaviour {
    public bool IsShowInfo = true;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    void OnGUI() {
        if (IsShowInfo) {
            GUILayout.Label("time : " + Time.time);
            GUILayout.Label("deltaTime : " + Time.deltaTime);
            
        }
        
        // GUILayout.Label("allTime : " + Time.fixedTime); same as time

    }
}
