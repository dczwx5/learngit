//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/6.
 * Time: 15:40
 */
package kof.game.player.view.batchUse {

import flash.utils.Timer;

import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.enum.EPlayerWndResType;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.ui.IUICanvas;
import kof.ui.master.messageprompt.MPBatchUseUI;

import morn.core.handlers.Handler;

public class CMPBatchUseViewHandler extends CRootView{
    private var _itemNu:int = 0;
    public function CMPBatchUseViewHandler() {
        super(MPBatchUseUI , null, EPlayerWndResType.ITEM_BATCH_USE, false);
    }

    protected override function _onShow():void
    {
        super._onShow();
        var ui:MPBatchUseUI = rootUI as MPBatchUseUI;
        ui.btn_ok.clickHandler = new Handler(_levelupFunc);
        ui.btn_min.clickHandler = new Handler(_minNuFunc);
        ui.btn_max.clickHandler = new Handler(_maxNuFunc);
        ui.slider.min = 1;
    }

    protected override function _onHide() : void
    {
        super._onHide();
    }

    public override function updateWindow() : Boolean
    {
        if (super.updateWindow() == false) return false;
        var url:String = _data.url;
        var nu:int = _data.nu;
        var ui:MPBatchUseUI = rootUI as MPBatchUseUI;
//        ui.itemIco.img.url = url;
//        ui.itemIco.txt.text = 1+"";
//        ui.itemIco.btn.visible = false;
//        ui.itemIco.blackbg.visible = false;
        ui.txt_name.text = "药水名字";
        ui.slider.max = nu;
        ui.slider.value = 1;
        ui.slider.tick = 1;
        ui.slider.lable.color = 0xffffff;
        ui.slider.changeHandler = new Handler(_sliderHandler);
        ui.slider.scrollCompleteHandler = new Handler(_sliderComplete);
        _itemNu = ui.slider.value;
        this.addToPopupDialog();
        return true;
    }

    override public function setData(value:Object, forceInvalid:Boolean = true):void
    {
        super.setData(value, forceInvalid);
    }

    private function _sliderComplete():void
    {
        var ui:MPBatchUseUI = rootUI as MPBatchUseUI;
        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EPlayerViewEventType.EVENT_BATCH_USE_CHANGE_ITEM_NUM,{value:ui.slider.value}));
    }

    private function _sliderHandler(value:int):void
    {
        var ui:MPBatchUseUI = rootUI as MPBatchUseUI;
//        ui.itemIco.txt.text = value+"";
        _itemNu = value;

    }

    private function _levelupFunc():void
    {
        var heroID:int = _data.heroID;
        //升级
        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EPlayerViewEventType.EVENT_HERO_TRAIN_LEVELUP,{id:heroID,itemArr:[{itemID:_data.itemID,num:_itemNu}]}));
        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EPlayerViewEventType.EVENT_HERO_TRAIN_LEVELUP,{itemID:_data.itemID,num:_itemNu}));
        _onClose();
    }

    private function _minNuFunc():void
    {
        var ui:MPBatchUseUI = rootUI as MPBatchUseUI;
        ui.slider.value = 1;
        _sliderComplete();
    }

    private function _maxNuFunc():void
    {
        var nu:int = _data.nu;
        var ui:MPBatchUseUI = rootUI as MPBatchUseUI;
        ui.slider.value = nu;
        _sliderComplete();
    }

    override protected function _onClose():void
    {
        var ui:MPBatchUseUI = rootUI as MPBatchUseUI;
        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EPlayerViewEventType.EVENT_BATCH_USE_CHANGE_ITEM_NUM,{value:0}));
        super._onClose();
    }
}
}
