//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/28.
 * Time: 14:48
 */
package kof.game.clubBoss.view {

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.game.bag.data.CBagData;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.table.ClubBossRankReward;
import kof.table.ClubBossRankSingle;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.clubBoss.CBRankItemUI;
import kof.ui.master.clubBoss.KillRewardUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/28
 * 排行奖励
 */
public class CRewardRank {
    private var _mainUI : CCBMainView = null;
    private var _rankReward : KillRewardUI = null;
    private var _cbDataManager : CCBDataManager = null;
    private var _cbTips : CCBItemTips = null;
    private var _rankSingleArr : Array = [];
    private var _rankClubArr : Array = [];
    private var _currentTabIndex : int = 0;

    public function CRewardRank( mainUI : CCBMainView ) {
        this._mainUI = mainUI;
        this._cbDataManager = this._mainUI.system.getBean( CCBDataManager ) as CCBDataManager;
        _cbTips = new CCBItemTips();
        _cbTips.appSystem = mainUI.system;
        _init();
    }

    private function _init() : void {
        _rankReward = new KillRewardUI();
        _rankReward.tabBtn.selectHandler = new Handler( _tabHandler );
        //初始化表
        var dataBaseSys : CDatabaseSystem = this._mainUI.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var rankSingleTable : CDataTable = dataBaseSys.getTable( KOFTableConstants.CLUBBOSSRANKSINGLE ) as CDataTable;
        _rankSingleArr = rankSingleTable.toArray();
        rankSingleTable = dataBaseSys.getTable( KOFTableConstants.CLUBBOSSRANKREWARD ) as CDataTable;
        _rankClubArr = rankSingleTable.toArray();
        _rankReward.rankList.renderHandler = _rankReward.rankList.renderHandler || new Handler( _renderRankList );
        _rankReward.rankList.dataSource = _rankSingleArr;
    }

    private function _tabHandler( idx : int ) : void {
        _currentTabIndex = idx;
        if ( idx == 0 ) {
            _rankReward.rankList.dataSource = _rankSingleArr;
        } else {
            _rankReward.rankList.dataSource = _rankClubArr;
        }
    }

    private function _renderRankList( comp : Component, idx : int ) : void {
        var itemUI : CBRankItemUI = comp as CBRankItemUI;
        var data : Object = null;
        if ( _currentTabIndex == 0 ) {
            data = comp.dataSource as ClubBossRankSingle;
        } else {
            data = comp.dataSource as ClubBossRankReward;
        }
        if ( !data )return;
        if ( data.rankMin == data.rankMax ) {
            itemUI.rnk1Box.visible = false;
            itemUI.rnk2Box.visible = false;
            itemUI.rnk3Box.visible = false;
            itemUI.rnk4Box.visible = false;
            itemUI.rnkNu.visible = true;
            itemUI.rnkNu.num = data.rankMin;
        } else {
            itemUI.rnkNu.visible = false;
            if ( data.rankMin < 10 ) {
                itemUI.rnk1Box.visible = true;
                itemUI.rnk2Box.visible = false;
                itemUI.rnk3Box.visible = false;
                itemUI.rnk4Box.visible = false;
                itemUI.rnk1f.num = data.rankMin;
                itemUI.rnk1b.num = data.rankMax;
            } else if ( data.rankMin < 100 ) {
                itemUI.rnk1Box.visible = false;
                itemUI.rnk2Box.visible = true;
                itemUI.rnk3Box.visible = false;
                itemUI.rnk4Box.visible = false;
                itemUI.rnk2f.num = data.rankMin;
                itemUI.rnk2b.num = data.rankMax;
            } else if ( data.rankMin < 2000 ) {
                itemUI.rnk1Box.visible = false;
                itemUI.rnk2Box.visible = false;
                itemUI.rnk3Box.visible = true;
                itemUI.rnk4Box.visible = false;
                itemUI.rnk3f.num = data.rankMin;
                itemUI.rnk3b.num = data.rankMax;
            } else {
                itemUI.rnk1Box.visible = false;
                itemUI.rnk2Box.visible = false;
                itemUI.rnk3Box.visible = false;
                itemUI.rnk4Box.visible = true;
                itemUI.rnk4.num = data.rankMin;
            }
        }
        itemUI.rewardList.renderHandler = itemUI.rewardList.renderHandler || new Handler( _renderRewardItemList );
        var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( this._mainUI.system.stage, data.rewardID );
        var itemListArr : Array = rewardListData.list;
        itemUI.rewardList.dataSource = itemListArr;
        itemUI.rewardList.repeatX = itemListArr.length;
        itemUI.rewardList.centerX = 0;
    }

    private function _renderRewardItemList( comp : Component, idx : int ) : void {
        var itemUI : RewardItemUI = comp as RewardItemUI;
        var data : CRewardData = comp.dataSource as CRewardData;
        if ( !data )return;
        itemUI.bg_clip.index = data.quality;
        itemUI.icon_image.url = data.iconSmall;
        itemUI.num_lable.text = data.num + "";
        itemUI.box_eff.visible = data.effect;
        if(data.quality>=4){
            itemUI.clip_eff.play();
        }
        var goods : GoodsItemUI = new GoodsItemUI();
        goods.img.url = data.iconBig;
        goods.quality_clip.index = data.quality;
        var bagData : CBagData = this._cbDataManager.getItemNuForBag( data.ID );
        if ( bagData ) {
            goods.txt.text = bagData.num + "";
        } else {
            goods.txt.text = "0";
        }
        itemUI.toolTip = new Handler( _showItemTips, [ goods, data.ID ] );
    }

    private function _showItemTips( goods : GoodsItemUI, id : int ) : void {
        _cbTips.showItemTips( goods, this._cbDataManager.getItemTableData( id ), this._cbDataManager.getItemData( id ) );
    }

    public function show() : void {
        this._mainUI.uiContainer.addPopupDialog( _rankReward );//排名奖励
    }
}
}
