using UnityEngine;
using System.Collections;

public class CRotation : MonoBehaviour {

    // Use this for initialization
    private GameObject axisObject;
    private float m_angleY = 1;
    void Start () {
        axisObject = GameObject.Find("axisObject");

    }
	
	// Update is called once per frame
	void Update () {


        Vector3 axisY = new Vector3(axisObject.transform.position.x, axisObject.transform.position.y, axisObject.transform.position.z);
       // axisY = Quaternion.Euler(axisObject.transform.rotation.x, axisObject.transform.rotation.y, axisObject.transform.rotation.z) * axisY;
        Debug.DrawLine(gameObject.transform.position, Vector3.zero, Color.green);
        Debug.DrawLine(gameObject.transform.position, new Vector3(0, gameObject.transform.position.y, 0), Color.green);
        gameObject.transform.position = Quaternion.AngleAxis(m_angleY, axisY) * gameObject.transform.position;
        m_angleY = Time.deltaTime * 50;




    }
}
