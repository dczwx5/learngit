//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/12.
 */
package kof.game.player.view.heroGet {

import com.greensock.TweenLite;
import com.greensock.easing.Bounce;
import kof.game.common.view.component.CUICompoentBase;
import morn.core.components.FrameClip;
import morn.core.handlers.Handler;

public class CPlayerHeroGetComponent extends CUICompoentBase {
    private var _count:int = 0;
    public function CPlayerHeroGetComponent(view:CPlayerHeroGetView) {
        super (view);
        _view = view;
        _count = 0;
        // initial base ui
        _view._ui.desc_box.alpha = 0;
        _view._ui.quality_clip.visible = false;

        // initial effects
        var initialHideList:Array = [
//            {effect:_view._ui.baoza_clip}, // 后面一起出现
            {effect:_view._ui.effect_quality_light_clip}, // 后面一起出现
            {effect:_view._ui.effect_txt_clip}, // 后面一起出现
//            {effect:_view._ui.loop_1_clip}, // 最后两个循环
            {effect:_view._ui.bg_light_frameclip} // 最后两个循环

        ];
        for each (var obj:Object in initialHideList) {
            var effect:FrameClip = obj["effect"] as FrameClip;
            effect.stop();
            effect.visible = false;
        }

        // initial action
        _actionList = new Vector.<Action>();
//        _actionList.push(new Action(_onPlayBaozha, -1));
        _actionList.push(new Action(_onPlayOther, -1));
        for (var i:int = 0; i < _actionList.length; i++) {
            if (i+1 < _actionList.length) {
                _actionList[i].next = _actionList[i+1];
            } else {
                _actionList[i].next = null;
            }
        }

        _curAction = _actionList.shift();
    }

    public function start() : void {
        _curAction.call();
    }

    // ==================step=======================
//    private function _onPlayBaozha(action:Action) : void {
//        var baozha:FrameClip = _view._ui.loop_2_clip;
//        baozha.stop();
//        baozha.visible = true;
//        baozha.playFromTo(null, null, new Handler(function () : void {
//            baozha.visible = false;
//            baozha.stop();
//            _nextAction(_curAction);
//        }));
//
//    }

    private function _onPlayOther(action:Action) : void {
        _view.playSound();
        _view._ui.name_img.visible = true;
        _view._ui.hero_icon_img.visible = true;
        _view._ui.job_clip.visible = true;

        var list:Array = [
//            {effect:_view._ui.baoza_clip, func:null},
            {effect:_view._ui.effect_quality_light_clip, func:null},
            {effect:_view._ui.effect_txt_clip, func:_onTxtPlayEnd},
        ];
        for each (var obj:Object in list) {
            _playEffectCommon(obj["effect"], obj["func"]);
        }
        _view._ui.quality_clip.visible = true;
        TweenLite.to(_view._ui.quality_clip, 1, {x:_view.baseQualityPos.x, onComplete:function () : void {
            _count++;
            _checkEnd();
        }, ease:Bounce.easeOut});

        // 两个循环的
//        _view._ui.loop_1_clip.visible = true;
//        _view._ui.loop_1_clip.gotoAndPlay(0);
        _view._ui.bg_light_frameclip.visible = true;
        _view._ui.bg_light_frameclip.gotoAndPlay(0);
    }
    private function _onTxtPlayEnd() : void {
        _view._ui.desc_box.visible = true;
        _view._ui.desc_box.alpha = 0;
        TweenLite.to(_view._ui.desc_box, 1, {alpha:1, onComplete:function () : void {
            _count++;
            _checkEnd();
        }});
    }
    private function _checkEnd() : void {
        if (_count >= 2) {
            _view._ui.btn_close.visible = true;
            _view._ui.img_confirm.visible = true;
        }
    }
    private function _playEffectCommon(effect:FrameClip, callback:Function) : void {
        effect.stop();
        effect.visible = true;
        effect.playFromTo(null, null, new Handler(function () : void {
            effect.stop();
            effect.visible = false;
            if (callback) callback.apply();
        }));
    }

    private function _nextAction(action:Action) : void {
        _curAction = action.next;
        if (_curAction) {
            delayCall(_curAction.call, 0.1);
        } else {
//            if (_endFunc) _endFunc.apply();
        }
    }

    private var _view:CPlayerHeroGetView;
    private var _actionList:Vector.<Action>;
    private var _curAction:Action;

}
}
class Action {
    public function Action(action:Function, duringTime:Number) {
        this._action = action;
        this.duringTime = duringTime;
    }

    public function call() : void {
        if (_action) {
            _action(this);
        }
    }

    private var _action:Function;
    public var isFinish:Boolean;
    public var duringTime:Number;
    public var next:Action;
}