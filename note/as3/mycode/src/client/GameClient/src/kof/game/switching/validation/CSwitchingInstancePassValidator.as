//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.validation {

import kof.framework.CAppSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.table.BundleEnable;

/**
 * 功能开启：副本通关验证器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingInstancePassValidator implements ISwitchingValidation {

    private var m_pSystemRef : CAppSystem;

    public function CSwitchingInstancePassValidator( pSystemRef : CAppSystem ) {
        super();
        m_pSystemRef = pSystemRef;
    }

    public function dispose() : void {
        m_pSystemRef = null;
    }

    public function evaluate( ... args ) : Boolean {
        var pData : BundleEnable = args[ 0 ] as BundleEnable;
        if ( !pData )
            return true;

        var vStatusQuery : Array = args.length > 1 ? args[ 1 ] as Array : [];
        if ( vStatusQuery.length == 0 )
            vStatusQuery.push( 0 );

        var vID2Validated : int = pData.InstancePassID;

        if ( vID2Validated == 0 ) {
            vStatusQuery[ 0 ] = -1;
            return true;
        }

        var pInstanceSys : IInstanceFacade = m_pSystemRef.stage.getSystem( IInstanceFacade ) as IInstanceFacade;

        if ( !pInstanceSys ) {
            vStatusQuery[ 0 ] = -1;
            return true;
        }

        vStatusQuery[ 0 ] = 0;

        return pInstanceSys.isInstancePass( vID2Validated );
    }

    public function getLocaleDesc( pConfigData : Object ) : String {
        var pData : BundleEnable = pConfigData as BundleEnable;
        if ( !pData )
            return null;
        var sInstanceDesc : String;
        var pInstanceSys : CInstanceSystem = m_pSystemRef.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
        if ( pInstanceSys ) {
            sInstanceDesc = pInstanceSys.getInstanceByID( pData.InstancePassID ).name;
        }
        if ( !sInstanceDesc )
            sInstanceDesc = pData.InstancePassID.toString();
        return "完成剧情副本<font color='{}'>" + sInstanceDesc + "</font>";
    }

}
}
