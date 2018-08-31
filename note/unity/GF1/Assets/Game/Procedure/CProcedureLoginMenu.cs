using Core;
using GameFramework.Fsm;
using GameFramework.Procedure;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;

public class CProcedureLoginMenu : CProcedure {
    protected override void OnEnter(IFsm<IProcedureManager> procedureOwner) {
        base.OnEnter(procedureOwner);

        CLoginMenuSystem loginMenuSystem = stage.GetSystem<CLoginMenuSystem>();
        loginMenuSystem.showLoginMenuView();
    }

    protected override void OnUpdate(IFsm<IProcedureManager> procedureOwner, float elapseSeconds, float realElapseSeconds) {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);

        CLoginMenuSystem loginMenuSystem = stage.GetSystem<CLoginMenuSystem>();
        if (loginMenuSystem.loginMenuView.isStart) {
            procedureOwner.SetData<VarInt>(EProcedureContant.NextSceneID, (int)ESceneContant.ESceneID.Gaming);
            ChangeState<CProcedureChangeScene>(procedureOwner);
        }
    }

    protected override void OnLeave(IFsm<IProcedureManager> procedureOwner, bool isShutdown) {
        CLoginMenuSystem loginMenuSystem = stage.GetSystem<CLoginMenuSystem>();
        loginMenuSystem.hideLoginMenuView();

        base.OnLeave(procedureOwner, isShutdown);
    }

}
