//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title {

import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerVisitData;
import kof.game.title.control.CTitleMainControler;
import kof.game.title.data.CTitleData;
import kof.game.title.enum.ETitleDataEventType;
import kof.game.title.enum.ETitleWndType;
import kof.game.title.event.CTitleEvent;
import kof.game.title.view.CTitleView;

public class CTitleUIHandler extends CViewManagerHandler {

    public function CTitleUIHandler() {
    }

    public override function dispose() : void {
        super.dispose();
        _system.unListenEvent(_onTitleEvent);
    }

    override public virtual function onEvtEnable() : void {
        super.onEvtEnable();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.addViewClassHandler(ETitleWndType.WND_MAIN, CTitleView, CTitleMainControler);

        this.addBundleData(ETitleWndType.WND_MAIN, _system.SYSTEM_TAG);

        _system.listenEvent(_onTitleEvent); // 由于在没有打开界面的时候。也需要处理事件，(levelUpView, 所以不能放到onEvtEnable处理)

        return ret;
    }

    // ================================== event ==================================
    private function _onTitleEvent(e:CTitleEvent) : void {
        if (CTitleEvent.DATA_EVENT != e.type) return ;

        var win:CViewBase;
        var subEvent:String = e.subEvent;
        switch (subEvent) {
            case ETitleDataEventType.DATA :
                win = getWindow(ETitleWndType.WND_MAIN);
                if (win && win.isShowState) {
                    win.invalidate();
                }

                break;
        }
    }

    public function showTitle(visitorData:CPlayerVisitData, otherTitleData:CTitleData) : void {
        if (visitorData && otherTitleData) {
            show(ETitleWndType.WND_MAIN, null, null, [otherTitleData, _playerData, visitorData]);
        } else {
            show(ETitleWndType.WND_MAIN, null, null, [_data, _playerData]);
        }

    }
    public function hideTitle() : void {
        this.hide(ETitleWndType.WND_MAIN);
    }
    // ================================== common data ==================================
    [Inline]
    private function get _system() : CTitleSystem {
        return system as CTitleSystem;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    [Inline]
    private function get _data() : CTitleData {
        return _system.data;
    }
}
}
