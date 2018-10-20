//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/10/24.
 */
package kof.game.bag.view {

import kof.framework.CViewHandler;
import kof.game.bag.CBagManager;
import kof.game.bag.data.CBagConst;
import kof.game.bag.data.CBagData;
import kof.util.CQualityColor;
import kof.ui.demo.Bag.BagItemTipsUI;

import morn.core.components.View;

public class CBagItemTipsHandler extends CViewHandler {

    private var m_bagItemTipsUI:BagItemTipsUI;
    private var m_tipsObj:View;

    public function CBagItemTipsHandler() {
        super();
        if(!m_bagItemTipsUI)
            m_bagItemTipsUI = new BagItemTipsUI();
    }
    public function addTips(tipsObj:View):void{
        m_tipsObj = tipsObj;
        if(m_tipsObj.dataSource){
            m_bagItemTipsUI.mc_item.img.url = m_tipsObj.dataSource.item.bigiconURL + ".png";
            m_bagItemTipsUI.mc_item.clip_bg.index = m_tipsObj.dataSource.item.quality ;
            m_bagItemTipsUI.txt_name.text = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[m_tipsObj.dataSource.item.quality] + "'>" + m_tipsObj.dataSource.item.name + "</font>";
            var typeName:String ;
            m_tipsObj.dataSource.item.typeDisplay == 99 ? typeName = CBagConst.TYPE_ARY[CBagConst.TYPE_ARY.length - 1] : typeName = CBagConst.TYPE_ARY[m_tipsObj.dataSource.item.typeDisplay];
            m_bagItemTipsUI.txt_type.text = "[" + typeName + "]";
            var bagData:CBagData = _pBagManager.getBagItemByUid(m_tipsObj.dataSource.itemID);
            var num:int;
            if(bagData)
                num  = bagData.num;
            m_bagItemTipsUI.txt_num.text = "拥有：" + num + "件";
            m_bagItemTipsUI.txt_cont.text =  m_tipsObj.dataSource.item.literatureDescription;
            if(m_tipsObj.dataSource.item.canSell)
                m_bagItemTipsUI.txt_price.text = "出售单价:" + m_tipsObj.dataSource.item.sellPrice;
            else
                m_bagItemTipsUI.txt_price.text = "该物品不可出售";

            App.tip.addChild(m_bagItemTipsUI);
        }
    }
    public function hideTips():void{
        m_bagItemTipsUI.remove();
    }

    private function get _pBagManager():CBagManager{
        return system.getBean(CBagManager) as CBagManager;
    }
}
}
