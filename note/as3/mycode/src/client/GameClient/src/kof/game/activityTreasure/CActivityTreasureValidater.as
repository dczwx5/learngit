//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/6/28.
 */
package kof.game.activityTreasure {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.player.CPlayerSystem;
import kof.game.switching.validation.ISwitchingValidation;
import kof.table.BundleEnable;

public class CActivityTreasureValidater implements ISwitchingValidation {
    private var m_pSystemRef : CActivityTreasureSystem;
    private var m_bValid : Boolean = true;

    public function CActivityTreasureValidater( pSystemRef : CActivityTreasureSystem ) {
        super();
        this.m_pSystemRef = pSystemRef;
    }

    public function dispose() : void {
        m_pSystemRef = null;
    }

    public function evaluate( ... args ) : Boolean {
        var pData : BundleEnable = args[ 0 ] as BundleEnable;
        if ( !pData )
            return true;
        else {
            var activityID : int = SYSTEM_ID( KOFSysTags.ACTIVITY_TREASURE );
            var bundleID : int = SYSTEM_ID( pData.TagID );

            if ( activityID != bundleID )
                return true;
            else
                return this.valid;
        }

        return true;
    }

    public function getLocaleDesc( configData : Object ) : String {
        return null;
    }

    final public function get valid() : Boolean {
        return m_bValid;
    }

    final public function set valid( value : Boolean ) : void {
        m_bValid = value;
        //同时校验活动状态和开启等级
        var lvl : int = (m_pSystemRef.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.teamData.level;
        var confLvl : int = m_pSystemRef.ConfigLevel;
        m_pSystemRef.changeActivityState( value && lvl >= confLvl );
    }
}
}
