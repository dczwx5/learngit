//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/13.
 */
package kof.game.platform_mobile_regist {

import flash.net.URLRequest;
import flash.net.navigateToURL;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.player.CPlayerSystem;
import kof.table.PlatformMobileRegister;

public class CPlatformMobileRegistSystem extends CBundleSystem{

    private var m_bInitialized : Boolean;

    public function CPlatformMobileRegistSystem() {
        super();

    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() ) {
            return false;
        }

        if ( !m_bInitialized ) {
            m_bInitialized = true;

        }

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.PLATFORM_MOBILE_REGIST);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext) : void {
        super.onBundleStart(ctx);

        var forceClose:Boolean = false;
        var pRecord:PlatformMobileRegister = _getMobileRegistRecord();
        if (!pRecord) {
            forceClose = true;
        }

        if (forceClose) {
            ctx.unregisterSystemBundle(this);
        }
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pRecord:PlatformMobileRegister = _getMobileRegistRecord();
        if (!pRecord) {
            return ;
        }
        if (value) {
            var url:String = pRecord.URL;
            if (url && url.length > 0) {
                // jump to url
                var urlRequest:URLRequest = new URLRequest();
                urlRequest.url = url;
                navigateToURL(urlRequest);
                setActivated(false);
            }
        }

    }

    private function _getMobileRegistRecord() : PlatformMobileRegister {
        var pPlayerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var platform:String = pPlayerSystem.platform.data.platform;
        if (!platform || platform.length == 0) {
            return null;
        }

        var pTable:IDataTable = (stage.getSystem(IDatabase ) as IDatabase).getTable(KOFTableConstants.PLATFORM_MOBILE_REGIST);
        if (pTable) {
            var pList:Array = pTable.findByProperty("platform", platform);
            if (pList && pList.length > 0) {
                var pRecord:PlatformMobileRegister = pList[0] as PlatformMobileRegister;
                return pRecord;
            }
        }
        return null;
    }


    override public function dispose() : void {
        super.dispose();

    }
}
}
