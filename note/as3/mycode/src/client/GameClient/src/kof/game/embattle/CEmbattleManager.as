//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/14.
 */
package kof.game.embattle {

import QFLib.Interface.IUpdatable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.table.InstanceType;

public class CEmbattleManager extends CAbstractHandler implements IUpdatable {
    public function CEmbattleManager() {
        super();
    }
    public function update(delta:Number) : void {

    }
    override public function dispose() : void {
        super.dispose();
    }

    public function getInstanceByType( type : int ):InstanceType{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.INSTANCE_TYPE );
        var instanceType : InstanceType;
        for each ( instanceType in pTable.toArray()){
            if( instanceType.ID == type )
                return instanceType;
        }
        return null;
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
