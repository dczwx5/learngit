//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/13.
 */
package kof.game.endlessTower.view {

import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;

public class CEndlessTowerResultViewHandler extends CMultiplePVPResultViewHandler {
    public function CEndlessTowerResultViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function _initView():void
    {
        super._initView();

        m_pViewUI.img_upRank.visible = false;
        m_pViewUI.num_changeValue_self.visible = false;
        m_pViewUI.img_currRank.visible = false;
        m_pViewUI.num_currRank.visible = false;
        m_pViewUI.txt_selfRankLabel.visible = false;
        m_pViewUI.txt_value_self.visible = false;
        m_pViewUI.clip_arrow_self.visible = false;
        m_pViewUI.txt_enemyRankLabel.visible = false;
        m_pViewUI.txt_value_enemy.visible = false;
        m_pViewUI.clip_arrow_enemy.visible = false;

        if(m_pData && m_pData.rewards.length)
        {
            m_pViewUI.img_getReward.visible = true;
        }
        else
        {
            m_pViewUI.img_getReward.visible = false;
        }
    }
}
}
