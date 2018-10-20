//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/1.
 * Time: 10:59
 */
package kof.game.sign.signFacade.signSystem.view {

    import flash.geom.Point;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;

    import kof.data.CDataTable;
import kof.game.KOFSysTags;
import kof.game.character.ai.actions.CMoveToAction;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
    import kof.game.common.CRewardUtil;
    import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
    import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.sign.CSignViewHandler;
import kof.game.sign.signFacade.CSignFacade;
    import kof.game.sign.signFacade.signSystem.net.CSignNetDataManager;
    import kof.table.Item;
    import kof.table.NewServerReward;
    import kof.table.SignInReward;
    import kof.table.TotalSignInReward;
    import kof.ui.IUICanvas;
    import kof.ui.components.KOFNum;
    import kof.ui.imp_common.RewardItemUI;
    import kof.ui.master.Sign.SignItemUI;
    import kof.ui.master.Sign.SignUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Box;
    import morn.core.components.Button;

    import morn.core.components.Clip;

    import morn.core.components.Component;

    import morn.core.components.Dialog;
    import morn.core.components.Label;
import morn.core.handlers.Handler;

import morn.core.handlers.Handler;
    import morn.core.utils.ObjectUtils;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/1 er
     */
    public class CSignView {
        private var _signUI : SignUI = null;
        private var _uiContainer : IUICanvas = null;

        private var _closeHandler : Handler = null;
        //记录累积天数奖励显示的对应的哪个累积天数的奖励
        private var _curDaysForTotalDays : int = 0;

        private var _isTotalDaysReward : Boolean = false;
        //签到后延时函数id
        private var _timeOutID : int = -1;

        private var _signTipsView : CSignTipsView = null;

        private var _isUpdate : Boolean = false;
        private var _isShow : Boolean = false;

        private var _bClickSignBtn : Boolean = false;
        private var _pNewestItem : Component = null;
        private var _pNewestTotalItemArr : Array = [];

        public function CSignView() {
            _signUI = new SignUI();
            _signUI.closeHandler = new Handler( _close );
            _signUI.itemList.renderHandler = new Handler( _renderItem );
            _signUI.itemList.dataSource = [];
            _signUI.totalRewardList.renderHandler = new Handler(CItemUtil.getItemRenderFunc(CSignFacade.getInstance().signAppSystem));
//            _signUI.preBtn.clickHandler = new Handler( _preBtnFunc );
//            _signUI.nextBtn.clickHandler = new Handler( _nextBtnFunc );
            _signUI.heroIco.mask = _signUI.heroMask;
            _signTipsView = new CSignTipsView();
        }

        public function dispose() : void {
            _signUI = null;
            _uiContainer = null;
            _closeHandler = null;
            _signTipsView = null;
        }

        public function get isShow() : Boolean {
            return _isShow;
        }

        private function _preBtnFunc() : void {
            var index : int = CSignFacade.getInstance().getTotalDaysIndexForTotalDays( _curDaysForTotalDays );
            var totalSignInReward : TotalSignInReward = CSignFacade.getInstance().getPreSumSignInReward( index );
            sumDaysReward( totalSignInReward );
        }

        private function _nextBtnFunc() : void {
            var index : int = CSignFacade.getInstance().getTotalDaysIndexForTotalDays( _curDaysForTotalDays );
            var totalSignInReward : TotalSignInReward = CSignFacade.getInstance().getNextSumSignInReward( index );
            sumDaysReward( totalSignInReward );
        }

        private function _signRewardBtn() : void {
            if ( _bClickSignBtn )return;
            _bClickSignBtn = true;
            CSignFacade.getInstance().commonSignRequest();
        }

        public final function set uiContainer( container : IUICanvas ) : void {
            this._uiContainer = container;
        }

        public final function show() : void {
            _isShow = true;
            if ( !_isUpdate ) {
                _signUI.totalDaysBtn.visible = false;
                _signUI.dayTxt.visible = true;
                _signUI.itemList.dataSource = [];
            }

            var hallViewHandler:CSignViewHandler = CSignFacade.getInstance().signAppSystem.getBean(CSignViewHandler);
            hallViewHandler.setTweenData(KOFSysTags.SIGN);
            hallViewHandler.showDialog(_signUI);
//            this._uiContainer.addDialog( _signUI );
        }



        public final function close() : void {
            if ( _timeOutID != -1 ) {
                clearTimeout( _timeOutID );
            }
            var hallViewHandler:CSignViewHandler = CSignFacade.getInstance().signAppSystem.getBean(CSignViewHandler);
            hallViewHandler.closeDialog(_closeB);

        }
        private final function _closeB() : void {
            _isShow = false;
        }

        private function _flyItem() : void {
            var len : int = 1;
            for ( var i : int = 0; i < len; i++ ) {
                var item : Component = (_pNewestItem as SignItemUI).ico;
                ObjectUtils.gray( item, false );
                CFlyItemUtil.flyItemToBag( item, item.localToGlobal( new Point() ), CSignFacade.getInstance().signAppSystem );
            }
        }

        public final function update() : void {
            _isUpdate = true;
            _signUI.signBtn.visible = true;
            _signUI.totalDaysBtn.visible = true;
            _signUI.dayTxt.visible = false;
            if ( CSignNetDataManager.getInstance().signInState == 1 ) {
                _signUI.signBtn.label = CLang.Get( "alreadySignIn" );
                _signUI.signBtn.clickHandler = null;
                ObjectUtils.gray( _signUI.signBtn, true );
            } else {
                _signUI.signBtn.label = CLang.Get( "signIn" );
                _signUI.signBtn.clickHandler = new Handler( _signRewardBtn );
                ObjectUtils.gray( _signUI.signBtn, false );
            }
            var curMonth : int = CSignNetDataManager.getInstance().month;
            var itemArr : Array = [];
            if ( CSignNetDataManager.getInstance().isNewServer ) {
                var newServerTable : CDataTable = CSignFacade.getInstance().newServerRewardTable;
                var len : int = newServerTable.toVector().length;
                for ( var i : int = 0; i < len; i++ ) {
                    var newServerReward : NewServerReward = newServerTable.findByPrimaryKey( i + 1 );
                    itemArr.push( newServerReward );
                }
            }
            else {
                itemArr = CSignFacade.getInstance().getSignInRewardForMonth( curMonth );
            }
            _signUI.heroIco.url = "icon/role/big/role_"+itemArr[0].heros+".png";
            _signUI.itemList.dataSource = itemArr;
//            _signUI.daysTxt2.text = "/"+itemArr.length;
            if ( _isTotalDaysReward ) {
                _isTotalDaysReward = false;
                _signUI.totalDaysBtn.visible = false;
                _signUI.dayTxt.visible = true;
                _signUI.dayTxt.text = CLang.Get( "alreadyGet" );
                _timeOutID = setTimeout( updateShowTotalSignInReward, 2000 );
                _flyTotalItem();
            } else {
                updateShowTotalSignInReward();
            }

            if ( _bClickSignBtn && CSignNetDataManager.getInstance().signInState == 1 ) {
                _flyItem();
            }
            _bClickSignBtn = false;
        }

        private function _flyTotalItem() : void {
            var len : int = _pNewestTotalItemArr.length;
            for ( var i : int = 0; i < len; i++ ) {
                var item : Component = _pNewestTotalItemArr[ i ];
                CFlyItemUtil.flyItemToBag( item, item.localToGlobal( new Point() ), CSignFacade.getInstance().signAppSystem );
            }
        }

        private function updateShowTotalSignInReward() : void {
            var totalSignInReward : TotalSignInReward = CSignFacade.getInstance().getSumSignInReward( CSignNetDataManager.getInstance().getGetNearTotalDaysRewardIndex() );
            sumDaysReward( totalSignInReward );
            var total:int=totalSignInReward.totalDays;
            if(total<10){
                _signUI.shi.visible = false;
                _signUI.ge.index = total;
            }else{
                _signUI.shi.visible = true;
                _signUI.shi.index = total/10;
                _signUI.ge.index = total%10;
            }
        }

        private function sumDaysReward( totalSignInReward : TotalSignInReward ) : void {
            var sumDays : int = CSignNetDataManager.getInstance().sumDays;
            var daysIndex : int = CSignFacade.getInstance().getTotalDaysIndexForTotalDays( totalSignInReward.totalDays );
            var daysState : int = CSignNetDataManager.getInstance().getGetTotalDaysRewardStateForIndex( daysIndex );
            if ( sumDays < totalSignInReward.totalDays ) {
                _signUI.totalDaysBtn.visible = false;
                _signUI.dayTxt.visible = true;
                _signUI.dayTxt.text = CLang.Get( "needDays", {v1 : (totalSignInReward.totalDays - sumDays)} );
            } else {
                if ( daysState == 0 ) {
                    _signUI.dayTxt.visible = false;
                    _signUI.totalDaysBtn.visible = true;
                    _signUI.totalDaysBtn.clickHandler = new Handler( _totalDaysRewardClick );
                    _signUI.dayTxt.text = CLang.Get( "needDays", {v1 : (totalSignInReward.totalDays - sumDays)} );
                }
                else {
                    _signUI.dayTxt.visible = true;
                    _signUI.totalDaysBtn.visible = false;
                    _signUI.totalDaysBtn.clickHandler = null;

                    if(totalSignInReward.totalDays - sumDays <= 0)
                    {
                        _signUI.dayTxt.text = CLang.Get( "alreadyGet" );
                    }
                    else
                    {
                        _signUI.dayTxt.text = CLang.Get( "needDays", {v1 : (totalSignInReward.totalDays - sumDays)} );
                    }
                }
            }
            if ( totalSignInReward ) {
                _curDaysForTotalDays = totalSignInReward.totalDays;
                var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( CSignFacade.getInstance().signAppSystem.stage, totalSignInReward.rewardID );
                var itemListArr : Array = rewardListData.list;
                _signUI.totalRewardList.dataSource = itemListArr;
            }
            _signUI.daysTxt1.text = sumDays+"";
        }

        private function _renderRewardItem( item:Component,idx:int):void{
            var rewardData : CRewardData = item.dataSource as CRewardData;
            var rewardItemUI : RewardItemUI = item as RewardItemUI;
            rewardItemUI.icon_image.url = rewardData.iconSmall;
            rewardItemUI.hasTakeImg.visible = false;
            rewardItemUI.num_lable.text = rewardData.num + "";

            var itemTable : Item = CSignFacade.getInstance().getItemForItemID( rewardData.ID );
            var itemNu : int = CSignFacade.getInstance().getItemNuForBag( rewardData.ID );
            var itemData : CItemData = CSignFacade.getInstance().getItemDataForItemID( rewardData.ID );
            rewardItemUI.toolTip = new Handler( _showTips, [ itemNu, itemTable, itemData ] );
            rewardItemUI.bg_clip.index = itemTable.quality;
            rewardItemUI.box_eff.visible = itemTable.effect;
            _pNewestTotalItemArr.push( rewardItemUI );
        }

        private function _totalDaysRewardClick() : void {
            _isTotalDaysReward = true;
            var daysIndex : int = CSignFacade.getInstance().getTotalDaysIndexForTotalDays( _curDaysForTotalDays );
            CSignFacade.getInstance().getTotalSignInRewardRequest( daysIndex );
        }

        private function _renderItem( item : Component, idx : int ) : void {
            var itemUI : SignItemUI = item as SignItemUI;
            var data : Object = item.dataSource as NewServerReward;
            if ( !data ) {
                data = item.dataSource as SignInReward;
            }
            if ( !data )return;
            itemUI.days.text = data.days + CLang.Get("signDays");
            var itemTable : Item = CSignFacade.getInstance().getItemForItemID( data.rewardID );
            itemUI.ico.icon_image.url = itemTable.smalliconURL + ".png";
            itemUI.ico.num_lable.text = data.rewardNum;
            itemUI.ico.bg_clip.index = itemTable.quality;
            itemUI.ico.box_eff.visible = itemTable.effect > 0 ? (itemTable.extraEffect == 0 || data.rewardNum >= itemTable.extraEffect) : false;
            if ( idx == CSignNetDataManager.getInstance().totalSignInDays ) {
                _pNewestItem = item;
            }
            if ( data.days <= CSignNetDataManager.getInstance().totalSignInDays ) {
                itemUI.signInIco.visible = true;
                itemUI.signInedImg.visible = true;
                itemUI.ico.hasTakeImg.visible = false;
            } else {
                itemUI.signInIco.visible = false;
                itemUI.signInedImg.visible = false;
                itemUI.ico.hasTakeImg.visible = false;
            }

            if ( data.vipLevel != 0 ) {
                itemUI.vipIco.visible = true;
                if ( data.vipLevel < 16 ) {
                    itemUI.vipIco.visible = true;
                    (itemUI.vipIco.getChildByName( "clip" ) as Clip).index = data.vipLevel-1;
                } else {
                    itemUI.vipIco.visible = false;
                }
            } else {
                itemUI.vipIco.visible = false;
            }
            var itemNu : int = CSignFacade.getInstance().getItemNuForBag( data.rewardID );
            var itemData : CItemData = CSignFacade.getInstance().getItemDataForItemID( data.rewardID );

            itemUI.ico.dataSource = itemData;
//            itemUI.ico.toolTip = new Handler( _showTips, [ itemNu, itemTable, itemData ] );
            itemUI.ico.toolTip = new Handler( _showItemTips, [itemUI.ico] );
        }

        private function _showItemTips(item:RewardItemUI) : void
        {
            (CSignFacade.getInstance().signAppSystem.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView, item);
        }

        private function _showTips( itemNu : int, itemTableData : Item, itemData : CItemData ) : void {
            _signTipsView.showSignItemTips( itemNu, itemTableData, itemData );
        }

        public function set closeHanlder( closeHandler : Handler ) : void {
            _closeHandler = closeHandler;
        }

        private function _close( type : String ) : void {
            if ( type == Dialog.CLOSE ) {
                if ( _closeHandler ) {
                    _closeHandler.execute();
                }
            }
        }

    }
}
