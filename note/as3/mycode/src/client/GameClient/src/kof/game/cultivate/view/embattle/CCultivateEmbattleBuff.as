//------------------------------------------------------------------------------
// Copyright (C) 2.058 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2.058/4/26.
 */
package kof.game.cultivate.view.embattle {

import com.greensock.TimelineLite;
import com.greensock.TweenLite;
import com.greensock.easing.Elastic;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.view.event.CViewEvent;
import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.data.cultivate.CCultivateData;
import kof.game.common.view.CChildView;
import kof.game.cultivate.enum.ECultivateViewEventType;
import kof.game.cultivate.imp.CCultivateUtils;
import kof.game.player.data.CPlayerData;
import kof.ui.master.cultivate.CultivateEmbattleUI;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CCultivateEmbattleBuff extends CChildView {
    public function CCultivateEmbattleBuff() {
        super ()
    }
    protected override function _onCreate() : void {
        _isFrist = true;
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }

    protected override function _onShowing():void {
    }

    protected override function _onShow():void {
        _ui.buff_box.addEventListener(MouseEvent.CLICK, _onSelectBuff);
        _playBuffActivedEffectFinishHandler = new Handler(_onPlayBuffActivedEffectFinish);
        _ui.buff_box.rotation = 0;

    }
    protected override function _onHide() : void {
        _ui.buff_box.removeEventListener(MouseEvent.CLICK, _onSelectBuff);

        _ui.buff_active_effect_clip.visible = false;
        _ui.buff_active_effect_clip.stop();
        _ui.buff_select_effect_clip.visible = false;
        _ui.buff_select_effect_clip.stop();
        _playBuffActivedEffectFinishHandler = null;
        _stopTimeline();
    }

    // ===========update and render
    public virtual override function updateWindow() : Boolean {
        if (false ==  super.updateWindow()) {
            return false;
        }

        CCultivateUtils.buffViewRender(_climpData, _ui, false);
        if (_needToPlayBuffActiveMovie) {
            _needToPlayBuffActiveMovie = false;
            ObjectUtils.gray(_ui.buff_box, true); // 过程需要灰化
            _ui.buff_active_effect_clip.stop();
            _ui.buff_active_effect_clip.visible = true;
            _ui.buff_active_effect_clip.playFromTo(null, null, _playBuffActivedEffectFinishHandler)
        }

        return true;
    }
    private function _onPlayBuffActivedEffectFinish() : void {
        _ui.buff_active_effect_clip.stop();
        _ui.buff_active_effect_clip.visible = false;
        ObjectUtils.gray(_ui.buff_box, _climpData.cultivateData.otherData.currBuffEffect == 0);

        if (!this.isShowState) {
            return ;
        }

        _ui.buff_box.rotation = 0;
        _reduceEffTimeline = new TimelineLite();
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, .3,{rotation : 15, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, .3,{rotation : -15, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 3, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : -3, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 3, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : -3, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 3, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : -3, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 3, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : -3, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 2, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : -2, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 2, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : -2, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 2, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : -2, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 1, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : -1, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 1, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : -1, ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(_ui.buff_box, 0.05,{rotation : 0,ease:Elastic.easeInOut,onComplete:_stopTimeline}));
    }
    private function _stopTimeline():void{
        if(_reduceEffTimeline){
            _reduceEffTimeline.stop();
            _reduceEffTimeline = null;
            _ui.buff_box.rotation = 0;
        }
    }

    private var _reduceEffTimeline:TimelineLite;

    public function showBuffActivedMovie() : void {
        _needToPlayBuffActiveMovie = true;
    }
    private var _needToPlayBuffActiveMovie:Boolean;

    private function _onSelectBuff(e:Event) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.EMBATTLE_CLICK_STRATEGY, []));
    }

    [Inline]
    public function get _ui() : CultivateEmbattleUI {
        return (rootUI as CultivateEmbattleUI);
    }
    [Inline]
    public function get _climpData() : CClimpData {
        return super._data[0] as CClimpData;
    }
    [Inline]
    private function get _cultivateData() : CCultivateData {
        return _climpData.cultivateData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _heroEmbattleList:CHeroEmbattleListView;
    private function get _hasEmbattleData() : Boolean {
        return super._data[2] as Boolean;
    }
    private var _isFrist:Boolean = true;
    private var _playBuffActivedEffectFinishHandler:Handler;

}
}