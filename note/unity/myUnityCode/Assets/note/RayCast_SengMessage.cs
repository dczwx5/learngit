using UnityEngine;
using System.Collections;

public class RayCast_SengMessage : MonoBehaviour {

    // Use this for initialization
    private Camera m_pCamera;
    void Start() {
        m_pCamera = GameObject.FindObjectOfType<Camera>();

    }

    // Update is called once per frame
    void Update() {
        if (Input.GetMouseButtonUp(0)) {
            // 按下了左键
            Ray ray = m_pCamera.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            bool isHit = Physics.Raycast(ray, out hit, 1000);
            if (isHit) {
                GameObject selectObj = hit.collider.gameObject;
                if (selectObj.name != "Plane") {
                    if (selectObj == gameObject) {
                        // SendMessage : 发消息给自己
                        selectObj.SendMessage("OnSelfMessage");
                        // BroadcastMessage : 发消息给自己和所有children
                        selectObj.BroadcastMessage("OnSelf_N_ChildrenMessage");
                    } else {
                        // SendMessageUpwards : 发消息给自己和所有parent
                        selectObj.SendMessageUpwards("OnMessageFromChildren");

                    }
                }

            }
        }

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
