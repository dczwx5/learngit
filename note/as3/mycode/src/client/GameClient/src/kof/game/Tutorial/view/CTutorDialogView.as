//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/8/17.
 */
package kof.game.Tutorial.view {

import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.data.CTutorData;
import kof.game.Tutorial.enum.ETutorWndResType;
import kof.game.common.view.CRootView;
import kof.game.player.data.CPlayerData;
import kof.ui.CUISystem;
import kof.ui.master.NoviceTutor.NTNpcUI;

public class CTutorDialogView extends CRootView {

    public function CTutorDialogView() {
        super(NTNpcUI, null, ETutorWndResType.TUTOR, false);
    }

    protected override function _onCreate() : void {

    }

    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {

    }

    protected override function _onHide() : void {
        _actionInfo = null;
    }

    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _actionInfo = _initialArgs[0];
        if (_actionInfo) {
            _ui.desc_txt.text = _actionInfo.dialogTxt;
        }

        if (_ui && _ui.stage == null) {
            var pUISys : CUISystem = uiCanvas as CUISystem;
            pUISys.tutorLayer.addChild( _ui );
        }

        return true;
    }

    public function updatePosition(actionInfo:CTutorActionInfo, arrowX:int, arrowY:int, arrowRotation:Number, hasArrow:Boolean) : void {
        if (_actionInfo != actionInfo) {
            _actionInfo = actionInfo;
            if (_actionInfo) {
                _ui.desc_txt.text = _actionInfo.dialogTxt;
            }
        }

        if (!hasArrow && _ui.stage) {
            _ui.x = (_ui.stage.stageWidth - _ui.width)/2;
            _ui.y = (_ui.stage.stageHeight - _ui.height)/2;
            return ;
        }

        _ui.x = arrowX;
        _ui.y = arrowY;

        var spaceX:int = 0;
        var arrowWidth:int;
        var arrowHeight:int;
        switch (arrowRotation) {
            case 0 : // >
                arrowWidth = 220;
                _ui.x = arrowX - _ui.width/2;
                _ui.y = arrowY - _ui.height - 80;
                break;
            case 90 : // A
                arrowHeight = 220;
                arrowWidth = 80;
                _ui.x = arrowX - arrowWidth - _ui.width - spaceX;
                _ui.y = arrowY - _ui.height/2;
                break;
            case 180 : // <
                arrowWidth = 220;
                _ui.x = arrowX - _ui.width/2;
                _ui.y = arrowY - _ui.height - 80;
                break;
            case -90 : // V
                arrowHeight = 220;
                arrowWidth = 80;
                _ui.x = arrowX - arrowWidth - _ui.width - spaceX;
                _ui.y = arrowY - _ui.height/2 - 30;
                break;
        }

        if (_actionInfo) {
            var offsetX:int = _actionInfo.dialogOffsetX;
            var offsetY:int = _actionInfo.dialogOffsetY;
            if (offsetX != 0) {
                _ui.x += offsetX;
            }
            if (offsetY != 0) {
                _ui.y += offsetY;
            }
        }
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================

    //===================================get/set======================================

    [Inline]
    private function get _ui() : NTNpcUI {
        return rootUI as NTNpcUI;
    }
    [Inline]
    private function get _tutorData() : CTutorData {
        return super._data[0] as CTutorData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
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
    private var _actionInfo:CTutorActionInfo;

    public function setForceHide(v:Boolean) : void {
        _forceHide = v;
        if (v) {
            visible = false;
        }
    }
    private var _forceHide:Boolean;

}
}
