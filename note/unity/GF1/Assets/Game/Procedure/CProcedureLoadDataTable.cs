using Core;
using GameFramework.Event;
using GameFramework.Fsm;
using GameFramework.Procedure;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityGameFramework.Runtime;

public class CProcedureLoadDataTable : CProcedure {
    protected override void OnEnter(IFsm<IProcedureManager> procedureOwner) {
        base.OnEnter(procedureOwner);

        m_finishCount = 0;
        m_totalCount = 0;

        EventComponent eventComp = GameEntry.GetComponent<EventComponent>();
        eventComp.Subscribe(LoadDataTableSuccessEventArgs.EventId, _OnLoadDataTableSuccess);

        _LoadDataTable("DTScene");
    }

    protected override void OnUpdate(IFsm<IProcedureManager> procedureOwner, float elapseSeconds, float realElapseSeconds) {
        base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);

        if (m_finishCount >= m_totalCount) {
            ChangeState<CProcedureStageStart>(procedureOwner);
        }
    }

    protected override void OnLeave(IFsm<IProcedureManager> procedureOwner, bool isShutdown) {
        EventComponent eventComp = GameEntry.GetComponent<EventComponent>();
        eventComp.Unsubscribe(LoadDataTableSuccessEventArgs.EventId, _OnLoadDataTableSuccess);

        base.OnLeave(procedureOwner, isShutdown);
    }

    private void _LoadDataTable(string tableName) {
        Type type = Type.GetType(tableName);
        m_totalCount++;
        DataTableComponent dataTable = GameEntry.GetComponent<DataTableComponent>();
        dataTable.LoadDataTable(type, tableName, CAssetsPath.GetDatatTablePath(tableName));
    }

    private void _OnLoadDataTableSuccess(object sender, GameEventArgs e) {
        m_finishCount++;
    }

    private int m_finishCount;
    private int m_totalCount;

}
