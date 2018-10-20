//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/9/6.
 */
package kof.game.activityHall.event {

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.switching.validation.ISwitchingValidation;
import kof.table.BundleEnable;

public class CActivityHallValidater implements ISwitchingValidation {

    private var m_pSystemRef : CAppSystem;
    private var m_bValid : Boolean = true;
    public function CActivityHallValidater( pSystemRef : CAppSystem) {
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
        else
        {
            var activityID : int = SYSTEM_ID(KOFSysTags.ACTIVITY_HALL );
            var bundleID : int = SYSTEM_ID( pData.TagID );
            if (activityID != bundleID)
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
    }

}
}
