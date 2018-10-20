//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.view.levelUp {

import com.greensock.TimelineLite;
import com.greensock.TweenLite;
import com.greensock.data.TweenLiteVars;
import com.greensock.easing.Bounce;
import com.greensock.easing.Elastic;

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.table.PeakScoreLevel;
import kof.ui.master.PeakGame.PeakGameLevelUpUI;
import kof.util.TweenUtil;

import morn.core.handlers.Handler;

public class CPeakGameLevelUpView extends CRootView {

    public function CPeakGameLevelUpView() {
        super(PeakGameLevelUpUI, null, null, false);
        viewId = EPopWindow.POP_WINDOW_12;
    }

    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {
        _coundDownComponent.dispose();
        _coundDownComponent = null;
    }
    protected override function _onShow():void {
        this.listEnterFrameEvent = true;

        _ui.confirm_btn.clickHandler = new Handler(_onOk);
        _coundDownComponent = new CCountDownCompoent(this, _ui.confirm_btn, 30000, _onCountDownEnd, CLang.Get("peak_count_down_prefix"), CLang.Get("peak_count_down_buffix"));

        _showEffect();
    }
    private function _showEffect() : void {
        _ui.confirm_btn.visible = false;
        _ui.desc_txt.visible = false;
        _ui.title_img.visible = false;
        _ui.effect_box.visible = false;

        _ui.level_item.scale = 3.5;
        _ui.level_item.alpha = 0.5;
        _ui.level_item.centerX = 0;
        _ui.level_item.centerY = 0;
        _ui.level_item.name_txt.visible = false;

        _stopTimeline();
        _reduceEffTimeline = new TimelineLite();
        _reduceEffTimeline.append(TweenLite.to(_ui.level_item, .5,{scale:0.97, alpha:1, onUpdate:function () : void {
            _ui.level_item.centerX = 0;
            _ui.level_item.centerY = 0;
            _ui.level_item.name_txt.visible = false;
        }, ease:Bounce.easeOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.level_item, .1,{scale:1, onUpdate:function () : void {
            _ui.level_item.centerX = 0;
            _ui.level_item.centerY = 0;
            _ui.level_item.name_txt.visible = false;
        }, ease:Bounce.easeOut, onComplete:function () : void {
            _stopTimeline();
            _ui.level_item.name_txt.visible = true;
            _ui.confirm_btn.visible = true;
            _ui.desc_txt.visible = true;
            _ui.title_img.visible = true;
            _ui.effect_box.visible = true;

        }}));
    }

    private function _stopTimeline():void{
        if(_reduceEffTimeline){
            _reduceEffTimeline.stop();
            _reduceEffTimeline = null;
        }
    }

    protected override function _onHide() : void {
        _ui.confirm_btn.clickHandler = null;

        var reciprocalSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
        reciprocalSystem.removeEventPopWindow( this.viewId );
    }
    protected override function _onEnterFrame(delta:Number) : void {
        _coundDownComponent.tick();
    }
    private function _onCountDownEnd() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.LEVEL_UP_CLICK_OK));
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _ui.desc_txt.text = CLang.Get("peak_level_up_desc", {v1:_peakGameData.levelName});
        var levelRecord:PeakScoreLevel = _peakGameData.peakLevelRecord;
        CPeakGameLevelItemUtil.setValueBig(_ui.level_item, levelRecord.levelId, levelRecord.subLevelId, levelRecord.levelName);

        this.addToPopupDialog();

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        // this.setChildrenData(v as CPeakGameData);
    }

    // ====================================event=============================
    private function _onOk() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.LEVEL_UP_CLICK_OK));
    }

    //===================================get/set======================================

    [Inline]
    private function get _ui() : PeakGameLevelUpUI {
        return rootUI as PeakGameLevelUpUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _reduceEffTimeline:TimelineLite;
    private var _coundDownComponent:CCountDownCompoent;
}
}
