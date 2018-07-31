using UnityEngine;
using System.Collections;

public class CMonoBehaviourEvent : MonoBehaviour {
    // 第一次的顺序 awake->enable->start->fixupdate->update->laterUpdate
    // 其中enable可能会被调多次, fixupdate的调用频率与update调用频率不同

    //  不会调
    private void Reset() {
        Debug.Log("Reset");
    }
    // gameObject激活时调
    private void Awake() {
        Debug.Log("Awake");

    }

    // 脚本所在的gameObject或脚本本身, set为enbale, 或激活时调用
    private void OnEnable() {
        Debug.Log("OnEnable");
    }
    // Use this for initialization

    // Use this for initialization
    void Start () {
        Debug.Log("Start");

    }

    private void FixedUpdate() {
        Debug.Log("FixedUpdate");

    }
    // Update is called once per frame
    void Update () {
        Debug.Log("Update");

    }
    private void LateUpdate() {
        Debug.Log("LateUpdate");

    }
    // 脚本所在的gameObject或脚本本身, set为disable, 或设直非激活时调用
    private void OnDisable() {
        Debug.Log("onDisable");
    }
}
