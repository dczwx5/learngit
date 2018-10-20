//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm.view.gmView {

import kof.game.common.view.event.CViewEvent;
import kof.game.gm.data.CGmData;
import kof.game.gm.data.CGmPropertyData;
import kof.game.gm.event.EGmEventType;
import kof.ui.gm.GMViewUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CGmPropertyView extends CGmChildView {
    public function CGmPropertyView() {
        super();
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();

    }
    protected override function _onDispose() : void {
        // dispose
        super._onDispose();
    }
    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        super.setData(data, forceInvalid);
    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();


        _ui.property_select_btn.clickHandler = new Handler(_onSelect);
        _ui.property_modify_btn.clickHandler = new Handler(_onModify);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        _ui.property_select_btn.clickHandler = null;
        _ui.property_modify_btn.clickHandler = null;
    }
    private function _onSelect() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SELECT_PANEL, 4));
    }
    private function _onModify() : void {
        var strProperty:String = _ui.property_select_comb.selectedLabel;
        var value:int = (int)(_ui.property_value_txt.text);
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_PROPERTY_MODIFY, [strProperty, value]));
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;
        if(_propertyListData){
            _ui.property_select_comb.dataSource = _propertyListData.propertyList;
        }

        return true;
    }
    public override function set enable(v:Boolean) : void {
        //if (enable == v) return ;
        super.enable = v;
        _ui.property_sub_box.visible = enable;

    }
    public override function get panel() : Component { return _ui.property_box; }
    private function get _propertyListData() : CGmPropertyData {
        return (this._data as CGmData).propertyListData;
    }
    private function get _ui() : GMViewUI {
        return rootUI as GMViewUI;
    }
}
}
