//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm {

import flash.display.DisplayObjectContainer;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.core.CGameObject;
import kof.game.gm.controller.CGmController;
import kof.game.gm.data.CGmData;
import kof.game.gm.enum.EGmViewType;
import kof.game.gm.event.CGmEvent;
import kof.game.gm.view.gmMenu.CGmMenu;
import kof.game.gm.view.gmView.CGmView;
import kof.game.player.data.CPlayerHeroData;

public class CGmUIHandler extends CViewManagerHandler {
    public function CGmUIHandler() {
         
    }
    override public function onEvtEnable() : void {
        super.onEvtEnable();
        if (evtEnable) {
            (system as CGmSystem).gmData.addEventListener(CGmEvent.EVENT_SELECT_HERO_DATA, _onData);
        } else {
            (system as CGmSystem).gmData.removeEventListener(CGmEvent.EVENT_SELECT_HERO_DATA, _onData);
        }
    }
    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();
        this.addViewClassHandler(EGmViewType.TYPE_VIEW, CGmView, CGmController);
        this.addViewClassHandler(EGmViewType.TYPE_MENU, CGmMenu, CGmController);

        return ret;
    }

    private function _onData(e:CGmEvent) : void {
        var selectHero:CGameObject = e.data as CGameObject;
        var gmView:CGmView = getWindow(EGmViewType.TYPE_VIEW) as CGmView;
        if (gmView) {
            gmView.actionView.setArgs([selectHero]);
            gmView.actionView.invalidate();
        }
    }

    public function forceSwitchGmView(parent:DisplayObjectContainer, isShow:Boolean, data:CGmData) : void {
        var view:CViewBase = getWindow(EGmViewType.TYPE_VIEW);
        if (view) {
            if (!isShow) hide(EGmViewType.TYPE_VIEW);
        } else {
            if (isShow) this.show(EGmViewType.TYPE_VIEW, [parent], null, data);
        }
    }

    public function forceSwitchGMenu(parent:DisplayObjectContainer, isShow:Boolean, data:Array) : void {
        var view:CViewBase = getWindow(EGmViewType.TYPE_MENU);
        if (view) {
            if (!isShow) hide(EGmViewType.TYPE_MENU);
        } else {
            if (isShow) this.show(EGmViewType.TYPE_MENU, [parent], null, data);
        }
    }
}
}
