using Core;
using GameFramework.Fsm;
using GameFramework.Procedure;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;

public class CProcedureCheckVersion : CProcedure {
    protected override void OnEnter(IFsm<IProcedureManager> procedureOwner) {
        base.OnEnter(procedureOwner);
    }

    protected override void OnUpdate(IFsm<IProcedureManager> procedureOwner, float elapseSeconds, float realElapseSeconds) {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);

        ChangeState<CProcedureLoadDataTable>(procedureOwner);

    }

    protected override void OnLeave(IFsm<IProcedureManager> procedureOwner, bool isShutdown) {
        base.OnLeave(procedureOwner, isShutdown);
    }

}
