//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.pay {

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.util.CAssertUtils;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CPlayConfigData {

    /** @private */
    private var m_pSystem : CAppSystem;

    /** Creates a new CPlayConfigData */
    public function CPlayConfigData( pSystem : CAppSystem ) {
        super();

        this.m_pSystem = pSystem;

        CAssertUtils.assertTrue( this.m_pSystem, "System should be valid." );
    }

    /**
     * 列表出充值项配置数据，依照充值的面额大小排序
     */
    public function listPayItemConfigData() : Array {
        if ( !m_pSystem )
            return null;

        var pDB : IDatabase = m_pSystem.stage.getSystem( IDatabase ) as IDatabase;
        if ( pDB ) {
            var pTable : IDataTable = pDB.getTable( KOFTableConstants.PAY_PRODUCT );

            if ( !pTable )
                return null;

            var pList : Array = pTable.toArray();
            pList.sortOn( "Price" );
            return pList;
        }

        return null;
    }

}
}
