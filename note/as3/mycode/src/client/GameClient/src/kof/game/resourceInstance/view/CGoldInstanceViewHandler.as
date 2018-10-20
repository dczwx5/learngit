//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/6/22.
 */
package kof.game.resourceInstance.view {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.instance.enum.EInstanceType;
import kof.ui.demo.Currency.MoneyOneTipsUI;
import kof.ui.master.ResourceInstance.GoldInstanceViewUI;

/**
 * 金币副本难度界面
 *
 * @author dendi (dendi@qifun.com)
 */
public class CGoldInstanceViewHandler extends CResourceInstanceBasicsViewHandler {
    public function CGoldInstanceViewHandler() {
        super();
        instanceType = EInstanceType.TYPE_GOLD_INSTANCE;
    }

    override protected function onInitializeView() : Boolean {
        if(pViewUI == null)
            pViewUI = new GoldInstanceViewUI();

        return super.onInitializeView();
    }

    override public function initListData() : Array{
        var resourceInstanceDifficultyTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RESOURCEINSTANCEDIFFICULTY);
        if(resourceInstanceDifficultyTable){
            var instanceDifArray:Array = resourceInstanceDifficultyTable.toArray();
            return instanceDifArray;
        }
        return null;
    }

    override public function get viewClass() : Array {
        return [ GoldInstanceViewUI,MoneyOneTipsUI ];
    }
}
}
