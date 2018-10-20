//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/20.
 */
package kof.game.task {

import kof.framework.CViewHandler;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.task.data.CTaskData;
import kof.ui.imp_common.RewardTipsItemUI;
import kof.ui.imp_common.RewardTipsMainUI;

import morn.core.components.Component;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CTaskRewardTipsView extends CViewHandler {

    private var m_pViewUI:RewardTipsMainUI;

    public function CTaskRewardTipsView( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function get viewClass() : Array
    {
        return [ RewardTipsMainUI ];
    }
    public function addTips( taskData : CTaskData  ):void
    {

        if (m_pViewUI == null)
        {
            m_pViewUI = new RewardTipsMainUI();
//            m_pViewUI.list_skill.renderHandler = new Handler(_renderSkillInfo);
            m_pViewUI.reward_list.renderHandler = new Handler(_renderHandler);
        }

        var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, taskData.plotTask.reward );
        m_pViewUI.reward_list.addEventListener( UIEvent.ITEM_RENDER ,_renderCompleted );
        m_pViewUI.reward_list.dataSource = rewardListData.list;
        App.tip.addChild( m_pViewUI );
    }
    private function _renderHandler(item:Component, idx:int):void {
        if ( !(item is RewardTipsItemUI) ) {
            return;
        }
        var pSkillTipsTagUI : RewardTipsItemUI = item as RewardTipsItemUI;
        if ( pSkillTipsTagUI.dataSource ) {
            var rewardData : CRewardData = pSkillTipsTagUI.dataSource as CRewardData;
            pSkillTipsTagUI.hasTakeImg.visible = false;
            pSkillTipsTagUI.name_txt.text = rewardData.nameWithColor;
            pSkillTipsTagUI.icon_image.url = rewardData.iconSmall;
            pSkillTipsTagUI.box_eff.visible = rewardData.effect;
            pSkillTipsTagUI.num_lable.text = rewardData.num.toString();
            pSkillTipsTagUI.bg_clip.index = rewardData.quality;
        }
    }
    private function _renderCompleted( evt : UIEvent ):void{
        m_pViewUI.reward_list.removeEventListener( UIEvent.ITEM_RENDER ,_renderCompleted );
        if( m_pViewUI ){
            m_pViewUI.bg_img.height = m_pViewUI.reward_list.height - 30;
        }
    }
}
}
