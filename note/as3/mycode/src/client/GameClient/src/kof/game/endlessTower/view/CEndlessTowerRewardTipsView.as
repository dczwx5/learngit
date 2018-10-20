//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/19.
 */
package kof.game.endlessTower.view {

import kof.framework.CViewHandler;
import kof.game.common.CRewardUtil;
import kof.game.common.tips.ITips;
import kof.game.endlessTower.CEndlessTowerHelpHandler;
import kof.game.endlessTower.CEndlessTowerManager;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.ui.master.endlessTower.EndlessTowerRewardTipsUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CEndlessTowerRewardTipsView extends CViewHandler implements ITips{

    private var m_pViewUI:EndlessTowerRewardTipsUI;
    private var m_pTipsObj:Component;
    private var m_pTipsData:Object;

    public function CEndlessTowerRewardTipsView( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ EndlessTowerRewardTipsUI ];
    }

    public function addTips(component:Component, args:Array = null):void
    {
        if ( m_pViewUI == null )
        {
            m_pViewUI = new EndlessTowerRewardTipsUI();
        }

        m_pTipsObj = component;

        var currLayer:int = _manager.baseData.maxPassedLayer;
        var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, _helper.getEveryDayBoxRewardId());
        if(rewardListData)
        {
            var rewardArr:Array = rewardListData.list;
            for each(var itemData:CRewardData in rewardArr)
            {
                itemData.num = currLayer == 0 ? 1 : currLayer;
            }

            if(m_pViewUI.list_item.renderHandler == null)
            {
                m_pViewUI.list_item.renderHandler = new Handler(_helper.renderItem);
            }

            m_pViewUI.list_item.dataSource = rewardArr;
            var listWidth:int = 52*rewardArr.length + 2*(rewardArr.length-1);
            m_pViewUI.list_item.x = m_pViewUI.width - listWidth >> 1;

            m_pViewUI.txt_title.x = m_pViewUI.width - m_pViewUI.txt_title.width >> 1;

            m_pViewUI.img_canTake.visible = _manager.baseData.dayRewardTakeLayer != currLayer;
            m_pViewUI.img_hasTake.visible = _manager.baseData.dayRewardTakeLayer == currLayer;
            m_pViewUI.img_notCompl.visible = false;
        }
        else
        {
            m_pViewUI.list_item.dataSource = [];
            m_pViewUI.img_canTake.visible = false;
            m_pViewUI.img_notCompl.visible = false;
            m_pViewUI.img_hasTake.visible = false;
        }

        App.tip.addChild(m_pViewUI);
    }

    private function clear():void
    {
        m_pViewUI.txt_desc.text = "";
        m_pViewUI.txt_title.text = "";
        m_pViewUI.list_item.dataSource = [];
        m_pViewUI.img_canTake.url = "";
        m_pViewUI.img_notCompl.url = "";
    }

    public function hideTips():void
    {
        if(m_pViewUI)
        {
            m_pViewUI.remove();
        }
    }

    private function get _manager():CEndlessTowerManager
    {
        return system.getHandler(CEndlessTowerManager) as CEndlessTowerManager;
    }

    private function get _helper():CEndlessTowerHelpHandler
    {
        return system.getHandler(CEndlessTowerHelpHandler) as CEndlessTowerHelpHandler;
    }

}
}
