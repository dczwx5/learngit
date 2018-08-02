using UnityEngine;
using System.Collections;

public class RayCast_SengMessage_children : MonoBehaviour {

    // Use this for initialization
    private Camera m_pCamera;
    void Start() {

    }

    // Update is called once per frame
    void Update() {
        

    }
    public void OnMessageFromChildren() {
        Rigidbody rigi = GetComponent<Rigidbody>();
        rigi.AddForce(Vector3.up * 300);
        Debug.Log("OnMessageFromChildren : " + gameObject.name);
    }
    public void OnSelfMessage() {
        Rigidbody rigi = GetComponent<Rigidbody>();
        rigi.AddForce(Vector3.up * 300);
        Debug.Log("OnSelfMessage : " + gameObject.name);
    }
    public void OnSelf_N_ChildrenMessage() {
        Rigidbody rigi = GetComponent<Rigidbody>();
        rigi.AddForce(Vector3.up * 300);
        Debug.Log("OnSelf_N_ChildrenMessage : " + gameObject.name);

    }
}
