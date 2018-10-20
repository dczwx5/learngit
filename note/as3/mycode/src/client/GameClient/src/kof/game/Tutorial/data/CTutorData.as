//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial.data {

    import QFLib.Foundation.CMap;

    import kof.data.CObjectData;
    import kof.data.KOFTableConstants;
    import kof.framework.IDataTable;
    import kof.framework.IDatabase;
    import kof.table.TutorAction;
    import kof.table.TutorGroup;

    public class CTutorData extends CObjectData {
    public function CTutorData(database:IDatabase) {
        setToRootData(database);

        _tutorGroupList = new CMap();
    }

    override public function dispose() : void {
        for each (var groupInfo:CTutorGroupInfo in _tutorGroupList) {
            groupInfo.dispose();
        }
        _tutorGroupList.clear();
        _tutorGroupList = null;
    }

    public function clear() : void {

    }

    public function getTutorGroupByActionID( iActionID : int ) : CTutorGroupInfo {
        if ( iActionID <= 0 )
            return null;
        var iGroupID : int = 0;
        var actionInfo : TutorAction = tutorActionTable.findByPrimaryKey( iActionID );
        if ( actionInfo ) {
            iGroupID = actionInfo.GroupID;
        }

        if ( iGroupID <= 0 )
            return null;
        return getTutorGroupByID( iGroupID );
    }

    public function getTutorGroupByID(groupID:int) : CTutorGroupInfo {
        var groupInfo:CTutorGroupInfo = _tutorGroupList.find(groupID) as CTutorGroupInfo;
        if (groupInfo == null) {
            if ( tutorGroupTable.findByPrimaryKey( groupID ) ) {
                groupInfo = new CTutorGroupInfo( this, groupID );
                _tutorGroupList.add( groupID, groupInfo );
            }
        }
        return groupInfo;
    }

    public function firstGroup() : CTutorGroupInfo {
        var pList : Array = tutorGroupTable.queryList();
        if ( pList && pList.length ) {
            pList.sortOn( tutorGroupTable.primaryKey );
            return getTutorGroupByID( TutorGroup(pList[0]).ID );
        }
        return null;
    }

    final public function get tutorGroupTable() : IDataTable {
        if (_tutorGroupTable == null) {
            _tutorGroupTable = _databaseSystem.getTable(KOFTableConstants.TUTOR_GROUP);
        }
        return _tutorGroupTable;
    }

    final public function get tutorActionTable() : IDataTable {
        if (_tutorActionTable == null) {
            _tutorActionTable = _databaseSystem.getTable(KOFTableConstants.TUTOR_ACTION);
        }
        return _tutorActionTable;
    }

    final public function get tutorTxtTable() : IDataTable {
        if (_tutorTxtTable == null) {
            _tutorTxtTable = _databaseSystem.getTable(KOFTableConstants.TUTOR_TXT);
        }
        return _tutorTxtTable;
    }

    private var _tutorGroupTable:IDataTable;
    private var _tutorActionTable:IDataTable;
    private var _tutorTxtTable:IDataTable;

    private var _tutorGroupList:CMap;

}
}
