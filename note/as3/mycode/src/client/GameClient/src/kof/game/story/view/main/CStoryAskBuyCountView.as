//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/17.
 */
package kof.game.story.view.main {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.data.CPlayerData;
import kof.game.story.CStorySystem;
import kof.game.story.data.CStoryData;
import kof.game.story.data.CStoryGateData;
import kof.game.story.enum.EStoryViewEventType;
import kof.ui.master.HeroStoryView.StoryBuyFightCountUI;

import morn.core.handlers.Handler;


public class CStoryAskBuyCountView extends CRootView {

    public function CStoryAskBuyCountView() {
        var childrenList:Array = null;
        super(StoryBuyFightCountUI, childrenList, null, false);
    }

    protected override function _onCreate() : void {
     }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _ui.ok_btn.clickHandler = new Handler(_onBuy);
    }
    protected override function _onHide() : void {
        _ui.ok_btn.clickHandler = null;

    }


    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var gateData:CStoryGateData = _initialArgs[0] as CStoryGateData;

        _ui.ask_txt.text = CLang.Get("story_ask_to_add_fight_count", {v1:gateData.resetNum});
        var consume:int = _storyData.getBuyCountConsume(gateData.resetNum);
        _ui.cosume_txt.text = consume.toString();

        this.addToPopupDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    private function _onBuy() : void {
        var gateData:CStoryGateData = _initialArgs[0] as CStoryGateData;
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStoryViewEventType.ASK_BUY_COUNT_CLICK_BUY, gateData));
    }


    [Inline]
    private function get _ui() : StoryBuyFightCountUI {
        return rootUI as StoryBuyFightCountUI;
    }
    [Inline]
    private function get _storyData() : CStoryData {
        if (_data && _data.length > 0) {
            return super._data[0] as CStoryData;
        }
        return null;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        if (_data && _data.length > 1) {
            return super._data[1] as CPlayerData;
        }
        return null;
    }
    private function get _system() : CStorySystem {
        return system as CStorySystem;
    }



}
}
