//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm.view.gmView {

import flash.display.DisplayObjectContainer;

import kof.game.common.view.CRootView;
import kof.game.gm.data.CGmData;
import kof.ui.CUISystem;
import kof.ui.gm.GMViewUI;

public class CGmView extends CRootView {

    public function CGmView() {
        super(GMViewUI, [CGmLevelView, CGmBaseView, CGmActionView, CGmSkillView, CGmPropertyView], null, false);
    }

    protected override function _onCreate() : void {
    }

    protected override function _onHide() : void {

    }
    protected override function _onShow() : void {
        // do thing when show
        super._onShow();
        selectPanel(0);
    }

    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        this.setChildrenData(data, forceInvalid);
        super.setData(data, forceInvalid);
    }

    private var _parent:DisplayObjectContainer;
    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_parent == null) {
            if (this._initialArgs && _initialArgs.length > 0) {
                _parent = _initialArgs[0];
            }
        }
        if (_parent) {
            this.addToParent(_parent);
        } else {
            this.addToRoot();
        }

        return true;
    }

    public function get gmData() : CGmData {
        return _data as CGmData;
    }

    public function selectPanel(panelID:int) : void {
        var child:CGmChildView = this.getChild(panelID) as CGmChildView;
        if (child == null) return ;
        var prePreChild:CGmChildView;
        for (var i:int = 0; i < this.childList.length; i++) {
            child = childList[i];
            if (panelID == i) {
                child.enable = true;
            } else {
                child.enable = false;
            }
            if (i != 0) {
                if (i % 2 == 0) {
                    child.panel.x = 0;
                    prePreChild = childList[i-2];
                    child.panel.y = prePreChild.panel.y + prePreChild.panel.height + 10;
                } else {
                    if (_parent && _parent.stage) {
                        child.panel.x = _parent.stage.stageWidth/2;
                    } else {
                        child.panel.x = 400;
                    }
                    if (i-2 < 0) {
                        child.panel.y = 0;
                    } else {
                        prePreChild = childList[i-2];
                        child.panel.y = prePreChild.panel.y + prePreChild.panel.height + 10;
                    }
                }
            }
//            if (i != 0) {
//                var preChild:CGmChildView = childList[i-1];
//                child.panel.y = preChild.panel.y + preChild.panel.height + 20;
//            }
//            child.panel.x = 0;
        }
    }

//    private function _onShowGMView() : void {
//        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SWITCH_GM_VIEW));
//    }
    private function get _levelView() : CGmLevelView { return this.getChild(0) as CGmLevelView; }
    private function get _baseView() : CGmBaseView { return this.getChild(1) as CGmBaseView; }
    public function get actionView() : CGmActionView { return this.getChild(2) as CGmActionView; }
    private function get _skillView() : CGmSkillView { return this.getChild(3) as CGmSkillView; }
    private function get _propertyView() : CGmPropertyView { return this.getChild(4) as CGmPropertyView; }

    private function get _ui() : GMViewUI {
        return rootUI as GMViewUI;
    }
}
}


