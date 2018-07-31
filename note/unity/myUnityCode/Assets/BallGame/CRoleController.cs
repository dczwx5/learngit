using UnityEngine;
using System.Collections;
// 下面三个函数用于获得鼠标按键状态 0 : 左键, 1右键, 2中键
// GetMouseButtonUp鼠标按下松开
// GetMouseButtonDown鼠标按下
// GetMouseButton鼠标持续按下, 只按一次也会触发
// 
// Input.GetAxis(Horizontal) 获得各键的值, 偏移量
public class CRoleController : MonoBehaviour {


    public const string Horizontal = "Horizontal";
    public const string Vertical = "Vertical";
    public const string Fire1 = "Fire1";
    public const string Fire2 = "Fire2";
    public const string Fire3 = "Fire3";
    public const string Jump = "Jump";
    public const string MouseX = "Mouse X";
    public const string MouseY = "Mouse Y";
    public const string MouseScrollWheel = "Mouse ScrollWheel";

    public float MoveStep = 100f;
    public float jumpPower = 300f;
    private Vector3 m_moveDir;
    private Camera m_pCamare;

    private Rigidbody m_rigibody;
    private bool m_isJump = false;
    // Use this for initialization
    void Start() {
        m_moveDir = new Vector3();
        m_pCamare = GameObject.FindObjectOfType<Camera>();
        m_rigibody = gameObject.GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    // Gravity : -1 or 1 回到0的效率
    // Sensitivity : 0 到 -1 or 1的效率 
    // 3 : 是0.35秒完成
    // 100 是马上完成
    // 10 : 0.11秒完成
    void Update() {

        _ASWD();

        if (Input.GetAxis(Jump) != 0) {
            if (!m_isJump) {
                m_isJump = true;
                if (m_rigibody) {
                    m_rigibody.AddForce(Vector3.up * jumpPower);
                }
            }
        }

        // u/i/o/space
        m_isFire1 = Input.GetAxis(Fire1) != 0;
        m_isFire2 = Input.GetAxis(Fire2) != 0;
        m_isFire3 = Input.GetAxis(Fire3) != 0;
    }

    private void _ASWD() {

        Transform pTran = gameObject.transform;
        float movePower = MoveStep;
        if (m_isJump) {
            movePower /= 5;
        }

        // 键盘上下左右控制
         m_moveDir.Set(0f, 0f, 0f);
        bool isMove = false;
        float horizontalValue = Input.GetAxis(Horizontal);
        if (horizontalValue != 0) {
            m_moveDir += m_pCamare.transform.right * horizontalValue * movePower;
            isMove = true;
        }
        float verticalValue = Input.GetAxis(Vertical);
        if (verticalValue != 0) {
            isMove = true;
            m_moveDir += m_pCamare.transform.forward * verticalValue * movePower;
        }
        if (isMove) {
            // pTran.position = pTran.position + m_moveDir;
            m_rigibody.AddForce(m_moveDir);
            // pTran.Rotate(m_moveDir*30);
        }

        
    }
    private void OnCollisionStay(Collision collision) {
        m_isJump = false;
    }

    private bool m_isFire1;
    private bool m_isFire2;
    private bool m_isFire3;
   
    
}
