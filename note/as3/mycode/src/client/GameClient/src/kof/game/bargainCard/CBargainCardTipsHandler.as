//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/9/10.
 */
package kof.game.bargainCard {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.table.CardMonthConfig;
import kof.ui.imp_common.RewardTipsItemUI;
import kof.ui.master.BargainCard.BargainCardTipsUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CBargainCardTipsHandler extends CViewHandler {

    private var m_barginCardTipsUI:BargainCardTipsUI;
    private var TITLE_STR_ARY:Array = ['白银宝箱','黄金宝箱'];
    private var TIPS_STR_ARY:Array = ['开通白银月卡可获得','开通黄金月卡可获得'];

    public function CBargainCardTipsHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
        if(!m_barginCardTipsUI){
            m_barginCardTipsUI = new BargainCardTipsUI();
            m_barginCardTipsUI.reward_list.renderHandler = new Handler( renderItem );
        }

    }
    public function addTips(type : int  ):void{

        m_barginCardTipsUI.txt_title.text = TITLE_STR_ARY[type - 1];
        m_barginCardTipsUI.tips_txt.text = TIPS_STR_ARY[type - 1];

        var pTable : IDataTable ;
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CARD_MONTH_CONFIG );
        var cardMonthConfig : CardMonthConfig = pTable.findByPrimaryKey( type );//1是白银，2是黄金 ;
        var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( system.stage, cardMonthConfig.rewardBagID );
        m_barginCardTipsUI.reward_list.dataSource = rewardListData.list;

        App.tip.addChild(m_barginCardTipsUI);
    }

    private function renderItem(item:Component, idx:int):void {
        if ( !(item is RewardTipsItemUI) ) {
            return;
        }
        var pTaskItemUI : RewardTipsItemUI = item as RewardTipsItemUI;
        var pRewardData : CRewardData = pTaskItemUI.dataSource as CRewardData;
        if ( pRewardData ) {
            pTaskItemUI.hasTakeImg.visible = false;
            pTaskItemUI.box_eff.visible = pRewardData.effect;
            pTaskItemUI.icon_image.url = pRewardData.iconSmall;
            pTaskItemUI.bg_clip.index = pRewardData.quality;
            pTaskItemUI.num_lable.text = pRewardData.num.toString();
            pTaskItemUI.name_txt.text = pRewardData.name;
//            pTaskItemUI.type_txt.text = CItemSystem.getItemTypeNameByType(pRewardData.typeDisplay);
        }
    }
    public function hideTips():void{
        m_barginCardTipsUI.remove();
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
