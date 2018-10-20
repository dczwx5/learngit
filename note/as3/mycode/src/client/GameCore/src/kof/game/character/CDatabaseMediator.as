//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.core.CGameComponent;

/**
 * 数据表支持组件
 *
 * @author Jeremy (Jeremy@qifun.com)
 */
public class CDatabaseMediator extends CGameComponent implements IDatabase {

    /** @private */
    private var m_pDatabase : IDatabase;

    /**
     * Creates a new CDatabaseMediator.
     */
    public function CDatabaseMediator( pDatabase : IDatabase ) {
        super( "static_data" );
        this.m_pDatabase = pDatabase;
    }

    override public function dispose() : void {
        super.dispose();
        this.m_pDatabase = null;
    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected function onExit() : void {
        super.onExit();
    }

    public function getTable( sTableName : String ) : IDataTable {
        return m_pDatabase.getTable( sTableName );
    }

    public function get isReady() : Boolean {
        return m_pDatabase.isReady;
    }

    public function addValidator( pfnValidator : Function ) : void {
        m_pDatabase.addValidator( pfnValidator );
    }

    public function removeValidator( pfnValidator : Function ) : void {
        m_pDatabase.removeValidator( pfnValidator );
    }

}
}
