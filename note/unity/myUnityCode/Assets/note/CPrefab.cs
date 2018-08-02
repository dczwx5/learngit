using UnityEngine;
using System.Collections;

public class CPrefab : MonoBehaviour {

	// Use this for initialization
	void Start () {
	    
	}

    void OnGUI() {
        if (GUILayout.Button("addGameObject")) {
            _addGameObjectPrefab();
        }
        if (GUILayout.Button("removeGameObject")) {
            _removeGameObjectPrefab();
        }
        if (GUILayout.Button("releaseResource")) {
            _onReleaseResource();
        }
    }

    // Material by Prefab
    private Object m_material_prefab;
    private void _addMaterialPrefab() {
        if (m_material_prefab == null) {
            string path = "Material/diffuseOhterColor";
            m_material_prefab = Resources.Load(path);
        }
        Material material = (Material)Instantiate(m_material_prefab);
        if (material) {

        }
       // tomoll
    }
    // GameObject by Prefab
    private Object m_prefab_gameobject;
    private void _addGameObjectPrefab() {
        if (null == m_prefab_gameobject) {
            // 加载prefab对象, prefab不存有资源内存, 占用内存小, 不需要删除
            string path = "prefab/Cube";
            m_prefab_gameobject = Resources.Load(path);
        }
        // 实例化. 如果是第一次, 则会加载资源到内存, 耗时高
        GameObject gameObj = (GameObject)Instantiate(m_prefab_gameobject);
        float x = Random.Range(-5, 5);
        float y = Random.Range(-5, 5);
        float z = Random.Range(-5, 5);
        Vector3 pos = new Vector3(x, y, z);
        gameObj.transform.position = pos;

        gameObj.transform.parent = gameObject.transform;  
    }

    private void _removeGameObjectPrefab() {
        if (gameObject.transform.childCount > 0) {
            Transform children = gameObject.transform.GetChild(0);
            Destroy(children.gameObject);

        }
    }
    private void _onReleaseResource() {
        // 1 prefab 没引用
        // 实例全被destory, 没引用
        m_prefab_gameobject = null;
        // 满足上面2个条件才可以删除所有资源内存
        Resources.UnloadUnusedAssets(); 
    }

    // Update is called once per frame
    void Update () {
	    
	}
}
