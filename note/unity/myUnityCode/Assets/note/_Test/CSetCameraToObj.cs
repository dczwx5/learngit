using UnityEngine;
using System.Collections;

public class CSetCameraToObj : MonoBehaviour {

    public Transform target;
    public Camera pCamera;
    //public bool useForwar = true;
    // Use this for initialization
    void Start() {
        /**Transform[] transList = gameObject.GetComponentsInChildren<Transform>();
        foreach (Transform tran in transList) {
            if (tran.name == "Cube") {
                targetTransform = tran;
                break;
            }
        }*/

        pCamera = GameObject.FindObjectOfType<Camera>();
    }

    // Update is called once per frame
    void Update() {
        if (null != target) {
            Camera camera = GameObject.FindObjectOfType<Camera>();
            if (null != camera) {
                Vector3 cameraMoveDir = new Vector3();
                //if (useForwar) {
                    cameraMoveDir = (-target.transform.forward + target.transform.up) * 2;
                //} else {
                 //   cameraMoveDir = (-target.transform.forward + target.transform.up) * 2 ;
               // }
                camera.transform.position = new Vector3(target.position.x + cameraMoveDir.x, target.position.y + cameraMoveDir.y, target.position.z + cameraMoveDir.z);
                camera.transform.LookAt(target);
            }
        }
    }

     
}
 
