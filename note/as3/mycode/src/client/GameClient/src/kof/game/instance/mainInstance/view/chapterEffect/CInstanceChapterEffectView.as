//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/27.
 */
package kof.game.instance.mainInstance.view.chapterEffect {


import kof.game.common.CNextFrameCall;
import kof.game.common.view.CRootView;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.ui.instance.InstanceChapterEffectUI;

import morn.core.components.FrameClip;
import morn.core.handlers.Handler;

public class CInstanceChapterEffectView extends CRootView {
    public function CInstanceChapterEffectView() {
        super(InstanceChapterEffectUI, [], EInstanceWndResType.INSTANCE_CHAPTER_EFFECT, false);
        viewId = EPopWindow.POP_WINDOW_4;
    }

    protected override function _onCreate() : void {
        setNoneData();
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _ui.chapter_finish_clip.gotoAndStop(0);
        _ui.new_chapter_open_clip.gotoAndStop(0);
        _ui.chapter_finish_clip.visible = false;
        _ui.new_chapter_open_clip.visible = false;
        _isFirst = true;
    }

    protected override function _onHide() : void {
        _ui.chapter_finish_clip.gotoAndStop(0);
        _ui.new_chapter_open_clip.gotoAndStop(0);
        var reciprocalSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
        reciprocalSystem.removeEventPopWindow( this.viewId );
    }

    private var _isFirst:Boolean;
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var isFinish:Boolean = _initialArgs[0] as Boolean;
        var isOpen:Boolean = !isFinish;
        if (isFinish) {
            _playEffect = _ui.chapter_finish_clip;
        } else {
            _playEffect = _ui.new_chapter_open_clip;
        }
        if (_isFirst) {
            _playEffect.visible = false;
            var callback:Handler = new Handler(function () : void {
                _playEffect.visible = true;
                _playEffect.playFromTo(null, null, new Handler(_onPlayCompleted));
            });
            var iDelayFrame:int = 0;
            if (isFinish) {
                iDelayFrame = 30;
            }
            new CNextFrameCall(system.stage.flashStage, callback, iDelayFrame);
            _isFirst = false;
        }
        this.addToDialog(null);
        return true;
    }

    private function _onPlayCompleted() : void {
        close();
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

    }

    private function get _ui() : InstanceChapterEffectUI {
        return rootUI as InstanceChapterEffectUI;
    }

    private var _playEffect:FrameClip;
}
}
