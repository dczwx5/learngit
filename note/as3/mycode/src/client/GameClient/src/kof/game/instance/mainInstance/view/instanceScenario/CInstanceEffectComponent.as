//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/27.
 */
package kof.game.instance.mainInstance.view.instanceScenario {

import kof.game.common.view.CChildView;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.ui.instance.InstanceScenarioUI;

import morn.core.components.Component;
import morn.core.components.FrameClip;

public class CInstanceEffectComponent extends CChildView{
    public function CInstanceEffectComponent() {
    }

    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        _ui.effect_mask.cacheAsBitmap = true;
        _ui.effect_mask2.cacheAsBitmap = true;
        _ui.effect_mask_3.cacheAsBitmap = true;
        _ui.movie_6_clip.cacheAsBitmap = true;

        _ui.movie_15_clip_2.cacheAsBitmap = true;
        _ui.movie_4_clip_2.cacheAsBitmap = true;
        _ui.movie_6_clip_2.cacheAsBitmap = true;
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShowing():void {
        // can not call super._onShowing in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        // 隐藏所有特效
        var effect:Component;
        var effectName:String;
        for each (effectName in _effectListInstance) {
            effect = _ui[effectName];
            if (effect) {
                effect.visible = false;
                if (effect is FrameClip) {
                    (effect as FrameClip).stop();
                }
            }
        }
        for each (effectName in _effectListElite) {
            effect = _ui[effectName];
            if (effect) {
                effect.visible = false;
                if (effect is FrameClip) {
                    (effect as FrameClip).stop();
                }
            }
        }
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
    }
    public  override function updateWindow() : Boolean {
        var effect:Component;
        var effectName:String;
        if (data.instanceType == EInstanceType.TYPE_MAIN) {
            for each (effectName in _effectListInstance) {
                effect = _ui[effectName];
                if (effect) {
                    effect.visible = true;
                    if (effect is FrameClip) {
                        (effect as FrameClip).play();
                    }
                }
            }
            _ui.effect_mask.visible = false;
            _ui.effect_mask2.visible = false;
            _ui.movie_6_clip.mask = _ui.effect_mask_3;
        } else {
            for each (effectName in _effectListElite) {
                effect = _ui[effectName];
                if (effect) {
                    effect.visible = true;
                    if (effect is FrameClip) {
                        (effect as FrameClip).play();
                    }
                }
            }
            _ui.effect_mask.visible = _ui.effect_mask2.visible = true;
            _ui.movie_15_clip_2.mask = _ui.effect_mask;
            _ui.movie_4_clip_2.mask = _ui.effect_mask2;
            _ui.movie_6_clip_2.mask = _ui.effect_mask_3;
        }

        return true;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    private function get _ui() : InstanceScenarioUI {
        return rootUI as InstanceScenarioUI;
    }
    private var _effectListInstance:Array = ["movie_6_clip",  "movie_13_clip", "movie_2_clip", "effect_flat_box"];
    private var _effectListElite:Array = ["movie_15_clip_2","movie_4_clip_2", "movie_6_clip_2", "movie_7_clip_2", "movie_100_clip_2", "movie_13_clip_2", "movie_2_clip_2" , "movie_3_clip_2", "effect_flat_box_2"];
}
}
