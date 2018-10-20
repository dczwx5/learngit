//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/31.
 * Time: 15:30
 */
package kof.game.clubBoss.view {

import flash.utils.clearInterval;
import flash.utils.setInterval;

import kof.framework.CAppSystem;
import kof.game.bag.data.CBagData;
import kof.game.clubBoss.CClubBossSystem;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.view.CCBItemTips;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.globalBoss.CWorldBossSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.clubBoss.FightResultUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/31
 */
public class CCBFightResultView {
    private var _fightResult : FightResultUI = null;
    private var _system : CAppSystem = null;
    private var _uiContainer : IUICanvas = null;
    private var _cbDataManager : CCBDataManager = null;
    private var _cbTips : CCBItemTips = null;

    private var _intervelID : int = 0;

    public function CCBFightResultView( uiContainer : IUICanvas, appSys : CAppSystem ) {
        this._uiContainer = uiContainer;
        _fightResult = new FightResultUI();
        _fightResult.leaveBtn.clickHandler = new Handler( _leaveInstance );
        _system = appSys;
        CClubBossSystem(_system.stage.getSystem( CClubBossSystem )).excuteNotEndLeveInstance = _notEndLeve;
    }

    private function _notEndLeve():void{
        _fightResult.close();
        clearInterval(_intervelID);
    }

    private function _leaveInstance() : void {
        (_system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).exitInstance();
        _fightResult.close();
        clearInterval(_intervelID);
    }

    public function show() : void {
        _uiContainer.addPopupDialog( _fightResult );
        _initView();
    }

    private function _initView() : void {
        _cbTips = new CCBItemTips();
        _cbDataManager = _system.stage.getSystem( CClubBossSystem ).getBean( CCBDataManager ) as CCBDataManager;
        _fightResult.damageProgress.value = _cbDataManager.recordSelfDamage / _cbDataManager.cbFightData.maxHP;
        var damagePercent:int = int(_cbDataManager.recordSelfDamage * 100 / _cbDataManager.cbFightData.maxHP);
        damagePercent=damagePercent>100?100:damagePercent;
        _fightResult.percentLabel.text = damagePercent + "%";
        _fightResult.clubRankLabel.text = _cbDataManager.cbRewardResult.cRank + "";
        _fightResult.rankLabel.text = _cbDataManager.cbRewardResult.rRank + "";
        _fightResult.rewardList.renderHandler = new Handler( _renderItem );
        var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( _system.stage, _cbDataManager.getCBResultRewardRewardID() );
        var itemListArr : Array = rewardListData.list;
        _fightResult.rewardList.repeatX = itemListArr.length;
        _fightResult.rewardList.dataSource = itemListArr;

        var reviveTime : int = 45;
        var shi : int = reviveTime / 10;
        var ge : int = reviveTime % 10;
        _intervelID = setInterval
        ( function () : void {
            reviveTime--;
            if ( reviveTime < 0 ) {
                clearInterval( _intervelID );
                _leaveInstance();
            }
            shi = reviveTime / 10;
            ge = reviveTime % 10;
            _fightResult.cutdownLabel.text = "(00:" + shi + ge + CLang.Get( "autoLeavout" ) + ")";
        }, 1000 );
    }

    private function _renderItem( comp : Component, idx : int ) : void {
        var itemUI : RewardItemUI = comp as RewardItemUI;
        var data : CRewardData = comp.dataSource as CRewardData;
        if ( !data )return;
        itemUI.bg_clip.index = data.quality;
        itemUI.icon_image.url = data.iconSmall;
        itemUI.num_lable.text = data.num + "";

        var goods : GoodsItemUI = new GoodsItemUI();
        goods.img.url = data.iconBig;
        var bagData : CBagData = _cbDataManager.getItemNuForBag( data.ID );
        if ( bagData ) {
            goods.txt.text = bagData.num + "";
        } else {
            goods.txt.text = "0";
        }
        itemUI.toolTip = new Handler( _showItemTips, [ goods, data.ID ] );
    }

    private function _showItemTips( goods : GoodsItemUI, id : int ) : void {
        _cbTips.appSystem = _system.stage.getSystem( CClubBossSystem );
        _cbTips.showItemTips( goods, _cbDataManager.getItemTableData( id ), _cbDataManager.getItemData( id ) );
    }
}
}
