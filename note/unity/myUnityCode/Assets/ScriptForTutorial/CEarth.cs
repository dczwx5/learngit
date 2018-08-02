using UnityEngine;
using System.Collections;

public class CEarth : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        // Quaternion earthRotation = gameObject.transform.rotation;
        Vector3 vAxisYEnd = gameObject.transform.position + (gameObject.transform.up) * 10;
        Vector3 vAxisYStart = gameObject.transform.position + (- gameObject.transform.up) * 10;
        Debug.DrawLine(vAxisYStart, vAxisYEnd, Color.red);

        // 自转
        gameObject.transform.Rotate(Vector3.up, 10 * Time.deltaTime);

        // 引力
        SphereCollider[] childrenList = gameObject.GetComponentsInChildren<SphereCollider>();
        Debug.Log(childrenList.Length);
        foreach (SphereCollider children in childrenList) {
            if (children != gameObject) {
                Rigidbody rigi = children.gameObject.GetComponent<Rigidbody>();
                Vector3 vTorque = (gameObject.transform.position - children.transform.position);
                rigi.AddTorque(vTorque);
            }
        }
    }
}
