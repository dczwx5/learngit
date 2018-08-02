using UnityEngine;
using System.Collections;

public class CPhysicEvent : MonoBehaviour {

    string _GetLogOtherContent(GameObject other) {
        return "   " + other.name + " -> " + other.transform.position.x + ", " + other.transform.position.y;
    }

    /*====================================trigger只会触发这部分事件(进入trigger的物体也会触发)======================================================*/
    // 触发器与进入触发器的物体, 都可以使用此事件
    // 激活了触发器选项的物体, 不再有碰撞功能
    // 进入触发器时触发
    void OnTriggerEnter(Collider other) {
        Debug.Log("OnTriggerEnter : " + _GetLogOtherContent(other.gameObject));
    }
    // 在触发器内时触发
    void OnTriggerStay(Collider other) {
        Debug.Log("OnTriggerStay" + _GetLogOtherContent(other.gameObject));

    }
    // 离开触发器触发
    void OnTriggerExit(Collider other) {
        Debug.Log("OnTriggerExit" + _GetLogOtherContent(other.gameObject));
    }

    
    /*==========================================================================================*/

    /******************************************发生碰撞时触发*********************************************/
    void OnCollisionEnter(Collision collision) {
        Debug.Log("OnCollisionEnter" + _GetLogOtherContent(collision.gameObject));

    }

    void OnCollisionExit(Collision collision) {
        Debug.Log("OnCollisionExit" + _GetLogOtherContent(collision.gameObject));

    }
    void OnCollisionStay(Collision collision) {
        Debug.Log("OnCollisionStay" + _GetLogOtherContent(collision.gameObject));

    }
    void OnControllerColliderHit(ControllerColliderHit hit) {
        Debug.Log("OnControllerColliderHit" + _GetLogOtherContent(hit.gameObject));

    }
}
