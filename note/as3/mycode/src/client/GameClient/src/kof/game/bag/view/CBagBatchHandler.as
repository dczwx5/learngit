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
import kof.game.bag.data.CBagConst;
import kof.game.bag.data.CBagData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.ui.demo.Bag.BatchUI;
import kof.ui.demo.Bag.QualityBoxUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/** 批量使用 批量出售 */
public class CBagBatchHandler extends CViewHandler {

    private var m_batchUI:BatchUI;
    private var m_bagData:CBagData;
    private var label:String;

    private var m_maxNum:int;

    public function CBagBatchHandler() {
        super();
    }

    public function show(label:String,bagData:CBagData):void{
        this.label = label;
        m_bagData = bagData;
        m_maxNum = _pBagManager.getBagItemByUid(m_bagData.itemID ).num;
        if(!m_batchUI){
            m_batchUI = new BatchUI();
            m_batchUI.closeHandler = new Handler( _onClose );
            m_batchUI.mc.toolTip = new Handler(showTips, [m_batchUI.mc]);
        }

        showBatchUI();
    }
    private function showBatchUI():void{

        uiCanvas.addPopupDialog( m_batchUI );
        _addEventListeners();
        m_batchUI.mc.dataSource = m_bagData;
        m_batchUI.txt_title.text = CBagConst.TITLE_ARY[CBagConst.MENU_ARY.indexOf(label)];
        m_batchUI.txt_value.visible = m_batchUI.img_glod.visible = (label == CBagConst.SELL_STR);
        if(m_bagData.item){
            m_batchUI.txt_name.text = m_bagData.item.name;
            m_batchUI.mc.img.url = m_bagData.item.smalliconURL + ".png";
            m_batchUI.mc.clip_bg.index = m_bagData.item.quality ;
            //m_batchUI.mc.box_eff.visible = m_bagData.item.effect;
            m_batchUI.mc.txt_num.visible = m_maxNum > 1;
            if( m_batchUI.mc.txt_num.visible )
                m_batchUI.mc.txt_num.text = String( m_maxNum );
            //新增道具扫光判断条件，effect>0且额外配置数量>0时，数量超过配置数量，或者额外配置数量为0时，显示扫光
            //==============================add by Lune 0617 start======================================
            m_batchUI.mc.box_eff.visible = m_bagData.item.effect > 0 ? (m_bagData.item.extraEffect == 0 || m_bagData.num >= m_bagData.item.extraEffect) : false;
            //==============================add by Lune 0617 end========================================
        }

        m_batchUI.slider.min = 1;
        m_batchUI.slider.max = m_maxNum;
        m_batchUI.slider.value = m_maxNum;
        m_batchUI.slider.showLabel = false;
        _onUpdateBatchSlider();
    }
    private function _onUpdateBatchSlider(evt:Event = null):void{
        m_batchUI.txt_num.text = label + ":" + m_batchUI.slider.value + "/" + m_maxNum;
        m_batchUI.txt_value.text = (m_batchUI.slider.value * m_bagData.item.sellPrice).toString();
        m_batchUI.btn_max.disabled = (m_batchUI.slider.value >= m_maxNum);
        m_batchUI.btn_min.disabled = (m_batchUI.slider.value <= 1);
    }
    private function _onChangeBatchNum(evt:MouseEvent):void{
        if(evt.currentTarget == m_batchUI.btn_min){
            m_batchUI.slider.value = 1;
        }else if(evt.currentTarget == m_batchUI.btn_max){
            m_batchUI.slider.value = m_maxNum;
        }
    }
    private function _onApplyHandler():void{
        if(label == CBagConst.USE_STR ){
            _pBagHandler.onItemUseRequest(m_bagData.uid,m_batchUI.slider.value);
        }else if(label == CBagConst.SELL_STR ){
            if(m_bagData.item.canSell)
                _pBagHandler.onItemSellRequest(m_bagData.uid,m_batchUI.slider.value);
            else
                trace("该商品不能出售");
        }
    }

    private function showTips(item:QualityBoxUI):void {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    private function _addEventListeners():void {
        m_batchUI.btn_min.addEventListener(MouseEvent.CLICK ,_onChangeBatchNum , false , 0, true );
        m_batchUI.btn_max.addEventListener(MouseEvent.CLICK ,_onChangeBatchNum , false , 0, true );
        m_batchUI.slider.addEventListener(Event.CHANGE, _onUpdateBatchSlider);
    }
    private function _removeEventListeners():void {
        if(m_batchUI){
            m_batchUI.btn_min.removeEventListener(MouseEvent.CLICK , _onChangeBatchNum );
            m_batchUI.btn_max.removeEventListener(MouseEvent.CLICK , _onChangeBatchNum );
            m_batchUI.slider.removeEventListener(Event.CHANGE, _onUpdateBatchSlider);
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
