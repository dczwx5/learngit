using Core;
using GameFramework.Fsm;
using GameFramework.Procedure;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;

public class CProcedureStageStart : CProcedure {
    protected override void OnEnter(IFsm<IProcedureManager> procedureOwner) {
        base.OnEnter(procedureOwner);

        stage.AddSystem<CLoginMenuSystem>();
        stage.AddSystem<CSceneSystem>();
        stage.AddSystem<CLobbySystem>();
    }

    protected override void OnUpdate(IFsm<IProcedureManager> procedureOwner, float elapseSeconds, float realElapseSeconds) {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);

        ChangeState<CProcedureChangeScene>(procedureOwner);
    }

    protected override void OnLeave(IFsm<IProcedureManager> procedureOwner, bool isShutdown) {
        base.OnLeave(procedureOwner, isShutdown);
    }

}
