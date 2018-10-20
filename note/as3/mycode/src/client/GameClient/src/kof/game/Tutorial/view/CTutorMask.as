//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial.view {

import flash.events.Event;
import flash.geom.Point;

import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.data.CTutorData;
import kof.game.common.view.CChildView;
import kof.game.player.data.CPlayerData;
import kof.ui.master.tutor.TutorMaskUI;
import kof.ui.master.tutor.TutorViewUI;
import kof.util.CAssertUtils;

import morn.core.components.Component;

import morn.core.components.Image;

public class CTutorMask extends CChildView {

    public function CTutorMask() {
    }

    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        _ui.bg_img.addEventListener(Event.RESIZE, _onMaskResize);
        _needRedrawMask = false;
        // can not call super._onShow in this class
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.bg_img.removeEventListener(Event.RESIZE, _onMaskResize);

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) {
            return false;
        }

        return true;
    }

    private var _tempPos:Point;
    // if target is null, reset mask
    public function drawHole(target:Component, actionInfo:CTutorActionInfo, fMaskAlpha : Number = NaN) : void {
        CAssertUtils.assertNotNull(actionInfo);

        if (_lastHoleData == null) {
            _lastHoleData = new HoleData();
        }

        var mask:Image = _ui.bg_img;

        // 不需要蒙板
        if (!actionInfo.hasMask) {
            return ;
        }

        // 还原蒙板
        if (target == null) {
            _resetMask( isNaN( fMaskAlpha ) ? actionInfo.groupInfo.maskAlpha : fMaskAlpha );
            return;
        }

        // 不需要洞
        if (actionInfo.hasHole == false) {
            _resetMask(actionInfo.groupInfo.maskAlpha);
            return ;
        }
        _tempPos = target.localToGlobal(STAGE_LEFT_TOP);

        // draw hole
        var drawHoleFunc:Function;
        if (actionInfo.isRectHoleMask) {
            drawHoleFunc = _unFillRectB;
        } else {
            drawHoleFunc = _unFillCircle;
        }


        var maskWidth:int = target.width + actionInfo.holeOffsetWidth;
        var maskHeight:int = target.height + actionInfo.holeOffsetHeight;
        _tempPos.x += actionInfo.holeOffsetX;
        _tempPos.y += actionInfo.holeOffsetY;



        if (_needRedrawMask || false == _lastHoleData.isSameWith(_tempPos.x, _tempPos.y, maskWidth, maskHeight, actionInfo.isRectHoleMask)) {
            _needRedrawMask = false;
            // draw
            mask.graphics.clear();
            mask.graphics.beginFill(0, actionInfo.groupInfo.maskAlpha);
            mask.graphics.drawRect(0, 0, mask.width, mask.height);
            drawHoleFunc(mask, _tempPos.x, _tempPos.y, maskWidth, maskHeight);
            mask.graphics.endFill();

            _lastHoleData.setData(_tempPos.x, _tempPos.y, maskWidth, maskHeight, actionInfo.isRectHoleMask);
        }
    }
    private function _unFillRectB(mask:Image, x:int, y:int, w:int, h:int) : void {
        mask.graphics.drawRect(x, y, w, h);
    }
    private function _unFillCircle(mask:Image, x:int, y:int, w:int, h:int) : void {
        if (h == 0) {
            h = w;
        }
        mask.graphics.drawEllipse(x, y, w, h);
    }

    private function _resetMask(maskAlpha:Number) : void {
//        if (_lastHoleData.hasHole) {
            var mask:Image = _ui.bg_img;
            mask.graphics.clear();
            mask.graphics.beginFill(0, maskAlpha);
            mask.graphics.drawRect(0, 0, mask.width, mask.height);
            mask.graphics.endFill();
            _lastHoleData.clear();
//        }
    }

    private function _onMaskResize(e:Event) : void {
        _needRedrawMask = true;
    }

    public function get visible() : Boolean {
        return _ui.visible;
    }
    public function set visible(v:Boolean) : void {
        _ui.visible = v;
    }
    public function set alpha(v:Number) : void {
        _ui.alpha = v;
    }
    private function get _mainUI() : TutorViewUI {
        return rootUI as TutorViewUI;
    }
    [Inline]
    private function get _ui() : TutorMaskUI {
        return _mainUI.mask_view;
    }
    [Inline]
    private function get _tutorData() : CTutorData {
        return super._data[0] as CTutorData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _lastHoleData:HoleData; // 用于优化, 上一次画洞的数据
    private var _needRedrawMask:Boolean;
}
}

class HoleData {

    public function setData(x:int, y:int, w:int, h:int, isRect:Boolean) : void {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.isRect = isRect;
    }

    public function isSameWith(x:int, y:int, w:int, h:int, isRect:Boolean) : Boolean {
        return this.x == x && this.y == y && this.w == w && this.h == h && this.isRect == isRect;
    }

    public function get hasHole() : Boolean {
        return x >= 0 && y >= 0 && w > 0 && h > 0;
    }

    public function clear() : void {
        x = y = w = h = -1;
        isRect = false;
    }
    public var x:int;
    public var y:int;
    public var w:int;
    public var h:int;
    public var isRect:Boolean;
}
