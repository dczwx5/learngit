using UnityEngine;
using System.Collections;

public class ReleaseObject : MonoBehaviour {

    // Use this for initialization
    private GameObject m_cube;
    void Start() {
        m_cube = gameObject.transform.GetChild(0).gameObject;

    }

    // Update is called once per frame
    void Update() {

    }

    void OnGUI() {
        GUILayout.BeginHorizontal();

        if (GUILayout.Button("CreateMaterial")) {
            _CreateMaterial();
        }
        if (GUILayout.Button("ReleaseMaterial")) {
            _ReleaseMaterial();
        }

        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();

        if (GUILayout.Button("CreateGameObject")) {
            _CreateGameObject();
        }
        if (GUILayout.Button("ReleaseGameObject")) {
            _ReleaseGameObject();
        }
        

        GUILayout.EndHorizontal();

        if (GUILayout.Button("ReleaseMemery")) {
            _ReleaseMemery();
        }
    }

    // 加载资源
    private void _CreateMaterial() {
        if (!m_prefabMaterial) {
            m_prefabMaterial = Resources.Load("Material/diffuseOhterColor");
        }
        // 每Instanceiate一次, 会加载一次材质资源, 内存会越来越大. 因此, material 等资源不可以用这种方式来加载. 
        // 这种方式不能达到资源只有一份, 浪费内存
        Material mat = (Material)Instantiate(m_prefabMaterial);
        MeshRenderer meshRender = m_cube.GetComponent<MeshRenderer>();
        meshRender.material = mat;

    }
    private void _ReleaseMaterial() {
        MeshRenderer meshRender = m_cube.GetComponent<MeshRenderer>();
        if (meshRender.material) {
            Material mat = meshRender.material;
            meshRender.material = null;
            // 释放资源. 但是不会被释放. 只有在没有任何其他该资源的引用,
            // 且调用了UnloadUnusedAssets才会释放内存
            GameObject.Destroy(mat);

        }

    }

    private void _CreateGameObject() {
        if (!m_prefabGameObject) {
            m_prefabGameObject = Resources.Load("Prefab/Sphere");
        }
        // 对于gameobject(非资源)对象, 实例化, 可达到共用一份资源, 
        GameObject obj = (GameObject)Instantiate(m_prefabGameObject);
        Vector3 vPos = new Vector3(Random.Range(-5, 5), Random.Range(-5, 5), Random.Range(-5, 5));
        obj.transform.parent = gameObject.transform;
        obj.transform.position = vPos;
    }
    private void _ReleaseGameObject() {
        // 第一个方块是用于测试material的
        if (gameObject.transform.childCount > 1) {
            Transform tran = gameObject.transform.GetChild(1);
            // 释放引用.释放gameobject
            // 如果要删除prefab的资源内存. 
            // 1.所有的实例都destory且没引用 
            // 2.prefab没引用
            // 3.调用UnloadUnusedAssets
            GameObject.Destroy(tran.gameObject);
        }
    }
    private void _ReleaseMemery() {
        if (gameObject.transform.childCount == 1) {
            m_prefabGameObject = null;
        }
        MeshRenderer meshRender = m_cube.GetComponent<MeshRenderer>();
        if (null == meshRender.material) {
            m_prefabMaterial = null;
        }
        // 释放所有没有引用的资源内存
        Resources.UnloadUnusedAssets();

    }

    private Object m_prefabGameObject;
    private Object m_prefabMaterial;
}
