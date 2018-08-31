using Core;
using GameFramework.Fsm;
using GameFramework.Procedure;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;

public class CProcedureGaming : CProcedure {
    protected override void OnEnter(IFsm<IProcedureManager> procedureOwner) {
        base.OnEnter(procedureOwner);

        CLobbySystem lobbySystem = stage.GetSystem<CLobbySystem>();
        lobbySystem.ShowLobbyView();
    }

    protected override void OnUpdate(IFsm<IProcedureManager> procedureOwner, float elapseSeconds, float realElapseSeconds) {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);

        CLobbySystem lobbySystem = stage.GetSystem<CLobbySystem>();
        if (lobbySystem.lobbyView.isExit) {
            procedureOwner.SetData<VarInt>(EProcedureContant.NextSceneID, (int)ESceneContant.ESceneID.LoginMenu);
            ChangeState<CProcedureChangeScene>(procedureOwner);
        }
    }

    protected override void OnLeave(IFsm<IProcedureManager> procedureOwner, bool isShutdown) {
        CLobbySystem lobbySystem = stage.GetSystem<CLobbySystem>();
        lobbySystem.HideLobbyView();

        base.OnLeave(procedureOwner, isShutdown);
    }

}
