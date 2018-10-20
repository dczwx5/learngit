//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/26.
 * Time: 15:41
 */
package kof.game.currency.qq.views {

    import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.common.CRewardUtil;
    import kof.game.currency.CCurrencyHandler;
import kof.game.currency.qq.CQQHallViewHandler;
import kof.game.currency.qq.data.configData.CQQTableDataManager;
    import kof.game.currency.qq.data.netData.CQQClientDataManager;
    import kof.game.currency.qq.data.netData.vo.CQQData;
    import kof.game.currency.qq.enums.ENetQQ;
    import kof.game.currency.qq.enums.EQQGiftType;
    import kof.game.currency.tipview.CQQTipsView;
    import kof.game.item.CItemData;
    import kof.game.item.data.CRewardData;
    import kof.game.item.data.CRewardListData;
    import kof.game.player.CPlayerSystem;
    import kof.table.Item;
    import kof.table.TencentDailyPrivilege;
    import kof.table.TencentFreshPrivilege;
    import kof.table.TencentLevelPrivilege;
    import kof.ui.IUICanvas;
    import kof.ui.imp_common.ItemUIUI;
    import kof.ui.imp_common.RewardItemUI;
    import kof.ui.platform.qq.GameHallUI;
    import kof.ui.platform.qq.HallLvItemUI;

    import morn.core.components.Button;
    import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.List;
    import morn.core.handlers.Handler;
    import morn.core.utils.ObjectUtils;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/26
     */
    public class CQQHallView {
        private var _uiCanvas : IUICanvas = null;
        private var _hallView : GameHallUI = null;
        private var _qqTipsView : CQQTipsView = null;
        private var _system : CAppSystem = null;

        public function CQQHallView( sys : CAppSystem ) {
            this._system = sys;
            _hallView = new GameHallUI();
            _hallView.btnGroup.selectHandler = new Handler( _selectCallBack );
            _hallView.btnGroup.selectedIndex = 0;
            _hallView.lvList.visible = false;
            _hallView.dayBox.visible = false;

            _qqTipsView = new CQQTipsView();
        }

        //领取等级奖励
        private function _getLvGift( lv : int ) : void {
            (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.LEVEL, ENetQQ.LOBBY, lv );
        }

        //领取每日奖励
        private function _getDailyGift() : void {
            (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.DAILY, ENetQQ.LOBBY, 0 );
        }

        //领取新手奖励
        private function _getFreshGift() : void {
            (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.FRESH, ENetQQ.LOBBY, 0 );
        }

        private function _initConfigData() : void {
            //新手礼包配置数据
            var freshRewardList : List = _hallView.newBox.getChildByName( "itemList" ) as List;
            freshRewardList.renderHandler = freshRewardList.renderHandler || new Handler( _renderFreshItem );
            var tencentFreshPrivilege : TencentFreshPrivilege = CQQTableDataManager.instance.getTencentFreshPrivilege( EQQGiftType.GAME_HALL );
            var freshRewardID : int = tencentFreshPrivilege.reward;
            var freshRewardListData : CRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, freshRewardID );
            var itemListArr : Array = freshRewardListData.list;
            freshRewardList.repeatX = itemListArr.length;
            freshRewardList.centerX = 0;
            freshRewardList.dataSource = itemListArr;
            //每日礼包配置数据
            var dailyRewardList : List = _hallView.dayBox.getChildByName( "itemList" ) as List;
            dailyRewardList.renderHandler = dailyRewardList.renderHandler || new Handler( _renderDayItem );
            var tencentDailyPrivilege : TencentDailyPrivilege = CQQTableDataManager.instance.getTencentDailyPrivilege( EQQGiftType.GAME_HALL );
            var dailyRewardID : int = int( tencentDailyPrivilege.reward );
            var dailyRewardListData : CRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, dailyRewardID );
            dailyRewardList.repeatX = dailyRewardListData.list.length;
            dailyRewardList.centerX = 0;
            dailyRewardList.dataSource = dailyRewardListData.list;
            //等级礼包
            var lvRewardList : List = _hallView.lvList;
            lvRewardList.renderHandler = lvRewardList.renderHandler || new Handler( _renderLvItem );
            var lvPrivilegeArr:Array = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.GAME_HALL );
            lvRewardList.dataSource = lvPrivilegeArr;
        }

        private function _renderLvItem( item : Component, idx : int ) : void {
            var itemUI : HallLvItemUI = item as HallLvItemUI;
            var tencentLvPriviLege : TencentLevelPrivilege=item.dataSource as TencentLevelPrivilege;
            if ( !tencentLvPriviLege )return;
            var dailyRewardID : int = int( tencentLvPriviLege.reward );
            var dailyRewardListData : CRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, dailyRewardID );
            itemUI.list.repeatX = dailyRewardListData.list.length;
            itemUI.list.dataSource = dailyRewardListData.list;
            itemUI.list.renderHandler = itemUI.list.renderHandler || new Handler( _lvRewardRender );
            itemUI.lvtxt.num = tencentLvPriviLege.level;
            var qqClientDataManager : CQQClientDataManager = _system.getBean( CQQClientDataManager ) as CQQClientDataManager;
            var qqdata : CQQData = qqClientDataManager.qqData;
            var lvArr : Array = qqdata.lobby.lobbyLevelGift;
            if ( tencentLvPriviLege.level > qqClientDataManager.getPlayerLevel() ) {
                ObjectUtils.gray( itemUI.getBtn, true );
                itemUI.getBtn.clickHandler = null;
                itemUI.getBtn.label = "领取";
                itemUI.getBtn.visible = true;
                itemUI.getedImg.visible=false;
            } else {
                if ( lvArr.indexOf( tencentLvPriviLege.level ) != -1 ) {
                    ObjectUtils.gray( itemUI.getBtn, true );
                    itemUI.getBtn.clickHandler = null;
                    itemUI.getBtn.label = "已领取";
                    itemUI.getBtn.visible = false;
                    itemUI.getedImg.visible=true;
                }
                else {
                    ObjectUtils.gray( itemUI.getBtn, false );
                    itemUI.getBtn.clickHandler = new Handler( _getLvGift, [ tencentLvPriviLege.level ] );
                    itemUI.getBtn.label = "领取";
                    itemUI.getBtn.visible = true;
                    itemUI.getedImg.visible=false;
                }
            }
        }

        private function _lvRewardRender( item : Component, idx : int ) : void {
            var itemUI : RewardItemUI = item as RewardItemUI;
            var rewardData : CRewardData = item.dataSource as CRewardData;
            if ( !rewardData )return;
            itemUI.icon_image.url = rewardData.iconSmall;
            itemUI.num_lable.text = rewardData.num + "";

            var qqClientDataManager : CQQClientDataManager = _system.getBean( CQQClientDataManager ) as CQQClientDataManager;
            var itemTable : Item = qqClientDataManager.getItemForItemID( rewardData.ID );
            var itemNu : int = qqClientDataManager.getItemNuForBag( rewardData.ID );
            var itemData : CItemData = qqClientDataManager.getItemDataForItemID( rewardData.ID );
            itemUI.toolTip = itemUI.toolTip || new Handler( _showTips, [ itemNu, itemTable, itemData ] );

            itemUI.bg_clip.index = itemTable.quality;
        }

        private function _renderDayItem( item : Component, idx : int ) : void {
            var itemUI : ItemUIUI = item as ItemUIUI;
            var rewardData : CRewardData = item.dataSource as CRewardData;
            if ( !rewardData )return;
            itemUI.img.url = rewardData.iconBig;
            itemUI.txt_num.text = rewardData.num + "";

            var qqClientDataManager : CQQClientDataManager = _system.getBean( CQQClientDataManager ) as CQQClientDataManager;
            var itemTable : Item = qqClientDataManager.getItemForItemID( rewardData.ID );
            var itemNu : int = qqClientDataManager.getItemNuForBag( rewardData.ID );
            var itemData : CItemData = qqClientDataManager.getItemDataForItemID( rewardData.ID );
            itemUI.toolTip = itemUI.toolTip || new Handler( _showTips, [ itemNu, itemTable, itemData ] );

            itemUI.clip_bg.index = itemTable.quality;
        }

        private function _renderFreshItem( item : Component, idx : int ) : void {
            var itemUI : ItemUIUI = item as ItemUIUI;
            var rewardData : CRewardData = item.dataSource as CRewardData;
            if ( !rewardData )return;
            itemUI.img.url = rewardData.iconBig;
            itemUI.txt_num.text = rewardData.num + "";

            var qqClientDataManager : CQQClientDataManager = _system.getBean( CQQClientDataManager ) as CQQClientDataManager;
            var itemTable : Item = qqClientDataManager.getItemForItemID( rewardData.ID );
            var itemNu : int = qqClientDataManager.getItemNuForBag( rewardData.ID );
            var itemData : CItemData = qqClientDataManager.getItemDataForItemID( rewardData.ID );
            itemUI.toolTip = itemUI.toolTip || new Handler( _showTips, [ itemNu, itemTable, itemData ] );

            itemUI.clip_bg.index = itemTable.quality;
        }

        private function _selectCallBack( index : int ) : void {
            if ( index == 0 ) {
                _showNewBox();
            }
            else if ( index == 1 ) {
                _showDayBox();
            } else {
                _showLvList();
            }
        }

        private function _showNewBox() : void {
            _hallView.dayBox.visible = false;
            _hallView.lvList.visible = false;
            _hallView.newBox.visible = true;
        }

        private function _showDayBox() : void {
            _hallView.dayBox.visible = true;
            _hallView.lvList.visible = false;
            _hallView.newBox.visible = false;
        }

        private function _showLvList() : void {
            _hallView.dayBox.visible = false;
            _hallView.lvList.visible = true;
            _hallView.newBox.visible = false;
        }

        public function set uiCanvas( value : IUICanvas ) : void {
            _uiCanvas = value;
        }

        public function set closeHandler( value : Handler ) : void {
            _hallView.closeHandler = value;
        }

        public function close() : void {
            var hallViewHandler:CQQHallViewHandler = _system.getBean(CQQHallViewHandler);
            hallViewHandler.closeDialog();
        }

        public function show() : void {
            var hallViewHandler:CQQHallViewHandler = _system.getBean(CQQHallViewHandler);
            hallViewHandler.setTweenData(KOFSysTags.QQ_HALL);
            hallViewHandler.showDialog(_hallView);
        }

        public function update() : void {
            _judgeRedImg();
            _initConfigData();
            var qqdata : CQQData = _system.getBean( CQQClientDataManager ).qqData;
            var freshGetBtn : Button = _hallView.newBox.getChildByName( "getBtn" ) as Button;
            var freshGetReward:Image = _hallView.newBox.getChildByName( "getedImg" ) as Image;
            if ( qqdata.lobby.lobbyFreshGift ) {
                freshGetBtn.clickHandler = null;
                ObjectUtils.gray( freshGetBtn, true );
                freshGetBtn.label = "已领取";
                freshGetBtn.visible = false;
                freshGetReward.visible=true;
            } else {
                freshGetBtn.clickHandler = freshGetBtn.clickHandler || new Handler( _getFreshGift );
                ObjectUtils.gray( freshGetBtn, false );
                freshGetBtn.label = "领取";
                freshGetBtn.visible = true;
                freshGetReward.visible=false;
            }

            var dailyGetBtn : Button = _hallView.dayBox.getChildByName( "getBtn" ) as Button;
            var dialyGetReward:Image=_hallView.dayBox.getChildByName( "getedImg" ) as Image;
            if ( qqdata.lobby.lobbyDailyGift ) {
                dailyGetBtn.clickHandler = null;
                ObjectUtils.gray( dailyGetBtn, true );
                dailyGetBtn.label = "已领取";
                dailyGetBtn.visible = false;
                dialyGetReward.visible=true;
            } else {
                dailyGetBtn.clickHandler = dailyGetBtn.clickHandler || new Handler( _getDailyGift );
                ObjectUtils.gray( dailyGetBtn, false );
                dailyGetBtn.label = "领取";
                dailyGetBtn.visible = true;
                dialyGetReward.visible=false;
            }

            //等级礼包
            var lvRewardList : List = _hallView.lvList;
            lvRewardList.renderHandler = lvRewardList.renderHandler || new Handler( _renderLvItem );
            var lvPrivilegeArr : Array = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.GAME_HALL );
            lvRewardList.dataSource = lvPrivilegeArr;
        }

        private function _showTips( itemNu : int, itemTableData : Item, itemData : CItemData ) : void {
            _qqTipsView.showQQItemTips( itemNu, itemTableData, itemData );
        }

        private function _judgeRedImg() : void {
            if ( _judgeFreshRedImg() ) {
                _hallView.img_red1.visible = true;
            } else {
                _hallView.img_red1.visible = false;
            }
            if ( _judgeDailyRedImg() ) {
                _hallView.img_red2.visible = true;
            } else {
                _hallView.img_red2.visible = false;
            }
            if ( _judgeLvRedImg() ) {
                _hallView.img_red3.visible = true;
            } else {
                _hallView.img_red3.visible = false;
            }
        }

        private function _judgeLvRedImg() : Boolean {
            var _qqdata : CQQData = (_system.getBean( CQQClientDataManager ) as CQQClientDataManager).qqData;
            var lvPrivilegeArr : Array = [];
            var playerLv : int = (_system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.teamData.level;
            var alreadyCompareLv : int = 0;
            lvPrivilegeArr = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.GAME_HALL );
            for ( var k : int = 0; k < lvPrivilegeArr.length; k++ ) {
                if ( lvPrivilegeArr[ k ].level ) {
                    var hlv : int = Math.min( playerLv, lvPrivilegeArr[ k ].level );
                    if ( _qqdata.lobby.lobbyLevelGift.indexOf( hlv ) == -1 ) {
                        if ( playerLv < hlv ) {
                            return false;
                        }
                    } else {
                        continue;
                    }
                    alreadyCompareLv = lvPrivilegeArr[ k ].level;
                    if ( alreadyCompareLv > playerLv ) {
                        return false;
                    } else {
                        return true;
                    }
                }
            }
            return false;
        }

        private function _judgeDailyRedImg() : Boolean {
            var _qqdata : CQQData = (_system.getBean( CQQClientDataManager ) as CQQClientDataManager).qqData;
            if ( !_qqdata.lobby.lobbyDailyGift ) {
                return true;
            }
            return false;
        }

        private function _judgeFreshRedImg() : Boolean {
            var _qqdata : CQQData = (_system.getBean( CQQClientDataManager ) as CQQClientDataManager).qqData;
            if ( !_qqdata.lobby.lobbyFreshGift ) {
                return true;
            }
            return false;
        }
    }
}
