using UnityEngine;
using System.Collections;

public class CSkyBox : MonoBehaviour {

	// Use this for initialization
	void Start () {
        
    }
	
	// Update is called once per frame
	void Update () {
        
	}
    private void OnGUI() {
        if (GUILayout.Button("addSkyBox")) {
            addSkyBox();
        }
        if (GUILayout.Button("removeSkyBox")) {
            removeSkyBox();
        }
    }

    private Object m_prefab;
    public void addSkyBox() {
        Camera pCamera = GameObject.FindObjectOfType<Camera>();
        if (null ==  pCamera.gameObject.GetComponent<Skybox>()) {
            // 创建。添加SkyBox组件
            Skybox skybox = pCamera.gameObject.AddComponent<Skybox>();
            if (null == m_prefab) {
                m_prefab = Resources.Load("skybox/sky02");
            }
            Material pMaterial = (Material)Instantiate(m_prefab);
            // 设置skybox
            skybox.material = pMaterial;
        }
        
    }
    public void removeSkyBox() {
        Camera pCamera = GameObject.FindObjectOfType<Camera>();
        Skybox pSkyBox = pCamera.gameObject.GetComponent<Skybox>();
        if (null != pSkyBox) {
            Material mat = pSkyBox.material;
            pSkyBox.material = null;
            Destroy(mat);
            // 删除天空盒
            Destroy(pSkyBox);
        }
    }
}
