//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story {

import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.story.control.CStoryAskBuyCountControler;
import kof.game.story.control.CStoryMainControler;
import kof.game.story.control.CStoryResultControler;
import kof.game.story.data.CStoryData;
import kof.game.story.data.CStoryGateData;
import kof.game.story.enum.EStoryDataEventType;
import kof.game.story.enum.EStoryWndType;
import kof.game.story.event.CStoryEvent;
import kof.game.story.view.CStoryWinView.CStoryWinView;
import kof.game.story.view.main.CStoryAskBuyCountView;
import kof.game.story.view.main.CStoryView;

public class CStoryUIHandler extends CViewManagerHandler {

    public function CStoryUIHandler() {
    }

    public override function dispose() : void {
        super.dispose();
        _system.unListenEvent(_onStoryEvent);
    }

    override public virtual function onEvtEnable() : void {
        super.onEvtEnable();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.addViewClassHandler(EStoryWndType.WND_MAIN, CStoryView, CStoryMainControler);
        this.addViewClassHandler(EStoryWndType.WND_RESULT, CStoryWinView, CStoryResultControler);
        this.addViewClassHandler(EStoryWndType.WND_ADD_FIGHT_COUNT, CStoryAskBuyCountView, CStoryAskBuyCountControler);

        this.addBundleData(EStoryWndType.WND_MAIN, _system.SYSTEM_TAG);

        _system.listenEvent(_onStoryEvent); // 由于在没有打开界面的时候。也需要处理事件，(levelUpView, 所以不能放到onEvtEnable处理)

        return ret;
    }

    // ================================== event ==================================
    private function _onStoryEvent(e:CStoryEvent) : void {
        if (CStoryEvent.DATA_EVENT != e.type) return ;

        var win:CViewBase;
        var subEvent:String = e.subEvent;
        switch (subEvent) {
            case EStoryDataEventType.DATA :
                win = getWindow(EStoryWndType.WND_MAIN);
                if (win && win.isShowState) {
                    win.invalidate();
                }

                break;
        }
    }

    public function showStory(heroID:int) : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStoryData = _data;
        show(EStoryWndType.WND_MAIN, [heroID], null, [streetData, playerData]);
    }
    public function hideStory() : void {
        this.hide(EStoryWndType.WND_MAIN);
    }
    public function showResult() : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStoryData = _data;
        show(EStoryWndType.WND_RESULT, null, null, [streetData, playerData]);
    }
    public function hideResult() : void {
        this.hide(EStoryWndType.WND_RESULT);
    }
    public function showAskBuyCount(gateData:CStoryGateData) : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStoryData = _data;
        show(EStoryWndType.WND_ADD_FIGHT_COUNT, [gateData], null, [streetData, playerData]);
    }
    // ================================== common data ==================================
    [Inline]
    private function get _system() : CStorySystem {
        return system as CStorySystem;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    [Inline]
    private function get _data() : CStoryData {
        return _system.data;
    }
}
}
