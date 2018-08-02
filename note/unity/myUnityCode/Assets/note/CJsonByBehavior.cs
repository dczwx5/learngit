using UnityEngine;
using System.Collections;
using System.IO;
using System;

public class CJsonByBehavior : MonoBehaviour {

    // Use this for initialization
    public int value1;
    public string value2;
    void Start() {
        _load();
    }

    void OnGUI() {
        if (GUILayout.Button("save")) {
            _save();
        }
        if (GUILayout.Button("load")) {
            _load();
        }
    }

    private void _save() {
        string content = JsonUtility.ToJson(this);
        string path = Path.Combine(Application.persistentDataPath, "testSaveJsonByBehavior");
        CFile.WriteFile(path, content, false);
    }
    private void _load() {
        string path = Path.Combine(Application.persistentDataPath, "testSaveJsonByBehavior");
        if (File.Exists(path)) {
            string content = CFile.ReadFile(path);
            JsonUtility.FromJsonOverwrite(content, this); // behaviour不能使用FromJson
        }
    }
    

}
