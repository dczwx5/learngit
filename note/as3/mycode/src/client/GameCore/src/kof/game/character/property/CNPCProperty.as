//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/12.
 */
package kof.game.character.property {

import QFLib.Foundation;

import kof.data.KOFTableConstants;

import kof.framework.IDataTable;

import kof.framework.IDatabase;
import kof.table.NPC;
import kof.util.CAssertUtils;

public class CNPCProperty extends CCharacterProperty {
    private var m_pDbSys : IDatabase;
    private var m_pNPCData:NPC;

    public function CNPCProperty() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
        m_pDbSys = null;
    }

    public function get shadow() : int {
        if ( m_pNPCData )
            return m_pNPCData.shadow;
        return 0;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        m_pDbSys = getComponent( IDatabase ) as IDatabase;
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        var pTable : IDataTable = m_pDbSys.getTable( KOFTableConstants.NPC );
        CAssertUtils.assertNotNull( pTable );

        var pData : NPC = pTable.findByPrimaryKey( this.prototypeID ) as NPC;

        if ( !pData ) {
            Foundation.Log.logErrorMsg( "Can't find the NPC from the NPC table by ID = " + this.prototypeID );
            return;
        }

        this.m_pNPCData = pData;
        this.skinName = pData.resource;
        this.moveSpeed = pData.moveSpeed;
        this.nickName = pData.name;
        this.appellation = pData.appellation;
    }

    override protected virtual function onExit() : void {
        super.onExit();

        m_pDbSys = null;
    }
}
}
