//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial.view {

import kof.game.Tutorial.data.CTutorData;
import kof.game.Tutorial.enum.ETutorWndResType;
import kof.game.common.view.CRootView;
import kof.game.player.data.CPlayerData;
import kof.ui.CUISystem;
import kof.ui.master.tutor.TutorViewUI;

import morn.core.components.Component;

public class CTutorView extends CRootView {

    public function CTutorView() {
        super(TutorViewUI, [CTutorMask], ETutorWndResType.TUTOR, false);
    }

    protected override function _onCreate() : void {
        setNoneData();

    }

    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {

    }

    protected override function _onHide() : void {

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_ui && _ui.stage == null) {
            var pUISys : CUISystem = uiCanvas as CUISystem;
            pUISys.tutorLayer.addChild( _ui );
        }
        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);

    }

    // ====================================event=============================

    //===================================get/set======================================
    public function get maskView() : CTutorMask { return this.getChild(0) as CTutorMask; }
    public function get forceMask() : Component {return _ui.force_mask; }

    [Inline]
    private function get _ui() : TutorViewUI {
        return rootUI as TutorViewUI;
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
        _ui.visible = v;
        if (v) {
            if (_ui && _ui.stage == null) {
                var pUISys : CUISystem = uiCanvas as CUISystem;
                pUISys.tutorLayer.addChild( _ui );
            }
        }
    }
}
}
