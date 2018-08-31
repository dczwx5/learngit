using Core;
using GameFramework.DataTable;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;

public class CSceneSystem : CAppSystem {

	// Use this for initialization
	void Start () {
        DataTableComponent dataComponent = GameEntry.GetComponent<DataTableComponent>();
        m_sceneDataTable = dataComponent.GetDataTable<DTScene>();

        AddComponent<CSceneLoader>();
    }

    public DTScene getSceneData(int sceneID) {
        return m_sceneDataTable.GetDataRow(sceneID);
    }
    public IDataTable<DTScene> m_sceneDataTable;
}
