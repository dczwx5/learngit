using UnityEngine;

using System.Collections;

// 下面三个函数用于获得鼠标按键状态 0 : 左键, 1右键, 2中键

// GetMouseButtonUp鼠标按下松开

// GetMouseButtonDown鼠标按下

// GetMouseButton鼠标持续按下, 只按一次也会触发

// 

// Input.GetAxis(Horizontal) 获得各键的值, 偏移量

public class CCameraManager : MonoBehaviour {





    public const string Horizontal = "Horizontal";

    public const string Vertical = "Vertical";

    public const string Fire1 = "Fire1";

    public const string Fire2 = "Fire2";

    public const string Fire3 = "Fire3";

    public const string Jump = "Jump";

    public const string MouseX = "Mouse X";

    public const string MouseY = "Mouse Y";

    public const string MouseScrollWheel = "Mouse ScrollWheel";



    private float m_distanceToCamera = 4.0f;

    private float m_angle_y = 0; // 摄像机按Ｙ轴旋转角度

    public float MoveStep = 0.1f;



    // Use this for initialization

    void Start() {



    }



    // Update is called once per frame

    // Gravity : -1 or 1 回到0的效率

    // Sensitivity : 0 到 -1 or 1的效率 

    // 3 : 是0.35秒完成

    // 100 是马上完成

    // 10 : 0.11秒完成

    void Update() {

        _ASWD();

        _mouseLeft();

        _mouseRight();

        _mouseMid();


        // show other

        m_mouseMoveX = Input.GetAxis(MouseX); // 左移负，　右移正

        m_mouseMoveY = Input.GetAxis(MouseY); // 上移正, 下移负

        m_mouseX = Input.mousePosition.x;

        m_mouseY = Input.mousePosition.y;

    }



    private void _ASWD() {

        Transform pTran = transform;



        // 键盘上下左右控制

        float horizontalValue = Input.GetAxis(Horizontal);

        if (horizontalValue > 0) {

            // 向右 d

            pTran.position = pTran.position + pTran.right * horizontalValue * MoveStep;

        } else if (horizontalValue < 0) {

            // 向左 a

            pTran.position = pTran.position + pTran.right * horizontalValue * MoveStep;



        }

        float verticalValue = Input.GetAxis(Vertical);

        if (verticalValue > 0) {

            // 向上 w

            pTran.position = pTran.position + pTran.forward * verticalValue * MoveStep;

        } else if (verticalValue < 0) {

            // 向下 s

            pTran.position = pTran.position + pTran.forward * verticalValue * MoveStep;



        }

    }



    private void _mouseLeft() {

        Transform pTran = transform;



        // 鼠标按键

        // 左键

        m_isLeftMouseButtonDown = Input.GetMouseButtonDown(0);

        if (m_isLeftMouseButtonDown) {

            m_isDraging = true;

        }

        m_isLeftMouseButtonUp = Input.GetMouseButtonUp(0);

        if (m_isLeftMouseButtonUp) {

            m_isDraging = false;

        }

        if (m_isDraging) {

            bool isMouseDowning = Input.GetMouseButton(0);
            if (!isMouseDowning) {
                m_isDraging = false;
                return;
            } else {
                float dragXValue = Input.GetAxis(MouseX);

                float dragYValue = Input.GetAxis(MouseY);

                if (dragXValue != 0) {

                    pTran.position = pTran.position + pTran.right * dragXValue * MoveStep;

                }

                if (dragYValue != 0) {

                    pTran.position = pTran.position + pTran.forward * dragYValue * MoveStep;

                }
            }
        }

    }

    private void _mouseRight() {

        // 右键
        bool isRightMouseDown = Input.GetMouseButton(1);

        if (isRightMouseDown) {
            float dragXValue = Input.GetAxis(MouseX);
            // float dragYValue = Input.GetAxis(MouseY);
            m_angle_y += dragXValue;
        }
    }

    private void _mouseMid() {
        // 中键

        bool isMouseMidDown = Input.GetMouseButtonDown(2);
        if (isMouseMidDown) {
            float mouseWheelValue = Input.GetAxis(MouseScrollWheel);
            m_distanceToCamera -= mouseWheelValue;
        }
    }




    private float m_mouseMoveX; // 鼠标Ｘ移动量
    private float m_mouseMoveY;
    private float m_mouseX; // 鼠标Ｘ
    private float m_mouseY;

    private bool m_isLeftMouseButtonDown;
    private bool m_isLeftMouseButtonUp;
    private bool m_isDraging;

    void OnGUI() {

      

    }





}