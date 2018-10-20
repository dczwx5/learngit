//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CAppSystemImp;
import kof.game.strengthen.data.CStrengthenData;
import kof.game.strengthen.event.CStrengthenEvent;

public class CStrengthenSystem extends CAppSystemImp  {
    public function CStrengthenSystem() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(SYSTEM_TAG);
    }
    // ===========================show/hide===========================
    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);

        if (isActived) {
            _uiHandler.showStrengthen();
        } else {
            _uiHandler.hideStrengthen();
        }
    }
    override protected function onBundleStart(ctx:ISystemBundleContext):void {
        super.onBundleStart(ctx);
    }

    public override function dispose() : void {
        super.dispose();
    }
    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();

        ret = ret && this.addBean(_manager = new CStrengthenManager());
        ret = ret && this.addBean(_uiHandler = new CStrengthenUIHandler());

        this.registerEventType(CStrengthenEvent.DATA_EVENT);

        return ret;
    }


    // ====================util==========================
    public function get SYSTEM_TAG() : String {
        return KOFSysTags.STRENGTHEN;
    }
    // ===========================get/set=============================
    [Inline]
    public function get manager() : CStrengthenManager { return _manager; }
    [Inline]
    public function get uiHandler() : CStrengthenUIHandler { return _uiHandler; }

    [Inline]
    public function get data() : CStrengthenData { return _manager.data; }


    private var _manager:CStrengthenManager;
    private var _uiHandler:CStrengthenUIHandler;
}
}
