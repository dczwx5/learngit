//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/10/24.
 */
package kof.game.bag.view {

import kof.framework.CViewHandler;
import kof.game.bag.CBagHandler;
import kof.game.bag.CBagManager;
import kof.game.bag.data.CBagData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.table.Item;
import kof.ui.demo.Bag.PropsSynthesisUI;
import kof.ui.demo.Bag.QualityBoxUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/** 物品合成*/
public class CBagPropsSynthesisHandler extends CViewHandler {

    private var m_propsSynthesisUI:PropsSynthesisUI;//合成界面
    private var m_bagData:CBagData;
    private var label:String;
    private var m_maxNum:int;

    public function CBagPropsSynthesisHandler() {
        super();
    }

    public function show(label:String,bagData:CBagData):void{
        this.label = label;
        m_bagData = bagData;
        m_maxNum = _pBagManager.getBagItemByUid(m_bagData.itemID ).num;
        if(!m_propsSynthesisUI){
            m_propsSynthesisUI = new PropsSynthesisUI();
            m_propsSynthesisUI.closeHandler = new Handler( _onClose );
            m_propsSynthesisUI.mc_pre.toolTip = new Handler(showTips, [m_propsSynthesisUI.mc_pre]);
            m_propsSynthesisUI.mc_next.toolTip = new Handler(showTips, [m_propsSynthesisUI.mc_next]);
        }

        showPropsSynthesisUI();
    }

    private function showPropsSynthesisUI():void{

        uiCanvas.addPopupDialog(m_propsSynthesisUI);
        m_propsSynthesisUI.mc_pre.dataSource = m_bagData;
        m_propsSynthesisUI.mc_pre.img.url = m_bagData.item.smalliconURL + ".png";
        m_propsSynthesisUI.mc_pre.clip_bg.index = m_bagData.item.quality ;
        m_propsSynthesisUI.mc_pre.txt_num.text = m_maxNum.toString();
        m_propsSynthesisUI.txt_cont.text = m_bagData.item.param1 + "合1";
        m_propsSynthesisUI.mc_pre.box_eff.visible = m_bagData.item.effect;
        var item:Item = _pBagManager.getItemTableByID(int(m_bagData.item.param2));
        if(item){
            m_propsSynthesisUI.mc_next.img.url = item.smalliconURL + ".png";
            m_propsSynthesisUI.mc_next.clip_bg.index = item.quality ;
            var bagData:Object = {};
            bagData.itemID = int(m_bagData.item.param2);
            bagData.item = item;
            m_propsSynthesisUI.mc_next.dataSource = bagData;
            var n_bagData:CBagData = _pBagManager.getBagItemByUid(bagData.itemID);
            var numStr:String = "" ;
            var num:int = Math.floor(m_maxNum / int(m_bagData.item.param1));
            if(num)
                numStr = num.toString();
            m_propsSynthesisUI.mc_next.txt_num.text = numStr;
            m_propsSynthesisUI.mc_next.box_eff.visible = item.effect;
        }

    }
    private function _onApplyHandler():void{
        if(!m_propsSynthesisUI)
            return;
        if(m_bagData.num < int( m_bagData.item.param1 ) )
                return;
        _pBagHandler.onItemUseRequest(m_bagData.uid );
    }

    private function showTips(item:QualityBoxUI):void {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            case Dialog.CLOSE:
                break;
            case Dialog.OK:
                _onApplyHandler();
                break;
        }
    }

    private function get _pBagHandler():CBagHandler{
        return  system.getBean( CBagHandler ) as CBagHandler;
    }
    private function get _pBagManager():CBagManager{
        return system.getBean(CBagManager) as CBagManager;
    }

}
}
