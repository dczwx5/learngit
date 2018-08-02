using UnityEngine;
using System.Collections;

public class MaterialPlane : MonoBehaviour {

    private GameObject m_mainCamera;
    private GameObject m_pointLight;
    private GameObject m_DiffusePlane;
    private GameObject m_DiffuseNormalPlane;
    private GameObject m_DiffuseSpecularPlane;
    private GameObject m_diffuseOtherColorPlane;

    public bool showDiffusePlane = true;
    public bool showDiffuseNormalPlane = true;
    public bool showDiffuseSpecularPlane = true;
    public bool showDiffuseOhterColorPlane = true;
    // Use this for initialization
    void Start() {
        //m_mainCamera = GameObject.Find("MainCamera");
       // m_pointLight = GameObject.Find("PointLight");
        m_DiffusePlane = GameObject.Find("DiffusePlane");
        m_DiffuseNormalPlane = GameObject.Find("DiffuseNormalPlane");
        m_DiffuseSpecularPlane = GameObject.Find("DiffuseSpecularPlane");
        m_diffuseOtherColorPlane = GameObject.Find("DiffuseOhterColorPlane");

    }

    // Update is called once per frame
    void Update() {
        
    }

    void OnValidate() { 
        if (m_DiffusePlane) {
            m_DiffusePlane.SetActive(showDiffusePlane);
        }
        if (m_DiffuseNormalPlane) {
            m_DiffuseNormalPlane.SetActive(showDiffuseNormalPlane);
        }
        if (m_DiffuseSpecularPlane) {
            m_DiffuseSpecularPlane.SetActive(showDiffuseSpecularPlane);
        }
        if (m_diffuseOtherColorPlane) {
            m_diffuseOtherColorPlane.SetActive(showDiffuseOhterColorPlane);
        }

    /**GameObject tempObj = GameObject.Find("DiffusePlane");
    if (showDiffusePlane) {
        if (!tempObj) {
        }
    } else {
        if (tempObj) {
            GameObject.DestroyObject(tempObj);
        }
    }*/
}
}
