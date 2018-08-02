using UnityEngine;
using System.Collections;

public class CInputManagerController : MonoBehaviour {
    public static string MouseScrollWheel = "Mouse ScrollWheel";
    public static string MouseX = "Mouse X";
    public static string MouseY = "Mouse Y";

    // Use this for initialization
    void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        float horizontalValue = Input.GetAxis("Horizontal");
        //if (horizontalValue != 0) {
            Debug.Log("horizontalValue " + horizontalValue + ", time : " + Time.time);
            // Gravity : -1 or 1 回到0的效率
            // Sensitivity : 0 到 -1 or 1的效率 
            // 3 : 是0.35秒完成
            // 100 是马上完成
            // 10 : 0.11秒完成
       // }

    }

    
}
