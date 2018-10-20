//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2018/1/4.
 */
package kof.game.rechargerebate {

import QFLib.Interface.IUpdatable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.table.RechargeRebate;

public class CRechargeRebateManager extends CAbstractHandler implements IUpdatable {
    public function CRechargeRebateManager() {
        super();
    }
    public function update(delta:Number) : void {

    }

    public var fristFlg : Boolean = true;
    public var blueDiamondExp : int;
    public var receiveRebateRecord : Array = [];

    public function getRewardObjById( id : int ):Object{
        var obj : Object;
        for each ( obj in receiveRebateRecord ){
            if( obj.chestNumber == id ){
                return obj;
                break;
            }
        }
        return null;
    }


    public function isCanGetAward():Boolean{
        if( blueDiamondExp > 0 ){
            var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.RECHARGEREBATE );
            var ary : Array = pTable.toArray();
            var rechargeRebate : RechargeRebate;
            for each( rechargeRebate in ary ){
                if( blueDiamondExp >= rechargeRebate.blueDiamondExp && getRewardObjById( rechargeRebate.ID ) == null ){
                    return true;
                }
            }
        }
        return false;
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
