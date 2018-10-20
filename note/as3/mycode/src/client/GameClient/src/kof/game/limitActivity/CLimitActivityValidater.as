//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.limitActivity {

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.switching.validation.ISwitchingValidation;
import kof.table.BundleEnable;

public class CLimitActivityValidater implements ISwitchingValidation{
    private var m_pSystemRef : CAppSystem;
    private var m_bValid : Boolean;

    /** Creates a new CSwitchingMinLevelValidator. */
    public function CLimitActivityValidater( pSystemRef : CAppSystem ) {
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
            var limitActivityId : int = SYSTEM_ID(KOFSysTags.LIMIT_ACTIVITY );
            var bundleID : int = SYSTEM_ID( pData.TagID );
            if (limitActivityId != bundleID )
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
