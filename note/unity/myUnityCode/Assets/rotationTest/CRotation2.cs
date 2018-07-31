using UnityEngine;
using System.Collections;

public class CRotation2 : MonoBehaviour {

    // Use this for initialization
    private GameObject axisObject;
    private float m_angleY = 1;
    void Start () {
        axisObject = GameObject.Find("axisObject2");

    }
	
	// Update is called once per frame
	void Update () {


        Vector3 axisY = new Vector3(axisObject.transform.position.x, axisObject.transform.position.y + axisObject.transform.localScale.y, axisObject.transform.position.z);
        Debug.DrawLine(gameObject.transform.position, axisObject.transform.position, Color.green);
        Debug.DrawLine(gameObject.transform.position, new Vector3(axisObject.transform.position.x, gameObject.transform.position.y, axisObject.transform.position.z), Color.green);
        gameObject.transform.position = Quaternion.AngleAxis(m_angleY, axisY) * gameObject.transform.position;
        m_angleY = Time.deltaTime * 50;




    }
}
