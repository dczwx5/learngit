using UnityEngine;
using System.Collections;

public class CCameraFollowRole : MonoBehaviour {
    public float distance = 4f;
    private Camera m_pCamera;
    private float m_angle_x = 0; // 摄像机按X轴旋转角度
    private float m_angle_y = 0; // 摄像机按Ｙ轴旋转角度

    // Use this for initialization
    void Start() {
        m_pCamera = GameObject.FindObjectOfType<Camera>();
    }

    // Update is called once per frame
    void Update() {
        Transform target = gameObject.transform;

        _mouseRight();
        _mouseMid();
        Camera camera = m_pCamera;
        if (null != camera) {
            Vector3 cameraMoveDir = new Vector3();
            cameraMoveDir = (-Vector3.forward + Vector3.up) * m_distanceToCamera;

            // cameraMoveDir沿Y轴旋转
            cameraMoveDir = Quaternion.AngleAxis(m_angle_y, Vector3.up) * cameraMoveDir;
            cameraMoveDir = Quaternion.AngleAxis(m_angle_x*-1, Vector3.right) * cameraMoveDir;

            camera.transform.position = target.position + cameraMoveDir;
            camera.transform.LookAt(target);
        }
    }

    private void _mouseRight() {
        // 右键
        bool isRightMouseDown = Input.GetMouseButton(1);
        if (isRightMouseDown) {
            float dragXValue = Input.GetAxis(CInputManagerController.MouseX);
            float dragYValue = Input.GetAxis(CInputManagerController.MouseY);
            m_angle_y += dragXValue;
            m_angle_x += dragYValue;

            if (m_angle_x > 45) {
                m_angle_x = 45f;
            } else if (m_angle_x < -45) {
                m_angle_x = -45;
            }
        }
    }
    private void _mouseMid() {
        // 中键
        bool isMouseMidDown = Input.GetMouseButtonDown(2);
        if (isMouseMidDown && m_pCamera) {
            float mouseWheelValue = Input.GetAxis(CInputManagerController.MouseScrollWheel);
            m_distanceToCamera -= mouseWheelValue;
        }
    }
    private float m_distanceToCamera = 4.0f;

     
}

