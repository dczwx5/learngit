//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/10/24.
 */
package kof.game.bag.view {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.bag.CBagHandler;
import kof.game.bag.CBagManager;
import kof.game.bag.data.CBagData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.ui.demo.Bag.OptionalBonusUI;
import kof.ui.demo.Bag.QualityBoxUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/** 可选奖励 */
public class CBageOptionalBonusHandler extends CViewHandler {

    private var m_optionalBonusUI:OptionalBonusUI;//可选界面
    private var label:String;
    private var m_bagData:CBagData;
    private var curQualityBoxUI:QualityBoxUI;

    public function CBageOptionalBonusHandler() {
        super();
    }
    public function show(label:String,bagData:CBagData):void{
        this.label = label;
        m_bagData = bagData;
        if(!m_optionalBonusUI){
            m_optionalBonusUI = new OptionalBonusUI();
            m_optionalBonusUI.list.renderHandler = new Handler( renderItemOnOptional );
            m_optionalBonusUI.list.mouseHandler = new Handler( listItemSelectOnOptionalHandler );
            m_optionalBonusUI.closeHandler = new Handler( _onClose );
        }
        showOptionalBonusUI();
    }
    private function showOptionalBonusUI():void{

        uiCanvas.addPopupDialog(m_optionalBonusUI);
        _addEventListeners();

        var i:int;
        var ary:Array = [];
        var bagData:Object;
        for(i = 1 ; i <= 8 ; i++ ){
            if(m_bagData.item["param" + i]){
                bagData = {};
                if(i%2 == 0){
                    bagData.itemID = m_bagData.item["param" + (i-1)];
                    bagData.param = m_bagData.item["param" + i];
                    bagData.item = _pBagManager.getItemTableByID(int(bagData.itemID));
                    ary.push(bagData);
                }
            }
        }
        m_optionalBonusUI.list.dataSource = ary;
        m_optionalBonusUI.slider.min = 1;
        m_optionalBonusUI.slider.max = m_bagData.num;
        m_optionalBonusUI.slider.value = m_bagData.num;
        m_optionalBonusUI.slider.showLabel = false;
        _onUpdateOptionalSlider();
    }

    private function renderItemOnOptional(item:Component, idx:int):void {
        if ( !(item is QualityBoxUI) ) {
            return;
        }
        var pQualityBoxUI : QualityBoxUI = item as QualityBoxUI;
        if(pQualityBoxUI.dataSource){
            pQualityBoxUI.img.url = item.dataSource.item.smalliconURL + ".png";
            pQualityBoxUI.clip_bg.index = item.dataSource.item.quality ;
            pQualityBoxUI.txt_num.text = (pQualityBoxUI.dataSource.param * m_optionalBonusUI.slider.value).toString();
            pQualityBoxUI.box_eff.visible = item.dataSource.item.effect;
        }

        pQualityBoxUI.toolTip = new Handler(showTips, [pQualityBoxUI]);
    }
    private function listItemSelectOnOptionalHandler( evt:Event,idx : int ) : void {
        curQualityBoxUI = m_optionalBonusUI.list.getCell( idx ) as QualityBoxUI;
        if ( evt.type == MouseEvent.CLICK ) {
            if(curQualityBoxUI.dataSource){
                for each( var cell:QualityBoxUI in m_optionalBonusUI.list.cells){
                    cell.img_selected.visible = (cell == curQualityBoxUI);
                }
            }
        }
    }

    private function showTips(item:QualityBoxUI):void {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }
    private function _onUpdateOptionalSlider(evt:Event = null):void{
        m_optionalBonusUI.txt_num.text = label + ":" + m_optionalBonusUI.slider.value + "/" + m_bagData.num;
        m_optionalBonusUI.btn_max.disabled = (m_optionalBonusUI.slider.value >= m_bagData.num);
        m_optionalBonusUI.btn_min.disabled = (m_optionalBonusUI.slider.value <= 1);
        for each(var pQualityBoxUI:QualityBoxUI in m_optionalBonusUI.list.cells){
            if(pQualityBoxUI.dataSource)
                pQualityBoxUI.txt_num.text = (pQualityBoxUI.dataSource.param * m_optionalBonusUI.slider.value).toString();
        }
    }
    private function _onChangeOptionalNum(evt:MouseEvent):void{
        if(evt.currentTarget == m_optionalBonusUI.btn_min){
            m_optionalBonusUI.slider.value = 1;
        }else if(evt.currentTarget == m_optionalBonusUI.btn_max){
            m_optionalBonusUI.slider.value = m_bagData.num;
        }
    }

    private function _onApplyHandler():void{
        if(!curQualityBoxUI)
                return;
        _pBagHandler.onItemUseRequest(m_bagData.uid,m_optionalBonusUI.slider.value,curQualityBoxUI.dataSource.itemID );
    }

    private function _addEventListeners():void{
        m_optionalBonusUI.btn_min.addEventListener(MouseEvent.CLICK ,_onChangeOptionalNum , false , 0, true );
        m_optionalBonusUI.btn_max.addEventListener(MouseEvent.CLICK ,_onChangeOptionalNum , false , 0, true );
        m_optionalBonusUI.slider.addEventListener(Event.CHANGE, _onUpdateOptionalSlider);
    }
    private function _removeEventListeners():void{
        if(m_optionalBonusUI){
            m_optionalBonusUI.btn_min.removeEventListener(MouseEvent.CLICK , _onChangeOptionalNum );
            m_optionalBonusUI.btn_max.removeEventListener(MouseEvent.CLICK , _onChangeOptionalNum );
            m_optionalBonusUI.slider.removeEventListener(Event.CHANGE, _onUpdateOptionalSlider);
        }
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            case Dialog.CLOSE:
                break;
            case Dialog.OK:
                _onApplyHandler();
                break;
        }
        _removeEventListeners();
    }

    private function get _pBagHandler():CBagHandler{
        return  system.getBean( CBagHandler ) as CBagHandler;
    }
    private function get _pBagManager():CBagManager{
        return system.getBean(CBagManager) as CBagManager;
    }
}
}
