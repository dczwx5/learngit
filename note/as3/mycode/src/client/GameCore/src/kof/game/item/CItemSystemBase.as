//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/23.
 */
package kof.game.item {

import kof.data.CDatabaseSystem;
import kof.framework.CAppSystem;

public class CItemSystemBase extends CAppSystem  {


    public function CItemSystemBase() {
        super();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _dataManager = new CItemDataManager(stage.getSystem(CDatabaseSystem) as CDatabaseSystem);
        //_itemTable = (stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        return ret;
    }


    // ======================================table================================================
    public function getItem(itemID:int) : CItemData {
        return _dataManager.getItem(itemID);
    }

    private var _dataManager:CItemDataManager;

}
}
