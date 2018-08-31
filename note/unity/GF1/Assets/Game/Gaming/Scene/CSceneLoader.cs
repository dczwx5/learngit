using Core;
using GameFramework.Event;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;

public class CSceneLoader : CBean {
    void Start() {
        isLoadFinish = false;
        isError = false;
    }

    public void ChangeScene(int sceneID) {
        this.sceneID = sceneID;

        EventComponent eventComp = GameEntry.GetComponent<EventComponent>();
        eventComp.Subscribe(LoadSceneSuccessEventArgs.EventId, _OnLoadSceneSuccess);
        eventComp.Subscribe(LoadSceneFailureEventArgs.EventId, _OnLoadSceneFailure);

        // 卸载所有场景
        SceneComponent sceneComp = GameEntry.GetComponent<SceneComponent>();
        string[] loadedSceneAssetNames = sceneComp.GetLoadedSceneAssetNames();
        for (int i = 0; i < loadedSceneAssetNames.Length; i++) {
            sceneComp.UnloadScene(loadedSceneAssetNames[i]);
        }

        // 还原游戏速度
        BaseComponent baseComp = GameEntry.GetComponent<BaseComponent>();
        baseComp.ResetNormalGameSpeed();

        // 加载场景
        DataTableComponent dataComponent = GameEntry.GetComponent<DataTableComponent>();

        DTScene sceneData = ((CSceneSystem)system).getSceneData(sceneID);
        string scenePath = CAssetsPath.GetScenePath(sceneData.sceneName);
        if (string.IsNullOrEmpty(scenePath)) {
            Debug.LogErrorFormat("sceneID : {0} is not Exist...", sceneID);
            isError = true;
            return ;
        }

        sceneComp.LoadScene(scenePath, this);
    }

    public void Reset() {
        EventComponent eventComp = GameEntry.GetComponent<EventComponent>();
        eventComp.Unsubscribe(LoadSceneSuccessEventArgs.EventId, _OnLoadSceneSuccess);
        eventComp.Unsubscribe(LoadSceneFailureEventArgs.EventId, _OnLoadSceneFailure);
    }

    private void _OnLoadSceneSuccess(object sender, GameEventArgs e) {
        isLoadFinish = true;
        Reset();
    }
    private void _OnLoadSceneFailure(object sender, GameEventArgs e) {
        isError = true;
        Reset();
    }


    public bool isLoadFinish {
        get;
        private set;
    }
    public bool isError {
        get;
        private set;
    }
    public int sceneID {
        get;
        private set;
    }

}
