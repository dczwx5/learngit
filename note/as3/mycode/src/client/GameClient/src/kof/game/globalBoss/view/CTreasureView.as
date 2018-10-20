//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/2.
 * Time: 14:29
 */
package kof.game.globalBoss.view {

import com.greensock.TweenMax;
import com.greensock.easing.Linear;
import com.greensock.easing.Strong;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

import kof.SYSTEM_ID;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.bag.data.CBagData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.rewardTips.CRewardTips;
import kof.game.globalBoss.CWorldBossHandler;
import kof.game.globalBoss.datas.CWBDataManager;
import kof.game.globalBoss.net.CWBNet;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.table.Item;
import kof.table.WorldBossTreasureBuyPrice;
import kof.table.WorldBossTreasureRatio;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.WorldBoss.WBTreasureUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/2
     */
    public class CTreasureView {
        private var _wbTreasure : WBTreasureUI = null;
        private var _uiContainer : IUICanvas = null;
        private var _network : CWBNet = null;
        private var _wbDataManager : CWBDataManager = null;
        private var _appSystem : CAppSystem = null;
        private var _wbTips : CWBTips = null;

        private var _dic : Dictionary = new Dictionary();
        private var _bCanClick : Boolean = true;

        private var _pLoopTweenMax : TweenMax = null;
        private var _currentTotalCount : int = 0;
        private var _isClickTGetTotalCountReward : Boolean = false;
        private var _status:int=0;

        public function CTreasureView( uiContainer : IUICanvas, sys : CAppSystem ) {
            _wbTreasure = new WBTreasureUI();
            this._uiContainer = uiContainer;
            _appSystem = sys;
            _wbTips = new CWBTips();
            _wbTips.appSystem = sys;

            for ( var i : int = 1; i <= 6; i++ ) {
                _dic[ i ] = (i - 1) * 60;
                _wbTreasure[ "light" + i ].visible = false;
            }
            _wbTreasure.startBtn.clickHandler = new Handler( _requestTreasure );

            this._network = (this._appSystem.getBean( CWorldBossHandler ) as CWorldBossHandler).WBNet;
            this._wbDataManager = this._appSystem.getBean( CWBDataManager ) as CWBDataManager;
            _wbTreasure.getFragment.addEventListener( MouseEvent.CLICK, _getFragment );
//            _wbTreasure.treasureTip.toolTip = new Handler( _showItemTips, [ null, 0 ] );
            CSystemRuleUtil.setRuleTips(_wbTreasure.treasureTip,CLang.Get("worldboss_treasure"));

            if ( _wbDataManager.wbData.totalTimes >= _wbDataManager.worldBossConstant.accRewardCount ) {
                _status = CRewardTips.REWARD_STATUS_CAN_REWARD;
            }else{
                _status = CRewardTips.REWARD_STATUS_OTHER_1;
            }
            var itemSys:CItemSystem = _appSystem.stage.getSystem( CItemSystem ) as CItemSystem;
            _wbTreasure.baoxiangBox.dataSource = _wbDataManager.worldBossConstant.accRewardID;
            _wbTreasure.baoxiangBox.toolTip = new Handler( itemSys.showRewardTips, [ _wbTreasure.baoxiangBox,[CLang.Get("greatReward"),_status] ] );

            _addEventListener();
        }

        private function _getFragment( e : MouseEvent ) : void {
            if ( _wbDataManager.wbData.totalTimes >= _wbDataManager.worldBossConstant.accRewardCount ) {
                _currentTotalCount = _wbDataManager.wbData.totalTimes;
                (_appSystem.getHandler( CWorldBossHandler ) as CWorldBossHandler).WBNet.gainTotalTreasureRequest();
                _isClickTGetTotalCountReward = true;
            }
        }

        private function _showVipTips() : void {
            _wbTips.showVip( _wbDataManager.vipPrivilegeTable() );
        }

        private function _initItemView() : void {
            var playerManager : CPlayerManager = _appSystem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var vipLv : int = playerManager.playerData.vipData.vipLv;
            _wbTreasure.vip_clip.index = vipLv;
            _wbTreasure.vip_clip.toolTip = new Handler( _showVipTips );
            for ( var i : int = 1; i <= 6; i++ ) {
                var treasureItem : WorldBossTreasureRatio = _getTreasureItemTableData( i );
                if ( treasureItem ) {
                    var itemTable : Item = _wbDataManager.getItemForItemID( treasureItem.itemID );
                    var itemUI : RewardItemUI = _wbTreasure[ "item" + i ];
                    itemUI.bg_clip.index = itemTable.quality;
                    itemUI.icon_image.url = itemTable.smalliconURL + ".png";
                    itemUI.num_lable.text = treasureItem.itemNumber + "";
                    itemUI.box_eff.visible = itemTable.effect > 0 ? (itemTable.extraEffect == 0 || treasureItem.itemNumber >= itemTable.extraEffect) : false;
                    var goods : GoodsItemUI = new GoodsItemUI();
                    goods.img.url = itemTable.bigiconURL + ".png";
                    var bagData : CBagData = _wbDataManager.getItemNuForBag( itemTable.ID );
                    if ( bagData ) {
                        goods.txt.text = bagData.num + "";
                    } else {
                        goods.txt.text = "0";
                    }
//                    itemUI.toolTip = new Handler( _showItemTips, [ goods, itemTable.ID,treasureItem.itemNumber ] );
                    itemUI.dataSource = _getItemData(itemTable.ID);
                    itemUI.toolTip = new Handler( _showItemTips2, [itemUI] );
                }
            }
            var priceTable : WorldBossTreasureBuyPrice = _getTreasureBuyPriceTableData( _wbDataManager.wbData.alreadyBuyTimes + 1 );
            if ( priceTable.price != 0 ) {
                _wbTreasure.costBox.visible = true;
                _wbTreasure.freecost.visible = false;
                _wbTreasure.priceLabel.text = priceTable.price + "";
            } else {
                _wbTreasure.costBox.visible = false;
                _wbTreasure.freecost.visible = true;
            }
            _wbTreasure.totalCount.text = _wbDataManager.wbData.totalTimes + "/" + _wbDataManager.worldBossConstant.accRewardCount;
            _wbTreasure.count.text = _wbDataManager.wbData.remainderTimes + "";
            _wbTreasure.progress.value = _wbDataManager.wbData.totalTimes / _wbDataManager.worldBossConstant.accRewardCount;
            _wbTreasure.countTips.text = CLang.Get("treasureCountTips",{v1:_wbDataManager.worldBossConstant.accRewardCount});
            _wbTreasure.boom_clip.visible = false;
            _wbTreasure.canGetClip.visible = false;
            _wbTreasure.getFragment.index = 1;
            if ( _wbDataManager.wbData.totalTimes >= _wbDataManager.worldBossConstant.accRewardCount ) {
                _wbTreasure.boom_clip.visible = true;
                _wbTreasure.canGetClip.visible = true;
                _wbTreasure.canGetClip.autoPlay = true;
                _wbTreasure.getFragment.index = 2;
            }

            if ( _wbDataManager.wbData.totalTimes >= _wbDataManager.worldBossConstant.accRewardCount ) {
                _status = CRewardTips.REWARD_STATUS_CAN_REWARD;
            }else{
                _status = CRewardTips.REWARD_STATUS_OTHER_1;
            }
            var itemSys:CItemSystem = _appSystem.stage.getSystem( CItemSystem ) as CItemSystem;
            _wbTreasure.baoxiangBox.toolTip = new Handler( itemSys.showRewardTips, [ _wbTreasure.baoxiangBox,[CLang.Get("greatReward"),_status] ] );
        }

        private function _showTreasureRewardTips( rewardListData : CRewardListData ) : void {
            var canget : Boolean = false;
            if ( _wbDataManager.wbData.totalTimes >= _wbDataManager.worldBossConstant.accRewardCount ) {
                canget = true;
            }
            _wbTips.showTreasureTotalCountReward( rewardListData, canget ,_wbDataManager.worldBossConstant.accRewardCount);
        }

        private function _showItemTips( goods : GoodsItemUI, id : int, itemNum : int) : void {
            if ( goods ) {
                _wbTips.showItemTips( goods, _wbDataManager.getItemForItemID( id ), _getItemData( id ),itemNum );
            } else {
                _wbTips.showRule();
            }
        }

        private function _showItemTips2(item:RewardItemUI) : void
        {
            (_appSystem.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView, item);
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = (_appSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        private function _getTreasureItemTableData( index : int ) : WorldBossTreasureRatio {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_TREASURE_RATIO ) as CDataTable;
            return itemTable.findByPrimaryKey( index );
        }

        private function _addEventListener() : void {
            this._wbDataManager.addEventListener( "drawTreasure", _responseView );
            this._wbDataManager.addEventListener( "treasureInfo", _updateView );
        }

        private function _updateView( e : Event ) : void {
            if ( _currentTotalCount > _wbDataManager.wbData.totalTimes && _isClickTGetTotalCountReward ) {
                _isClickTGetTotalCountReward = false;
                _wbTreasure.boom_clip.visible = true;
                _wbTreasure.boom_clip.play();
                var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( _appSystem.stage, _wbDataManager.worldBossConstant.accRewardID );
                (_appSystem.stage.getSystem( CItemSystem ) as CItemSystem).showRewardFull( rewardListData );
            }
            _initItemView();
        }

        private function _responseView( e : Event ) : void {
            if ( _wbDataManager.wbData.index > 0 ) {
                TweenMax.delayedCall( 4, function () : void {
                    if ( _pLoopTweenMax ) {
                        _pLoopTweenMax.kill();
                        _pLoopTweenMax = null;
                    }
                    _selectItem( _dic[ _wbDataManager.wbData.index ] );
                } );
            }

            _initItemView();
        }

        private function _requestTreasure() : void {
            if ( !_bCanClick )return;
            if ( _wbDataManager.wbData.remainderTimes > 0 ) {
                var purpleDiamond : int = (_appSystem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.purpleDiamond;
                var price : int = _getTreasureBuyPriceTableData( _wbDataManager.wbData.alreadyBuyTimes + 1 ).price;
                var blueDiamond : int = (_appSystem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.blueDiamond;
                if ( price > blueDiamond + purpleDiamond ) {

                    var bundleCtx:ISystemBundleContext = _appSystem.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                    var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                    bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

//                    (_appSystem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "bangzuan_lanzuan_notEnough" ) );
                    (_appSystem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert("很抱歉，您的绑钻不足，请前往获得");

                }
                else {
                    (_appSystem.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( price, function () : void {
                        (_appSystem.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).isWaitShowQuickUse(true);
                        _network.drawBossTreasureRequest();
                        _startRotation();
                    } );
                }
            }
            else {
                (_appSystem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "treasure_count_notEnough" ) );
            }
        }

        private function _getTreasureBuyPriceTableData( count : int ) : WorldBossTreasureBuyPrice {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = _appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_TREASURE_BUY_PRICE ) as CDataTable;
            var table : WorldBossTreasureBuyPrice = itemTable.findByPrimaryKey( count );
            if ( table ) {
                return table;
            }
            return itemTable.toArray()[ itemTable.toArray().length - 1 ];
        }

        private function _startRotation() : void {
            if ( _bCanClick ) {
                _bCanClick = false;
                startUp();
            }
        }

        public function show() : void {
            if ( _pLoopTweenMax ) {
                _pLoopTweenMax.kill();
                _pLoopTweenMax = null;
            }
            _uiContainer.addPopupDialog( _wbTreasure );
            _initItemView();
        }

        private function startUp() : void {
            TweenMax.to( _wbTreasure.pointerBox, 2, {
                rotation : 360,
                ease : Strong.easeIn,
                onComplete : _infiniteLoop,
                onUpdate : _updateLight
            } );
        }

        private function _infiniteLoop() : void {
            _pLoopTweenMax = TweenMax.to( _wbTreasure.pointerBox, 0.5, {
                rotation : 360,
                repeat : -1,
                ease : Linear.easeNone,
                onUpdate : _updateLight
            } );
        }

        private function _selectItem( degree : int ) : void {
            TweenMax.to( _wbTreasure.pointerBox, 3, {
                rotation : degree + 360,
                ease : Linear.easeNone,
                onUpdate : _updateLight,
                onComplete : _resultFunc
            } );
        }

        private function _resultFunc() : void {
            _flyItem();
//            _wbTreasure.close();
        }

        private function _flyItem() : void {
            var len : int = 1;
            for ( var i : int = 0; i < len; i++ ) {
                var item : Component = _wbTreasure[ "item" + _wbDataManager.wbData.index ] as Component;
                CFlyItemUtil.flyItemToBag( item, item.localToGlobal( new Point() ), _appSystem, _flyCompleteHandler );
            }
        }

        private function _flyCompleteHandler():void {
            _bCanClick = true;
            (_appSystem.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).isWaitShowQuickUse(false);
        }

        private function _updateLight() : void {
            var degree : int = _wbTreasure.pointerBox.rotation < 0 ? 360 + _wbTreasure.pointerBox.rotation : _wbTreasure.pointerBox.rotation;
            var index : int = degree / 60 + 1;
            if ( index > 6 ) {
                index = 6;
            }
            if ( index == 0 ) {
                index = 1;
            }
            _updateLightVisible( index );
        }

        private function _updateLightVisible( index : int ) : void {
            for ( var i : int = 1; i <= 6; i++ ) {
                _wbTreasure[ "light" + i ].visible = false;
            }
            _wbTreasure[ "light" + index ].visible = true;
        }




    }
}
