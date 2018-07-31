using UnityEngine;
using System.Collections;

public class CSetCameraToObj : MonoBehaviour {
    public float distance = 4f;
    public Transform target;
    private Camera m_pCamera;
    private float m_angle_y = 0; // 摄像机按Ｙ轴旋转角度
                                 
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

        m_pCamera = GameObject.FindObjectOfType<Camera>();
    }

    // Update is called once per frame
    void Update() {
        if (null == target) return;

        _mouseRight();
        _mouseMid();
        Camera camera = m_pCamera;
        if (null != camera) {
            Vector3 cameraMoveDir = new Vector3();
            cameraMoveDir = (-Vector3.forward + Vector3.up) * m_distanceToCamera;

            // cameraMoveDir沿Y轴旋转
            cameraMoveDir = Quaternion.AngleAxis(m_angle_y, Vector3.up) * cameraMoveDir;

            camera.transform.position = target.position + cameraMoveDir;
            camera.transform.LookAt(target);
        }
    }

    private void _mouseRight() {
        Transform pTran = target.transform;

        // 右键
        bool isRightMouseDown = Input.GetMouseButton(1);
        if (isRightMouseDown) {
            float dragXValue = Input.GetAxis(CInputManagerController.MouseX);
            // float dragYValue = Input.GetAxis(MouseY);
            m_angle_y += dragXValue;
        }
    }
    private void _mouseMid() {
        Transform pTran = target.transform;

        // 中键
        bool isMouseMidDown = Input.GetMouseButtonDown(2);
        if (m_pCamera) {
            float mouseWheelValue = Input.GetAxis(CInputManagerController.MouseScrollWheel);
            m_distanceToCamera -= mouseWheelValue;
        }
    }
    private float m_distanceToCamera = 4.0f;


}

