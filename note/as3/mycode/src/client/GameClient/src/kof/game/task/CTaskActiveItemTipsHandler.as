//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/23.
 */
package kof.game.task {

import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.TaskActive;
import kof.ui.IUICanvas;
import kof.ui.master.task.TaskActiveTipsUI;

import morn.core.components.View;

public class CTaskActiveItemTipsHandler extends CViewHandler {

    private var m_taskActiveTipsUI:TaskActiveTipsUI;
    private var m_tipsObj:View;
    private var taskActive : TaskActive;
    private var m_viewExternal:CViewExternalUtil;

    public function CTaskActiveItemTipsHandler() {
        super();
        if(!m_taskActiveTipsUI)
            m_taskActiveTipsUI = new TaskActiveTipsUI();
    }
    public function addTips(tipsObj:View):void{
        m_tipsObj = tipsObj;
        taskActive = m_tipsObj.dataSource as TaskActive;
        if(taskActive){
            m_taskActiveTipsUI.reward_title_txt.text = "活跃度值达到" + taskActive.active + "可以领取奖励";
            if( pCPlayerData.taskData.dailyQuestActiveRewards.indexOf( taskActive.ID ) != -1 ){
                m_taskActiveTipsUI.txt_state.text = "已领取";
            }else if( pCPlayerData.taskData.dailyQuestActiveValue >= taskActive.active ){
                m_taskActiveTipsUI.txt_state.text = "可领取";
            }else{
                m_taskActiveTipsUI.txt_state.text = "未达成";
            }
            if(!m_viewExternal)
                m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, m_taskActiveTipsUI);
            m_viewExternal.show();
            m_viewExternal.setData(taskActive.reward);
            m_viewExternal.updateWindow();

            App.tip.addChild(m_taskActiveTipsUI);
        }
    }
    public function hideTips():void{
        m_taskActiveTipsUI.remove();
    }

    private function get pCPlayerData():CPlayerData{
        var playerManager:CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
        return  playerManager.playerData;
    }
}
}
