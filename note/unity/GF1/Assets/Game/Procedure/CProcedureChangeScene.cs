using Core;
using GameFramework.Fsm;
using GameFramework.Procedure;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;

public class CProcedureChangeScene : CProcedure {
    public CProcedureChangeScene() {

    }
    protected override void OnEnter(IFsm<IProcedureManager> procedureOwner) {
        base.OnEnter(procedureOwner);

        int sceneID = procedureOwner.GetData<VarInt>(EProcedureContant.NextSceneID).Value;
        CSceneSystem sceneSystem = stage.GetSystem<CSceneSystem>();
        sceneSystem.GetComponent<CSceneLoader>().ChangeScene(sceneID);
    }

    protected override void OnUpdate(IFsm<IProcedureManager> procedureOwner, float elapseSeconds, float realElapseSeconds) {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);

        CSceneSystem sceneSystem = stage.GetSystem<CSceneSystem>();
        CSceneLoader sceneLoader = sceneSystem.GetComponent<CSceneLoader>();
        if (sceneLoader.isLoadFinish) {
            switch ((ESceneContant.ESceneID)sceneLoader.sceneID) {
                case ESceneContant.ESceneID.LoginMenu:
                    ChangeState<CProcedureLoginMenu>(procedureOwner);
                    break;
                case ESceneContant.ESceneID.Gaming:
                    ChangeState<CProcedureGaming>(procedureOwner);
                    break;
            }
        }


    }

    protected override void OnLeave(IFsm<IProcedureManager> procedureOwner, bool isShutdown) {
        base.OnLeave(procedureOwner, isShutdown);
    }

}
