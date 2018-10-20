//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/16.
 */
package kof.game.OneDiamondReward {

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.switching.validation.ISwitchingValidation;
import kof.table.BundleEnable;

public class COneDiamondValidater implements ISwitchingValidation{
    private var m_pSystemRef : CAppSystem;
    private var m_bValid : Boolean;

    /** Creates a new CSwitchingMinLevelValidator. */
    public function COneDiamondValidater( pSystemRef : CAppSystem ) {
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
            var oneDiamondId : int = SYSTEM_ID(KOFSysTags.ONE_DIAMOND_REWARD );
            var bundleID : int = SYSTEM_ID( pData.TagID );
            if (oneDiamondId != bundleID )
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
