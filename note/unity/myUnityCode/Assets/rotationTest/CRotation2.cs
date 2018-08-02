using UnityEngine;
using System.Collections;

// rotate :
// 物体绕轴旋转 : eluarAngles : 各个轴的旋转角度, Space : 旋转角度是根据自已坐标系还是根据世界坐标系旋转
// gameObject.transform.Rotate(eluarAngles * Time.deltaTime, Space.Self);

// rotateAround
// 物体按point3为起点的axis轴, 转angle角度
// gameObject.transform.RotateAround(point3, axis, angle);

// rotation
// 指定物体的世界旋转 : 一个Quaternion值, 表示x的eular degress, y's eular degress, z's eular degress
// gameObject.transform.rotation = Quaternion.Euler(rotationV3.x, rotationV3.y, rotationV3.z); //  rotationV3;

// Quaternion 
// Eular : 
// 传入3个轴的旋转角度, 返回一个旋转4元数
// Quaternion.Euler(rotationV3.x, rotationV3.y, rotationV3.z); == 一个旋转四元数
// Quaternion.Euler(rotationV3); == 一个旋转四元数

// AngleAxis
// 返回按axis旋转angle角度的旋转四元数
// Quaternion AngleAxis(float angle, Vector3 axis)
public class CRotation2 : MonoBehaviour {

	// Use this for initialization
	void Start () {

	
	}
	
	// Update is called once per frame
	void Update () {
        Debug.DrawLine(new Vector3(0, 0, 0), new Vector3(0, 100, 0), Color.red);
        Vector3 temp = new Vector3();
        temp = rotatePointV3 + rotateAixsV3 * 100; Debug.DrawLine(rotatePointV3, temp, Color.red);

    }


    private int m_toolbarSelectIndex = 0;
    private Vector3 rotateAixsV3 = new Vector3();
    private Vector3 rotatePointV3 = new Vector3();
    private bool m_useWorld = false;
    private bool m_rotateByAxis = true;

    private Vector3 rotationV3   = new Vector3();

    private void OnGUI() {
        string[] toolbar = { "rotate", "rotation", "rotateByAxis", "quaternion"};
        m_toolbarSelectIndex = GUILayout.Toolbar(m_toolbarSelectIndex, toolbar);

        if (0 == m_toolbarSelectIndex) {
            _ratateView();
        } else if (1 == m_toolbarSelectIndex) {
            _rotationView();
        }

    }

    private void _ratateView() {
        m_rotateByAxis = GUILayout.Toggle(m_rotateByAxis, "rotate by axis");
        bool rotateByAxisAndPoint = !m_rotateByAxis;
        m_useWorld = GUILayout.Toggle(m_useWorld, "UseWorldSpace");

        GUILayout.Label("rotate axis : ");
        GUILayout.BeginHorizontal();
        {
            GUILayout.Label("x : ");
            string temp = GUILayout.TextField(rotateAixsV3.x.ToString());
            if (temp.Length == 0) {
                temp = "0";
            }
            rotateAixsV3.x = float.Parse(temp);

            GUILayout.Label("y : ");
            temp = GUILayout.TextField(rotateAixsV3.y.ToString());
            if (temp.Length == 0) {
                temp = "0";
            }
            rotateAixsV3.y = float.Parse(temp);

            GUILayout.Label("z : ");
            temp = GUILayout.TextField(rotateAixsV3.z.ToString());
            if (temp.Length == 0) {
                temp = "0";
            }
            rotateAixsV3.z = float.Parse(temp);
        }

        GUILayout.EndHorizontal();
        if (rotateByAxisAndPoint) {
            GUILayout.Label("rotate point : ");
            GUILayout.BeginHorizontal();
            {
                GUILayout.Label("x : ");
                string temp = GUILayout.TextField(rotatePointV3.x.ToString());
                if (temp.Length == 0) {
                    temp = "0";
                }
                rotatePointV3.x = float.Parse(temp);

                GUILayout.Label("y : ");
                temp = GUILayout.TextField(rotatePointV3.y.ToString());
                if (temp.Length == 0) {
                    temp = "0";
                }
                rotatePointV3.y = float.Parse(temp);

                GUILayout.Label("z : ");
                temp = GUILayout.TextField(rotatePointV3.z.ToString());
                if (temp.Length == 0) {
                    temp = "0";
                }
                rotatePointV3.z = float.Parse(temp);
            }
            
            GUILayout.EndHorizontal();

        }
        if (m_rotateByAxis) {
            if (m_useWorld) {
                gameObject.transform.Rotate(rotateAixsV3 * Time.deltaTime, Space.World);
            } else {
                gameObject.transform.Rotate(rotateAixsV3 * Time.deltaTime, Space.Self);
            }
        } else {
            gameObject.transform.RotateAround(rotatePointV3, rotateAixsV3, 10 * Time.deltaTime);
            
        }
        
    }

    private void _rotationView() {
        GUILayout.BeginHorizontal();
        {
            GUILayout.Label("x : ");
            string temp = GUILayout.TextField(rotationV3.x.ToString());
            if (temp.Length == 0) {
                temp = "0";
            }
            rotationV3.x = float.Parse(temp);

            GUILayout.Label("y : ");
            temp = GUILayout.TextField(rotationV3.y.ToString());
            if (temp.Length == 0) {
                temp = "0";
            }
            rotationV3.y = float.Parse(temp);

            GUILayout.Label("z : ");
            temp = GUILayout.TextField(rotationV3.z.ToString());
            if (temp.Length == 0) {
                temp = "0";
            }
            rotationV3.z = float.Parse(temp);
        }
        GUILayout.EndHorizontal();

        gameObject.transform.rotation = Quaternion.Euler(rotationV3);
    }
     
}
