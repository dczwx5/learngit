//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/25.
 * Time: 21:53
 */
package kof.game.itemGetPath {

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.game.common.data.CErrorData;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.CMainInstanceHandler;
import kof.game.instance.mainInstance.data.CInstanceSweepRewardListData;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.InstanceConstant;
import kof.table.Item;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardListUI;
import kof.ui.imp_common.SweepItemPathUI;
import kof.ui.instance.InstanceSweepItemUI;

import morn.core.components.Component;
import morn.core.components.List;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/25
     */
    public class CSweepView {
        private var _sweepRewardView : SweepItemPathUI = null;
        private var _uiContainer : IUICanvas = null;
        private var _closeHandler : Handler = null;
        private var _appSystem : CAppSystem = null;
        private var _itemTips : CItemTips = null;
        private var _itemID:Number = 0;
    private var _needNu:int=0;

        public function CSweepView( uiContainer : IUICanvas ) {
            this._uiContainer = uiContainer;
            _sweepRewardView = new SweepItemPathUI();
            _sweepRewardView.closeHandler = new Handler( _removeEvent );

//            _sweepRewardView.ok_btn.btnLabel.text = CLang.Get("common_ok");
//            _sweepRewardView.ok_btn.clickHandler = new Handler(_onOk);
//            _sweepRewardView.sweep_more_btn.btnLabel.text = CLang.Get("sweep_more_time");
//            _sweepRewardView.sweep_more_btn.clickHandler = new Handler(_onSweepMore);

            _sweepRewardView.msg_list.renderHandler = new Handler( _onItemRender );
            _itemTips = new CItemTips();
            _sweepRewardView.sweepOnce.clickHandler = new Handler(_sweepOnceFunc,[1]);
            _sweepRewardView.sweepOnce.label = "扫荡1次";
            _sweepRewardView.sweepTen.clickHandler = new Handler(_sweepTenFunc,[10]);
            _sweepRewardView.item.txt_num.align = "center";
            _sweepRewardView.item.txt_num.letterSpacing = 0;
            _sweepRewardView.item.txt_num.bold = false;
        }

        private function _sweepOnceFunc(count:int):void{
            if(!_calculationPhysicalStrengthIsEnoughForChanllengeCount(count)){
                CItemGetSystem(_appSystem).openPower();
                _sweepRewardView.close();
                return;
            }
            _sweepRewardView.completeImg.visible = false;
            var mainNetHandler : CMainInstanceHandler = (_appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).mainNetHandler;
            (_appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).instanceData.resetSweepData();

            mainNetHandler.sendSweepInstance( CItemGetSystem(_appSystem).currentInstanceData.instanceID, 1 );
        }

        private function _sweepTenFunc(count:int):void{
            if(!_calculationPhysicalStrengthIsEnoughForChanllengeCount(count)){
                CItemGetSystem(_appSystem).openPower();
                _sweepRewardView.close();
                return;
            }
            _sweepRewardView.completeImg.visible = false;
            var mainNetHandler : CMainInstanceHandler = (_appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).mainNetHandler;
            (_appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).instanceData.resetSweepData();

            mainNetHandler.sendSweepInstance( CItemGetSystem(_appSystem).currentInstanceData.instanceID, count );
        }

    //判断体力是否足够挑战指定次数physicalStrength
    private function _calculationPhysicalStrengthIsEnoughForChanllengeCount(chanllengeCount:int) : Boolean {
        var instanceConstant : InstanceConstant = CItemGetSystem(_appSystem).currentInstanceData.constant;
        var playerData:CPlayerData = (CItemGetSystem(_appSystem).stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData;
        var costVit:int=CItemGetSystem(_appSystem).currentInstanceData.isElite?instanceConstant.INSTANCE_ELITE_PASS_COST_VT_NUM:instanceConstant.INSTANCE_MAIN_PASS_COST_VT_NUM;
        if ( playerData.vitData.physicalStrength < chanllengeCount * costVit ) {
            return false;
        }
        return true;
    }

        private function _removeEvent( type : String = "" ) : void {
            _appSystem.stage.getSystem( CInstanceSystem ).removeEventListener( CInstanceEvent.INSTANCE_SWEEP_DATA, _updateGetItemList );
            _appSystem.stage.getSystem( CBagSystem ).removeEventListener( CBagEvent.BAG_UPDATE, _updateItemNu );
        }

        public function set closeHandler( value : Handler ) : void {
            this._closeHandler = value;
        }

        public function set appSystem( value : CAppSystem ) : void {
            _appSystem = value;
        }

        public function get appSystem() : CAppSystem {
            return _appSystem;
        }

        public function show() : void {
            _appSystem.stage.getSystem( CInstanceSystem ).addEventListener( CInstanceEvent.INSTANCE_SWEEP_DATA, _updateGetItemList );
            _appSystem.stage.getSystem( CBagSystem ).addEventListener( CBagEvent.BAG_UPDATE, _updateItemNu );
            _uiContainer.addPopupDialog( _sweepRewardView );
            _sweepRewardView.completeImg.visible = false;
            _itemID = CItemGetSystem(_appSystem).itemID;
            _needNu = CItemGetSystem(_appSystem).needNu;
            var itemTable : Item = _getItemForItemID( _itemID );
            _sweepRewardView.item.img.url = itemTable.bigiconURL + ".png";
            _sweepRewardView.item.clip_bg.index = itemTable.quality;
            _sweepRewardView.itemName.text = itemTable.name;
            var bagData : CBagData = (this._appSystem.stage.getSystem( CBagSystem ).getBean( CBagManager ) as CBagManager).getBagItemByUid( _itemID );
            if ( bagData ) {
                _sweepRewardView.item.txt_num.text = bagData.num + "/" + _needNu;
                if(bagData.num<_needNu){
                    _sweepRewardView.item.txt_num.color = 0xff0000;
                }else{
                    _sweepRewardView.item.txt_num.color = 0xffffff;
                }
                _sweepRewardView.itemNu.text = bagData.num + "";
            } else {
                _sweepRewardView.item.txt_num.text = "0/"+_needNu;
                _sweepRewardView.itemNu.text = "0";
                _sweepRewardView.item.txt_num.color = 0xff0000;
            }
            _sweepRewardView.item.box_effect.visible = itemTable.effect;
        }

    private function _getItemForItemID( id : int ) : Item {
        var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
        return itemTable.findByPrimaryKey( id );
    }

    private function _updateItemNu(e:CBagEvent):void{
        var bagData : CBagData = (this._appSystem.stage.getSystem( CBagSystem ).getBean( CBagManager ) as CBagManager).getBagItemByUid( _itemID );
        if ( bagData ) {
            _sweepRewardView.item.txt_num.text = bagData.num + "/" + _needNu;
            if(bagData.num<_needNu){
                _sweepRewardView.item.txt_num.color = 0xff0000;
            }else{
                _sweepRewardView.item.txt_num.color = 0xffffff;
            }
            _sweepRewardView.itemNu.text = bagData.num + "";
        } else {
            _sweepRewardView.item.txt_num.text = "0/"+_needNu;
            _sweepRewardView.itemNu.text = "0";
            _sweepRewardView.item.txt_num.color = 0xff0000;
        }
        if(CItemGetSystem(_appSystem).currentInstanceData.isElite)
        {
            _updateButton();
        }else{
            _sweepRewardView.sweepOnce.mouseEnabled = true;
            _sweepRewardView.sweepTen.mouseEnabled = true;
            ObjectUtils.gray( _sweepRewardView.sweepOnce, false );
            ObjectUtils.gray( _sweepRewardView.sweepTen, false );
            _sweepRewardView.sweepTen.label = "扫荡10次";
            _sweepRewardView.sweepTen.clickHandler = new Handler(_sweepTenFunc,[10]);
        }
    }

        private function _updateGetItemList( e : CInstanceEvent ) : void {
            var sweepRewardData : CInstanceSweepRewardListData = e.data as CInstanceSweepRewardListData;
            var list : Array = sweepRewardData.list;
            _sweepRewardView.msg_list.dataSource = list;
            _sweepRewardView.msg_list.repeatY = list.length;
            _sweepRewardView.reward_panel.refresh();
            _sweepRewardView.reward_panel.scrollTo( 0 );
            _sweepRewardView.completeImg.visible = true;
        }

        private function _updateButton():void{
            var canChanllengeCount : int = _getEliteChanllengeLeftCount();
            if ( canChanllengeCount == 0 ) {
                _sweepRewardView.sweepOnce.mouseEnabled = false;
                _sweepRewardView.sweepTen.mouseEnabled = false;
                ObjectUtils.gray( _sweepRewardView.sweepOnce, true );
                ObjectUtils.gray( _sweepRewardView.sweepTen, true );
                _sweepRewardView.sweepTen.label = "扫荡3次";
            } else {
                _sweepRewardView.sweepOnce.mouseEnabled = true;
                _sweepRewardView.sweepTen.mouseEnabled = true;
                ObjectUtils.gray( _sweepRewardView.sweepOnce, false );
                ObjectUtils.gray( _sweepRewardView.sweepTen, false );
                var str:String="";
                if(canChanllengeCount==2)
                {
                    str = "2";
                }else if(canChanllengeCount==1){
                    str = "1";
                }else {
                    str = "3";
                }
                _sweepRewardView.sweepTen.label = "扫荡"+str+"次";
                _sweepRewardView.sweepTen.clickHandler = new Handler(_sweepTenFunc,[int(str)]);
            }
            var playerData:CPlayerData = (_appSystem.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData;
            if(playerData.vipData.vipLv < 3){
                ObjectUtils.gray( _sweepRewardView.sweepTen, true );
                _sweepRewardView.sweepTen.mouseEnabled = false;
            }
        }

    private function _calculationChanllengeCount( isElite : Boolean ) : int {
        var instanceConstant : InstanceConstant = CItemGetSystem(_appSystem).currentInstanceData.constant;
        var times : int = instanceConstant.INSTANCE_MAIN_SWEEP_NUM_MAX;
        var _playerData:CPlayerData = (_appSystem.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData;
        if ( _playerData.vitData.physicalStrength < times * instanceConstant.INSTANCE_MAIN_PASS_COST_VT_NUM ) {
            times = _playerData.vitData.physicalStrength / instanceConstant.INSTANCE_MAIN_PASS_COST_VT_NUM;
        }
        if ( isElite ) {
            times = CItemGetSystem(_appSystem).currentInstanceData.challengeCountLeft;
        }
        return times;
    }

    private function _getEliteChanllengeLeftCount():int{
        return CItemGetSystem(_appSystem).currentInstanceData.challengeCountLeft;
    }

        private function _onItemRender( item : Component, idx : int ) : void {
            var sweepItem : InstanceSweepItemUI = item as InstanceSweepItemUI;
            var data : CRewardListData = sweepItem.dataSource as CRewardListData;
            if ( !data ) {
                sweepItem.visible = false;
                return;
            } else {
                sweepItem.visible = true;
            }

            sweepItem.times_txt.text = CLang.Get( "sweep_times", {v1 : CLang.Get( "common_number_china_" + (1 + idx) )} ); // data.getRewardString();
            sweepItem.exp_add_txt.text = data.playerExp.toString();
            sweepItem.hero_exp_add_txt.text = data.heroExp.toString();
            sweepItem.gold_add_txt.text = data.gold.toString();
            sweepItem.reward_list.item_list.renderHandler = new Handler( _onRenderItem );
            var len : int = data.list.length;
            var deleteArr : Array = [];
            for ( var i : int = 0; i < len; i++ ) {
                var rewardData : CRewardData = data.list[ i ];
                if ( rewardData.isGold ) {
                    deleteArr.push( rewardData );
                } else if ( rewardData.isHeroExp ) {
                    deleteArr.push( rewardData );
                } else if ( rewardData.isPlayerExp ) {
                    deleteArr.push( rewardData );
                }

            }
            for ( var j : int = 0; j < deleteArr.length; j++ ) {
                var deleteRewardData : CRewardData = deleteArr[ j ];
                var index : int = data.list.indexOf( deleteRewardData );
                if ( index != -1 ) {
                    data.list.splice( index, 1 );
                }
            }
            var llen : int = data.list.length;
            if ( llen > 4 ) {
                sweepItem.reward_list.item_list.repeatX = 4;
            } else {
                sweepItem.reward_list.item_list.repeatX = llen;
            }

            sweepItem.reward_list.item_list.dataSource = data.list;
            sweepItem.reward_list.item_list.centerX = 0;

            sweepItem.reward_list.left_btn.clickHandler = new Handler( _onLeft, [ sweepItem ] );
            sweepItem.reward_list.right_btn.clickHandler = new Handler( _onRight, [ sweepItem ] );
            _curPage = 0;
            _updatePage( sweepItem );
        }

        private var _curPage : int = 0;

        private function _onLeft( sweepItem : InstanceSweepItemUI ) : void {
            _curPage--;
            _updatePage( sweepItem );
        }

        private function _onRight( sweepItem : InstanceSweepItemUI ) : void {
            _curPage++;
            _updatePage( sweepItem );
        }

        private function _updatePage( sweepItem : InstanceSweepItemUI ) : void {
            var itemList : List = sweepItem.reward_list.item_list;
            var rewardListUI : RewardListUI = sweepItem.reward_list;
            if ( _curPage < 0 )
                _curPage = 0;
            if ( _curPage >= itemList.totalPage )
                _curPage = itemList.totalPage - 1;
            itemList.page = _curPage;

            if ( itemList.totalPage == 1 ) {
                rewardListUI.left_btn.visible = false;
                rewardListUI.right_btn.visible = false;
            } else {
                if ( _curPage == 0 ) {
                    rewardListUI.left_btn.visible = false;
                    rewardListUI.right_btn.visible = true;
                } else {
                    rewardListUI.left_btn.visible = true;
                    if ( _curPage == itemList.totalPage - 1 ) {
                        rewardListUI.right_btn.visible = false;
                    } else {
                        rewardListUI.right_btn.visible = true;
                    }
                }
            }
            itemList.centerX = 0;
        }

        private function _onRenderItem( box : Component, idx : int ) : void {
            var item : RewardItemUI = box as RewardItemUI;
            if ( item == null ) return;
            item.visible = true;
            var rewardData : CRewardData = item.dataSource as CRewardData;
            if ( !rewardData ) {
                item.visible = false;
                return;
            }
            item.num_lable.visible = true;
            item.num_lable.text = rewardData.num.toString();
            item.icon_image.url = rewardData.iconSmall;
            item.bg_clip.index = rewardData.quality;
            var itemTable : Item = _itemTabel( rewardData.ID );
            var itemNu : int = rewardData.num;
            var itemData : CItemData = _getItemData( rewardData.ID );
            item.toolTip = new Handler( _addTips, [ itemNu, itemTable, itemData ] );

            item.box_eff.visible = itemTable.effect;
        }

        private function _addTips( itemNu : int, itemTableData : Item, itemData : CItemData ) : void {
            _itemTips.showItemTips( itemNu, itemTableData, itemData );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = (_appSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        private function _itemTabel( id : int ) : Item {
            var dataBaseSys : CDatabaseSystem = _appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var itemGetDataTable : CDataTable = dataBaseSys.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemGetDataTable.findByPrimaryKey( id ) as Item;
        }

    private function _judgeCanchanllenge(count:int) : Boolean {
        var errorData : CErrorData = (_appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).instanceData.checkInstanceCanFight( CItemGetSystem(_appSystem).currentInstanceData.instanceID, count, false, false );
        var errorString : String = "";
        if ( errorData != null && errorData.isError == false ) {
            if ( errorData.contents ) {
                if ( errorData.contents.length > 0 ) {
                    errorString = errorData.contents[ 0 ];
                    if ( errorString.indexOf( "instance_error_vit_not_enough" ) > -1 ) {
                        CItemGetSystem(_appSystem).openPower();
                        return false;
                    }
                }
            }
        }
        else {
            if ( errorData.contents ) {
                if ( errorData.contents.length > 0 ) {
                    errorString = errorData.contents[ 0 ];
                    if ( errorString.indexOf( "instance_error_vit_not_enough" ) > -1 ) {
                        CItemGetSystem(_appSystem).openPower();
                        return false;
                    }
                }
            }
        }
        return true;
    }

    }
}
