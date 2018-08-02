using UnityEngine;
using System.Collections;

public class CInputController : MonoBehaviour {

    // Use this for initialization
    public Transform target;
    public float moveSpeed = 1.0f;
    private Vector3 m_moveDir;

    public float jumpPower = 2.0f;
    private bool m_isJump = false;
    private Rigidbody m_rigibody;
    void Start () {
        m_moveDir = new Vector3();
        OnValidate();
    }
	
	// Update is called once per frame
	void Update () {
       
        if (target) {
            float moveStep = moveSpeed * Time.deltaTime;
            if (Input.GetKey(KeyCode.W)) {
                m_moveDir = target.forward * moveStep;
                target.position = new Vector3(target.position.x + m_moveDir.x, target.position.y + m_moveDir.y, target.position.z + m_moveDir.z) ;
            }
            if (Input.GetKey(KeyCode.S)) {
                m_moveDir = -target.forward * moveStep;
                target.position = new Vector3(target.position.x + m_moveDir.x, target.position.y + m_moveDir.y, target.position.z + m_moveDir.z);
            }
            if (Input.GetKey(KeyCode.A)) {
                m_moveDir = -target.right * moveStep;
                target.position = new Vector3(target.position.x + m_moveDir.x, target.position.y + m_moveDir.y, target.position.z + m_moveDir.z);
            }
            if (Input.GetKey(KeyCode.D)) {
                m_moveDir = target.right * moveStep;
                target.position = new Vector3(target.position.x + m_moveDir.x, target.position.y + m_moveDir.y, target.position.z + m_moveDir.z);
            }
            if (Input.GetKeyDown(KeyCode.Space)) {
                if (!m_isJump) {
                    m_isJump = true;
                   if (m_rigibody) {
                        m_rigibody.AddForce(target.transform.up * jumpPower);
                    }
                }
            }
        }
       
    }

    private void OnCollisionEnter(Collision collision) {
        m_isJump = false;
    }

    private void OnValidate() {
        if (target) {
            m_rigibody = target.GetComponent<Rigidbody>();
        } else {
            m_rigibody = null;
        }

    }

}
