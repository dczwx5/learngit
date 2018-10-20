//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package view {

import QFLib.Math.CVector3;

import kof.ui.master.BattleTutor.BTKeyboardUI;

import morn.core.components.FrameClip;

public class CWSADViewHandler extends CBattleTutorViewHandlerBase {
    public function CWSADViewHandler() {
        super(BTKeyboardUI);
    }
    override public function get viewClass():Array {
        return [BTKeyboardUI];
    }
    public function get ui():BTKeyboardUI {
        return getUI() as BTKeyboardUI;
    }
    protected override function get additionalAssets() : Array {
        return ["frameclip_xszy.swf", "frameclip_zy.swf"]; // 加载战斗引导的其他资源
    }

    override public function dispose():void {
        super.dispose();
    }

    protected override function _onRemoved() : void {
        if (_arrowClip) {
            if (_arrowClip.parent) _arrowClip.parent.removeChild(_arrowClip);
            _arrowClip = null;
        }
        if (_posTargetClip) {
            if (_posTargetClip.parent) _posTargetClip.parent.removeChild(_posTargetClip);
            _posTargetClip = null;
        }
        if (_circleClip) {
            if (_circleClip.parent) _circleClip.parent.removeChild(_circleClip);
            _circleClip = null;
        }
    }

    protected override function _onAdded() : void {
        super._onAdded();

        if (!_arrowClip) {
            _arrowClip = new FrameClip();
            _arrowClip.autoPlay = true;
            _arrowClip.interval = 32;
            _arrowClip.skin = "frameclip_jiantou";
            _arrowClip.centerX = 0;
            _arrowClip.centerY = 280;
        }

        if (!_posTargetClip) {
            _posTargetClip = new FrameClip();
            _posTargetClip.interval = 32;
            _posTargetClip.autoPlay = true;
            _posTargetClip.skin = "frameclip_zhiyindianji";
        }


        if (!_circleClip) {
            _circleClip = new FrameClip();
            _circleClip.interval = 32;
            _circleClip.skin = "frameclip_zhiyindianjiguangquan";
        }

    }

    public var _arrowClip:FrameClip;
    public var _posTargetClip:FrameClip;
    public var _circleClip:FrameClip;

    public var _startHeroPos:CVector3;
    public var _targetPos:CVector3;
}
}
