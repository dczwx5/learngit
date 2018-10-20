//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/8/21.
 */
package kof.game.Tutorial.view {

import QFLib.Math.CMath;

import com.greensock.TweenLite;
import com.greensock.easing.Bounce;
import com.greensock.easing.Elastic;

import flash.geom.Point;

import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.data.CTutorData;
import kof.game.Tutorial.enum.ETutorWndResType;
import kof.game.common.view.CRootView;
import kof.game.player.data.CPlayerData;
import kof.ui.CUISystem;
import kof.ui.master.tutor.TutorArrowUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.handlers.Handler;

public class CTutorArrowView extends CRootView {

    public function CTutorArrowView() {
        super(TutorArrowUI, null, ETutorWndResType.TUTOR_ARROW, false);
    }

    protected override function _onCreate() : void {
        setNoneData();
        _ui.mouseEnabled = false;
        _ui.mouseChildren = false;
        hideBigEffect();
    }

    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
    }

    protected override function _onHide() : void {
        _pHoleTarget = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_ui && _ui.stage == null) {
            var pUISys : CUISystem = uiCanvas as CUISystem;
            pUISys.tutorArrowLayer.addChild( _ui );
        }

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);

    }

    // ====================================event=============================

    //===================================get/set======================================
    [Inline]
    private function get _ui() : TutorArrowUI {
        return rootUI as TutorArrowUI;
    }
    [Inline]
    private function get _tutorData() : CTutorData {
        return super._data[0] as CTutorData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    public function clearHoleTarget() : void {
        _pHoleTarget = null;
    }
    private var _pHoleTarget:Component;
    private var _isTweening:Boolean;
    public function arrowTargetTo( holeTarget : Component, _info : CTutorActionInfo, isFirst:Boolean ) : void {
        void(_info);
        _pHoleTarget = holeTarget;
        const pTutorUI : TutorArrowUI = _ui;
        if ( !holeTarget ) {
            return;
        }
        if (_isTweening) {
            return ;
        }
        var arrowRotation:Number = 0;
        var targetGlobalPoint : Point = holeTarget.localToGlobal( STAGE_LEFT_TOP );
        var stageCenter : Point = new Point( holeTarget.stage.stageWidth / 2, holeTarget.stage.stageHeight / 2 );
        var stageQuart : Point = new Point( holeTarget.stage.stageWidth / 4, holeTarget.stage.stageHeight / 4 );
        var substract : Point = targetGlobalPoint.subtract(stageCenter);
        var offset : Point = new Point();

        if ( substract.x < 0 ) { // left
            arrowRotation = 180;
            if ( substract.y < 0 ) {
                if ( targetGlobalPoint.y < stageQuart.y ) {
                    arrowRotation = -90;
                }
            } else {
                if ( targetGlobalPoint.y > holeTarget.stage.stageHeight - stageQuart.y ) {
                    arrowRotation = 90;
                }
            }
        } else {
            arrowRotation = 0;
            if ( substract.y < 0 ) {
                if ( targetGlobalPoint.y < stageQuart.y ) {
                    arrowRotation = -90;
                }
            } else {
                if ( targetGlobalPoint.y > holeTarget.stage.stageHeight - stageQuart.y ) {
                    arrowRotation = 90;
                }
            }
        }

        var holeTargetWidth:int = holeTarget.width + _info.holeOffsetWidth;
        var holeTargetHeight:int = holeTarget.height + _info.holeOffsetHeight;
        if ( arrowRotation == 0 ) { // ->
            offset.setTo( 0, holeTargetHeight / 2 );
        } else if ( arrowRotation == 90 ) { // A
            offset.setTo( holeTargetWidth / 2, 0 );
        } else if ( arrowRotation == -90 ) {
            offset.setTo( holeTargetWidth / 2, holeTargetHeight ); // V
        } else if ( arrowRotation == 180 ) {
            offset.setTo( holeTargetWidth, holeTargetHeight / 2 ); // <-
        }

        // offset.setTo( holeTarget.width / 2, holeTarget.height / 2 );
        if (_info.holeOffsetX != 0) {
            offset.x += _info.holeOffsetX;
        }
        if (_info.holeOffsetY != 0) {
            offset.y += _info.holeOffsetY;
        }

        if (isFirst) {
            var targetPosX:int = targetGlobalPoint.x + offset.x;
            var targetPosY:int = targetGlobalPoint.y + offset.y;
            var fDistance:Number = CMath.lengthVector2(pTutorUI.arrow_right.x, pTutorUI.arrow_right.y, targetPosX, targetPosY);
            if (fDistance > 50) {
                _isTweening = true;
                pTutorUI.arrow_right.alpha = 0.4;
                TweenLite.to(pTutorUI.arrow_right, 0.5, {alpha:1, x:targetPosX, y:targetPosY, rotation:arrowRotation, onComplete:function () : void {
                    _isTweening = false;
                }});
            } else {
                pTutorUI.arrow_right.setPosition( targetGlobalPoint.x + offset.x, targetGlobalPoint.y + offset.y );
                pTutorUI.arrow_right.rotation = arrowRotation;
            }
        } else {
            pTutorUI.arrow_right.setPosition( targetGlobalPoint.x + offset.x, targetGlobalPoint.y + offset.y );
            pTutorUI.arrow_right.rotation = arrowRotation;
        }

        // 圆圈特效
        offset.setTo( holeTargetWidth / 2, holeTargetHeight / 2 );
        if (_info.circleEffectOffsetX != 0) {
            offset.x += _info.circleEffectOffsetX;
        }
        if (_info.circleEffectOffsetY != 0) {
            offset.y += _info.circleEffectOffsetY;
        }
        _ui.hole_effect_box.x = targetGlobalPoint.x + offset.x;
        _ui.hole_effect_box.y = targetGlobalPoint.y + offset.y;
    }

    public function get holeTarget() : Component {
        return _pHoleTarget;
    }

    public function get bigEffectBox() : Box {
        return _ui.big_hole_effect_box;
    }
    public function get bigEffect() : FrameClip {
        return _ui.big_hole_effect;
    }

    public function get arrowX() : int {
        return _ui.arrow_right.x;
    }
    public function get arrowY() : int {
        return _ui.arrow_right.y;
    }
    public function get arrowRotation() : Number {
        return _ui.arrow_right.rotation;
    }

    public function get visible() : Boolean {
        return _ui.visible;
    }
    public function set visible(v:Boolean) : void {
        if (_forceHide) {
            _ui.visible = false;
            return ;
        }

        _ui.visible = v;
        if (v) {
            if (_ui && _ui.stage == null) {
                var pUISys : CUISystem = uiCanvas as CUISystem;
                pUISys.tutorArrowLayer.addChild( _ui );
            }
        }

    }

    public function showBigEffect() : void {
        if (!_bigEffectPlayCompletedHandler) {
            _bigEffectPlayCompletedHandler = new Handler(_playBigEffectCompleted)
        }
        bigEffectBox.visible = true;
        bigEffectBox.x = _ui.hole_effect_box.x;
        bigEffectBox.y = _ui.hole_effect_box.y;
        bigEffect.playFromTo(null, null, _bigEffectPlayCompletedHandler)
    }
    private function _playBigEffectCompleted() : void {
        hideBigEffect();
    }
    public function hideBigEffect() : void {
        bigEffectBox.visible = false;
        bigEffect.stop();
    }

    public function isTweening() : Boolean {
        return _isTweening;
    }
    public function setForceHide(v:Boolean) : void {
        _forceHide = v;
        if (v) {
            visible = false;
        }
    }
    private var _bigEffectPlayCompletedHandler:Handler;
    private var _forceHide:Boolean;
}
}
