//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/28.
 * Time: 18:10
 */
package kof.game.clubBoss.view {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.game.bag.data.CBagData;
import kof.game.clubBoss.CClubBossHandler;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.enums.EBossStateType;
import kof.game.clubBoss.enums.EClubBossEventType;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.table.ClubBossBase;
import kof.table.Monster;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.JueseAndEqu.RoleItem03UI;
import kof.ui.master.clubBoss.CBBossIconItemUI;
import kof.ui.master.clubBoss.CBKillRewardUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/28
 * 击杀奖励
 */
public class CRewardKill {
    private var _mainUI : CCBMainView = null;
    private var _killReward : CBKillRewardUI = null;
    private var _cbDataManager : CCBDataManager = null;
    private var _cbTips : CCBItemTips = null;
    private var _bossToRewardDic : Dictionary = new Dictionary();
    private var _bossToItemIndex : Dictionary = new Dictionary();
    private var _recordCurBossId : int = 0;
    private var _pNewestTotalItemArr : Array = [];

    public function CRewardKill( mainUI : CCBMainView ) {
        this._mainUI = mainUI;
        this._cbDataManager = this._mainUI.system.getBean( CCBDataManager ) as CCBDataManager;
        _cbTips = mainUI.cbTips;
        this._cbDataManager.addEventListener( EClubBossEventType.CAN_GET_REWARD, _updateUI );
        this._cbDataManager.addEventListener( EClubBossEventType.GET_JOIN_REWARD, _getRewardResponse );
        _init();
    }

    public function _getRewardResponse( e : Event ) : void {
        var errorCode : Number = _cbDataManager.promptID;
        if ( _cbDataManager.promptID != 0 ) {
            this._mainUI.showPrompt( errorCode );
        } else {
            this._mainUI.showPrompt( 703 );
            this._mainUI.net.ifGotDamageRewardRequest();
            _flyTotalItem();
        }
    }

    private function _flyTotalItem() : void {
        var len : int = _pNewestTotalItemArr.length;
        for ( var i : int = 0; i < len; i++ ) {
            var item : Component = _pNewestTotalItemArr[ i ];
            CFlyItemUtil.flyItemToBag( item, item.localToGlobal( new Point() ), this._mainUI.system );
        }
    }

    private function _renderJoinItem( comp : Component, idx : int ) : void {
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

        _pNewestTotalItemArr.push( comp );

        var goods : GoodsItemUI = new GoodsItemUI();
        goods.img.url = data.iconBig;
        var bagData : CBagData = this._cbDataManager.getItemNuForBag( data.ID );
        if ( bagData ) {
            goods.txt.text = bagData.num + "";
        } else {
            goods.txt.text = "0";
        }
        itemUI.toolTip = new Handler( _showItemTips, [ goods, data.ID ] );
    }

    private function _renderKillItem( comp : Component, idx : int ) : void {
        var itemUI : RewardItemUI = comp as RewardItemUI;
        var data : CRewardData = comp.dataSource as CRewardData;
        if ( !data )return;
        itemUI.bg_clip.index = data.quality;
        itemUI.icon_image.url = data.iconSmall;
        itemUI.num_lable.text = data.num + "";
        itemUI.box_eff.visible = data.effect;
//        _pNewestTotalItemArr.push( comp );
        if ( data.quality >= 4 ) {
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

    //领取参与奖
    private function _getJoinReward() : void {
        this._mainUI.net.damageRewardRequest( _recordCurBossId );
    }

    private function _init() : void {
        _killReward = new CBKillRewardUI();
        _killReward.joinItem.list.renderHandler = new Handler( _renderJoinItem );
        _killReward.joinItem.txtClip.index = 1;
        _killReward.joinItem.getedImg.visible = false;

        _recordCurBossId = 1;
        _killReward.joinItem.getRewardBtn.clickHandler = new Handler( _getJoinReward );
        _killReward.killItem.list.renderHandler = new Handler( _renderKillItem );
        _killReward.killItem.txtClip.index = 2;
        _killReward.killItem.getedImg.visible = false;
        _killReward.killItem.getRewardBtn.visible = false;
        //初始化工会boss基础表
        var dataBaseSys : CDatabaseSystem = this._mainUI.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var cbBaseTabel : CDataTable = dataBaseSys.getTable( KOFTableConstants.CLUBBOSSBASE ) as CDataTable;
        var cbBaseArr : Array = cbBaseTabel.toArray();

        var monsterTabel : CDataTable = dataBaseSys.getTable( KOFTableConstants.MONSTER ) as CDataTable;
        for ( var i : int = 0; i < cbBaseArr.length; i++ ) {
            var cbBase : ClubBossBase = cbBaseArr[ i ] as ClubBossBase;
            var bossItemUI : CBBossIconItemUI = this._killReward[ "boss" + (i + 1) ] as CBBossIconItemUI;
            var roleItem : RoleItem03UI = bossItemUI.roleItem;
            roleItem.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath( cbBase.heroId );
            roleItem.icon_image.mask = roleItem.hero_icon_mask;
            bossItemUI.selectImg.visible = false;
            bossItemUI.addEventListener( MouseEvent.CLICK, _selectBoss );
            _bossToRewardDic[ bossItemUI ] = cbBase;
            _bossToItemIndex[ bossItemUI ] = i;
            roleItem.clip_intell.visible = false;
            roleItem.box_star.visible = false;
//            roleItem.clip_career.index = (monsterTabel.findByPrimaryKey( cbBase.monsterId ) as Monster).Profession;
            roleItem.clip_career.visible = false;
            roleItem.mouseChildren = true;
            (_mainUI.system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showCareerTips(roleItem.clip_career);
        }
        _killReward.boss1.selectImg.visible = true;
        var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( this._mainUI.system.stage, cbBaseArr[ 0 ].takePartIn );
        _killReward.joinItem.list.dataSource = rewardListData.list;
        rewardListData = CRewardUtil.createByDropPackageID( this._mainUI.system.stage, cbBaseArr[ 0 ].lastKill );
        _killReward.killItem.list.dataSource = rewardListData.list;
    }

    private function _selectBoss( e : MouseEvent ) : void {
        if ( _cbDataManager.vec_BossInfo.length == 0 )return;
        for ( var i : int = 1; i < 6; i++ ) {
            (this._killReward[ "boss" + i ] as CBBossIconItemUI).selectImg.visible = false;
        }
        var bossItem : CBBossIconItemUI = e.currentTarget as CBBossIconItemUI;
        bossItem.selectImg.visible = true;
        var cbBase : ClubBossBase = _bossToRewardDic[ bossItem ] as ClubBossBase;
        _pNewestTotalItemArr = [];
        //参与奖
        var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( this._mainUI.system.stage, cbBase.takePartIn );
        _killReward.joinItem.list.dataSource = rewardListData.list;
        //击杀奖
        rewardListData = CRewardUtil.createByDropPackageID( this._mainUI.system.stage, cbBase.lastKill );
        _killReward.killItem.list.dataSource = rewardListData.list;
        var itemIndex : int = _bossToItemIndex[ bossItem ];
        _recordCurBossId = itemIndex + 1;
        var state : int = _cbDataManager.vec_BossInfo[ itemIndex ].state;
        if ( state == EBossStateType.READY || state == EBossStateType.FIGHTING || state == EBossStateType.NOT_OPEN ) {
            ObjectUtils.gray( _killReward.joinItem.getRewardBtn, true );
            _killReward.joinItem.getRewardBtn.mouseEnabled = false;
            _killReward.joinItem.getRewardBtn.visible = true;
            _killReward.joinItem.getedImg.visible = false;
        } else if ( state == EBossStateType.BEAT ) {
            ObjectUtils.gray( _killReward.joinItem.getRewardBtn, false );
            _killReward.joinItem.getRewardBtn.mouseEnabled = true;
            //判断有没有领过
            if ( _cbDataManager.canGetRewardArr[ itemIndex ].status == 1 ) {
                ObjectUtils.gray( _killReward.joinItem.getRewardBtn, false );
                _killReward.joinItem.getRewardBtn.mouseEnabled = true;
                _killReward.joinItem.getRewardBtn.visible = true;
                _killReward.joinItem.getedImg.visible = false;
            } else if(_cbDataManager.canGetRewardArr[ itemIndex ].status == 2){
                _killReward.joinItem.getRewardBtn.visible = false;
                _killReward.joinItem.getedImg.visible = true;
            }else{
                ObjectUtils.gray( _killReward.joinItem.getRewardBtn, true );
                _killReward.joinItem.getRewardBtn.mouseEnabled = false;
                _killReward.joinItem.getRewardBtn.visible = true;
                _killReward.joinItem.getedImg.visible = false;
            }
        }
    }

    private function _updateUI( e : Event ) : void {
        if ( _cbDataManager.vec_BossInfo.length > 0 ) {
            _killReward.joinItem.getRewardBtn.visible = true;
            _killReward.killItem.getedImg.visible = false;
            var state : int = _cbDataManager.vec_BossInfo[ _recordCurBossId-1 ].state;
            if ( state == EBossStateType.READY || state == EBossStateType.FIGHTING || state == EBossStateType.NOT_OPEN ) {
                ObjectUtils.gray( _killReward.joinItem.getRewardBtn, true );
                _killReward.joinItem.getRewardBtn.mouseEnabled = false;
            } else if ( state == EBossStateType.BEAT ) {
                //判断有没有领过
                if ( _cbDataManager.canGetRewardArr[ _recordCurBossId-1 ].status == 1 ) {
                    ObjectUtils.gray( _killReward.joinItem.getRewardBtn, false );
                    _killReward.joinItem.getRewardBtn.mouseEnabled = true;
                    _killReward.joinItem.getRewardBtn.visible = true;
                    _killReward.joinItem.getedImg.visible = false;
                } else if(_cbDataManager.canGetRewardArr[ _recordCurBossId-1 ].status == 2){
                    _killReward.joinItem.getRewardBtn.visible = false;
                    _killReward.joinItem.getedImg.visible = true;
                }else{
                    ObjectUtils.gray( _killReward.joinItem.getRewardBtn, true );
                    _killReward.joinItem.getRewardBtn.mouseEnabled = false;
                    _killReward.joinItem.getRewardBtn.visible = true;
                    _killReward.joinItem.getedImg.visible = false;
                }
            }
        }
    }

    public function show() : void {
        _updateUI(null);
        (_mainUI.system.getBean( CClubBossHandler ) as CClubBossHandler).cbNet.ifGotDamageRewardRequest();
        this._mainUI.uiContainer.addPopupDialog( _killReward );//击杀奖励
    }
}
}
