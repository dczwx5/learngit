//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CAppSystemImp;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerVisitData;
import kof.game.title.data.CTitleData;
import kof.game.title.event.CTitleEvent;
//
//send add_title 配置id 剩余秒数
//id为0代表所有
//秒数小于0代表重置
// send add_title 0 0 全部生效
// send add_title 0 -1 全部失效
public class CTitleSystem extends CAppSystemImp  {
    public function CTitleSystem() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(SYSTEM_TAG);
    }
    // ===========================show/hide===========================
    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);

        if (isActived) {
            var otherData:Array = ctx.getUserData(this, VISITOR_DATA, null);
            if (otherData && otherData.length > 1) {
                var visitorData:CPlayerVisitData = otherData[0] as CPlayerVisitData;
                var titleData:CTitleData = otherData[1] as CTitleData;
                _uiHandler.showTitle(visitorData, titleData);
                ctx.setUserData(this, VISITOR_DATA, null);
            } else {
                _uiHandler.showTitle(null, null);
            }

        } else {
            _uiHandler.hideTitle();
        }
    }
    override protected function onBundleStart(ctx:ISystemBundleContext):void {
        super.onBundleStart(ctx);
        var pPlayerData:CPlayerData = (stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        netHandler.sendGetData(pPlayerData.ID);
    }

    public override function dispose() : void {
        super.dispose();
    }
    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();

        ret = ret && this.addBean(_manager = new CTitleManager());
        ret = ret && this.addBean(new CTitleNetEventTransformHandler());
        ret = ret && this.addBean(_uiHandler = new CTitleUIHandler());
        ret = ret && this.addBean(_netHandler = new CTitleNetHandler());

        this.registerEventType(CTitleEvent.NET_EVENT_DATA);
        this.registerEventType(CTitleEvent.NET_EVENT_UPDATE_DATA);
        this.registerEventType(CTitleEvent.NET_EVENT_WEAR);
        this.registerEventType(CTitleEvent.DATA_EVENT);

        return ret;
    }


    // ====================util==========================
    public function get SYSTEM_TAG() : String {
        return KOFSysTags.TITLE;
    }
    // ===========================get/set=============================
    [Inline]
    public function get manager() : CTitleManager { return _manager; }
    [Inline]
    public function get uiHandler() : CTitleUIHandler { return _uiHandler; }
    [Inline]
    public function get netHandler() : CTitleNetHandler { return _netHandler; }
    [Inline]
    public function get data() : CTitleData { return _manager.data; }


    private var _manager:CTitleManager;
    private var _netHandler:CTitleNetHandler;
    private var _uiHandler:CTitleUIHandler;
}
}
