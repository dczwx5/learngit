//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/9/18.
 */
package kof.game.totalRecharge {

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.switching.validation.ISwitchingValidation;
import kof.table.BundleEnable;

public class CTotalRechargeValidater implements ISwitchingValidation{
    private var m_pSystem : CAppSystem;
    private var m_bValid : Boolean = true;

    public function CTotalRechargeValidater(pSystemRef : CAppSystem) {
        super();
        this.m_pSystem = pSystemRef;
    }

    public function dispose() : void
    {
        m_pSystem = null;
    }

    public function evaluate( ... args ) : Boolean
    {
        var pData : BundleEnable = args[ 0 ] as BundleEnable;
        if ( !pData )
        {
            return true;
        }
        else
        {
            var sysID : int = SYSTEM_ID(KOFSysTags.TOTAL_RECHARGE );
            var bundleID : int = SYSTEM_ID( pData.TagID );

            if (sysID != bundleID)
            {
                return true;
            }
            else
            {
                return this.valid;
            }
        }
    }

    public function getLocaleDesc( configData : Object ) : String
    {
        return null;
    }

    final public function get valid() : Boolean
    {
        return m_bValid;
    }

    final public function set valid( value : Boolean ) : void
    {
        m_bValid = value;
    }
}
}