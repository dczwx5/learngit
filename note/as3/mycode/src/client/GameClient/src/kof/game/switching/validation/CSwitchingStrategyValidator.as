//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.validation {

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.instance.IInstanceFacade;
import kof.table.BundleEnable;

/**
 * 功能开启，应用场景验证
 *
 * 1. 无条件类型的功能开启
 * 2. 主城下的功能开启
 * 3. 副本中功能开启
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingStrategyValidator implements ISwitchingValidation {

    /** @private */
    private var m_pSystemRef : CAppSystem;
    /** @private */
    private var m_bMainCityInit : int;

    /** Creates a new CSwitchingStrategyValidator */
    public function CSwitchingStrategyValidator( pSystemRef : CAppSystem ) {
        super();
        m_pSystemRef = pSystemRef;
    }

    public function dispose() : void {
        m_pSystemRef = null;
    }

    public function get isInitialized() : Boolean {
        return m_bMainCityInit >= 2;
    }

    public function evaluate( ... args ) : Boolean {
        var pConfigData : BundleEnable = args[ 0 ] as BundleEnable;
        if ( !pConfigData )
            return true;
        var iBundleID : int = SYSTEM_ID( pConfigData.TagID );
        if ( iBundleID < -2 ) {
            return true;
        } else {
            var pInstanceSys : IInstanceFacade = m_pSystemRef.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
            if ( !pInstanceSys )
                return true;
            var ret : Boolean = pInstanceSys.isMainCity;
            if ( ret ) {
                m_bMainCityInit++;
            }
            return ret;
        }
    }

    public function getLocaleDesc( configData : Object ) : String {
        return null;
    }
}
}
