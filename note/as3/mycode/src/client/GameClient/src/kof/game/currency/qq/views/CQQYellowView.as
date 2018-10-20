//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/30.
 * Time: 19:27
 */
package kof.game.currency.qq.views {

    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    import kof.framework.CAppSystem;
import kof.game.KOFSysTags;

import kof.game.common.CRewardUtil;
    import kof.game.currency.CCurrencyHandler;
import kof.game.currency.qq.CQQYellowDiamondViewHandler;
import kof.game.currency.qq.data.configData.CQQTableDataManager;
    import kof.game.currency.qq.data.netData.CQQClientDataManager;
    import kof.game.currency.qq.data.netData.vo.CQQData;
    import kof.game.currency.qq.enums.ENetQQ;
    import kof.game.currency.qq.enums.EQQGiftType;
    import kof.game.currency.qq.enums.EQQRechargeType;
    import kof.game.currency.tipview.CQQTipsView;
    import kof.game.item.CItemData;
    import kof.game.item.data.CRewardData;
    import kof.game.item.data.CRewardListData;
import kof.game.platform.tx.data.CTXData;
import kof.game.player.CPlayerSystem;
    import kof.table.Item;
    import kof.table.TencentDailyPrivilege;
    import kof.table.TencentFreshPrivilege;
    import kof.table.TencentLevelPrivilege;
    import kof.ui.IUICanvas;
    import kof.ui.imp_common.ItemUIUI;
    import kof.ui.imp_common.RewardItemUI;
    import kof.ui.platform.qq.YellowDayItemUI;
    import kof.ui.platform.qq.YellowDiamondUI;
    import kof.ui.platform.qq.YellowLvItemUI;

    import morn.core.components.Box;
    import morn.core.components.Button;
    import morn.core.components.Component;
    import morn.core.components.List;
    import morn.core.handlers.Handler;
    import morn.core.utils.ObjectUtils;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/30
     */
    public class CQQYellowView {
        private var _uiCanvas : IUICanvas = null;
        private var _yellowView : YellowDiamondUI = null;
        private var _qqTipsView : CQQTipsView = null;
        private var _system : CAppSystem = null;

        public function CQQYellowView( sys : CAppSystem ) {
            this._system = sys;
            _yellowView = new YellowDiamondUI();
            _yellowView.btngroup.selectHandler = new Handler( _selectCallBack );
            _yellowView.dayBox.visible = false;
            _yellowView.lvList.visible = false;
            _yellowView.newBox.visible = false;

            with ( _yellowView.tequanBox ) {
                (getChildByName( "btn1" ) as Button).clickHandler = new Handler( _changeTab, [ "btn1" ] );
                (getChildByName( "btn2" ) as Button).clickHandler = new Handler( _changeTab, [ "btn2" ] );
                (getChildByName( "btn3" ) as Button).clickHandler = new Handler( _changeTab, [ "btn3" ] );
            }

            _qqTipsView = new CQQTipsView();

            _yellowView.recharge.clickHandler = new Handler( _recharge, [ EQQRechargeType.YELLOW ] );
            _yellowView.rechargeYear.clickHandler = new Handler( _recharge, [ EQQRechargeType.YELLOW_YEAR ] );
        }

        private function _recharge( type : int ) : void {
            _system.getBean( CQQClientDataManager ).navigateToQQRecharge( type );
        }

        private function _changeTab( btnName : String ) : void {
            if ( btnName == "btn1" ) {
                _yellowView.btngroup.selectedIndex = 1;
            } else if ( btnName == "btn2" ) {
                _yellowView.btngroup.selectedIndex = 2;
            } else if ( btnName == "btn3" ) {
                _yellowView.btngroup.selectedIndex = 3;
            }
        }

        private function _selectCallBack( index : int ) : void {
            if ( index == 0 ) {
                _showIntroduce();
            } else if ( index == 1 ) {
                _showNoviceGift();
            } else if ( index == 2 ) {
                _showDayGift();
            } else {
                _showLvGift();
            }
        }

        private function _showIntroduce() : void {
            _yellowView.tequanBox.visible = true;
            _yellowView.dayBox.visible = false;
            _yellowView.lvList.visible = false;
            _yellowView.newBox.visible = false;
        }

        private function _showNoviceGift() : void {
            _yellowView.tequanBox.visible = false;
            _yellowView.dayBox.visible = false;
            _yellowView.lvList.visible = false;
            _yellowView.newBox.visible = true;
        }

        private function _showDayGift() : void {
            _yellowView.tequanBox.visible = false;
            _yellowView.dayBox.visible = true;
            _yellowView.lvList.visible = false;
            _yellowView.newBox.visible = false;
        }

        private function _showLvGift() : void {
            _yellowView.tequanBox.visible = false;
            _yellowView.dayBox.visible = false;
            _yellowView.lvList.visible = true;
            _yellowView.newBox.visible = false;
        }

        public function set uiCanvas( value : IUICanvas ) : void {
            _uiCanvas = value;

            var yellowViewHandler:CQQYellowDiamondViewHandler = _system.getBean(CQQYellowDiamondViewHandler);
            yellowViewHandler.setTweenData(KOFSysTags.QQ_YELLOW_DIAMOND);
            yellowViewHandler.showDialog(_yellowView);
//            _uiCanvas.addDialog( _yellowView );
        }

        public function set closeHandler( value : Handler ) : void {
            _yellowView.closeHandler = value;
        }

        public function close() : void {
            var yellowViewHandler:CQQYellowDiamondViewHandler = _system.getBean(CQQYellowDiamondViewHandler);
            yellowViewHandler.closeDialog();
        }

        public function update() : void {
            _judgeRedImg();
            _initConfigData();
            var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;

            var qqdata : CQQData = _system.getBean( CQQClientDataManager ).qqData;
            var freshGetBtn : Button = _yellowView.newBox.getChildByName( "getBtn" ) as Button;
            if ( qqdata.yellow.yellowFreshGift ) {
                freshGetBtn.clickHandler = null;
                ObjectUtils.gray( freshGetBtn, true );
                freshGetBtn.label = "已领取";
            } else {
                freshGetBtn.label = "领取";
                if ( txData.isYellowVip || txData.isYellowYearVip ) {
                    freshGetBtn.clickHandler = freshGetBtn.clickHandler || new Handler( _getFreshGift );
                    ObjectUtils.gray( freshGetBtn, false );
                } else {
                    freshGetBtn.clickHandler = null;
                    ObjectUtils.gray( freshGetBtn, true );
                }
            }
            var dailyGetBtnStateArr : Array = qqdata.yellow.yellowDailyGift;
            var dailyGetBtn : Button = null;
            if ( dailyGetBtnStateArr.length == 0 ) {
                dailyGetBtn = _yellowView.dayBox.getChildByName( "getBtn1" ) as Button;
                ObjectUtils.gray( dailyGetBtn, true );
                dailyGetBtn = _yellowView.dayBox.getChildByName( "getBtn2" ) as Button;
                ObjectUtils.gray( dailyGetBtn, true );
            } else {
                for ( var i : int = 1; i <= dailyGetBtnStateArr.length; i++ ) {
                    if ( i == 1 ) {
                        dailyGetBtn = _yellowView.dayBox.getChildByName( "getBtn1" ) as Button;
                        if ( txData.isYellowVip || txData.isYellowYearVip ) {
                            if ( dailyGetBtnStateArr[ i - 1 ] ) {
                                dailyGetBtn.clickHandler = null;
                                ObjectUtils.gray( dailyGetBtn, true );
                                dailyGetBtn.label = "已领取";
                            } else {
                                dailyGetBtn.clickHandler = dailyGetBtn.clickHandler || new Handler( _getDailyGift, [ "getBtn1" ] );
                                ObjectUtils.gray( dailyGetBtn, false );
                                dailyGetBtn.label = "领取";
                            }
                        } else {
                            dailyGetBtn.clickHandler = null;
                            ObjectUtils.gray( dailyGetBtn, true );
                        }
                    }
                    if ( i == 2 ) {
                        dailyGetBtn = _yellowView.dayBox.getChildByName( "getBtn2" ) as Button;
                        if ( txData.isYellowYearVip ) {
                            if ( dailyGetBtnStateArr[ i - 1 ] ) {
                                dailyGetBtn.clickHandler = null;
                                ObjectUtils.gray( dailyGetBtn, true );
                                dailyGetBtn.label = "已领取";
                            } else {
                                dailyGetBtn.clickHandler = dailyGetBtn.clickHandler || new Handler( _getDailyGift, [ "getBtn2" ] );
                                ObjectUtils.gray( dailyGetBtn, false );
                                dailyGetBtn.label = "领取";
                            }
                        } else {
                            dailyGetBtn.clickHandler = null;
                            ObjectUtils.gray( dailyGetBtn, true );
                        }
                    }
                }
            }

            //等级礼包
            _yellowView.show();
        }

        private function _initConfigData() : void {
            //新手礼包配置数据
            var freshRewardList : List = _yellowView.newBox.getChildByName( "itemList" ) as List;
            freshRewardList.renderHandler = freshRewardList.renderHandler || new Handler( _renderFreshItem );
            var tencentFreshPrivilege : TencentFreshPrivilege = CQQTableDataManager.instance.getTencentFreshPrivilege( EQQGiftType.YELLOW_DIAMOND );
            var freshRewardID : int = tencentFreshPrivilege.reward;
            var freshRewardListData : CRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, freshRewardID );
            var itemListArr : Array = freshRewardListData.list;
            freshRewardList.repeatX = itemListArr.length;
            freshRewardList.centerX = 0;
            freshRewardList.dataSource = itemListArr;
            //每日礼包配置数据
            //普通黄钻
            var dailyRewardList : List = _yellowView.dayBox.getChildByName( "itemList" ) as List;
            dailyRewardList.renderHandler = dailyRewardList.renderHandler || new Handler( _renderDayItem );
            var tencentDailyPrivilege : TencentDailyPrivilege = CQQTableDataManager.instance.getTencentDailyPrivilege( EQQGiftType.YELLOW_DIAMOND );
            var rewardIDArr : Array = tencentDailyPrivilege.reward.split( "," );
            var arr : Array = [];
            var dailyRewardListData : CRewardListData = null;
            for ( var i : int = 0; i < rewardIDArr.length; i++ ) {
                dailyRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, int( rewardIDArr[ i ] ) );
                arr.push( dailyRewardListData );
            }
            dailyRewardList.dataSource = arr;
            //年费黄钻
            dailyRewardList = (_yellowView.dayBox.getChildByName( "yearBox" ) as Box).getChildByName( "yearList" ) as List;
            dailyRewardList.renderHandler = dailyRewardList.renderHandler || new Handler( _renderYearItem );
            tencentDailyPrivilege = CQQTableDataManager.instance.getTencentDailyPrivilege( EQQGiftType.YELLOW_DIAMOND );
            var dailyRewardID : int = int( tencentDailyPrivilege.yearReward );
            dailyRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, dailyRewardID );
            dailyRewardList.repeatX = itemListArr.length;
            dailyRewardList.centerX = 0;
            dailyRewardList.dataSource = dailyRewardListData.list;
            //等级礼包
            var lvRewardList : List = _yellowView.lvList;
            lvRewardList.renderHandler = lvRewardList.renderHandler || new Handler( _renderLvItem );
            var lvPrivilegeArr : Array = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.YELLOW_DIAMOND );
            lvRewardList.dataSource = lvPrivilegeArr;
        }

        private function _renderLvItem( item : Component, idx : int ) : void {
            var itemUI : YellowLvItemUI = item as YellowLvItemUI;
            var tencentLvPriviLege : TencentLevelPrivilege = item.dataSource as TencentLevelPrivilege;
            if ( !tencentLvPriviLege )return;
            var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;

            var dailyRewardID : int = int( tencentLvPriviLege.reward );
            var dailyRewardListData : CRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, dailyRewardID );
            itemUI.list.repeatX = dailyRewardListData.list.length;
            itemUI.list.dataSource = dailyRewardListData.list;
            itemUI.list.renderHandler = itemUI.list.renderHandler || new Handler( _lvRewardRender );
            itemUI.lvtxt.num = tencentLvPriviLege.level;
            var qqClientDataManager : CQQClientDataManager = _system.getBean( CQQClientDataManager ) as CQQClientDataManager;
            var qqdata : CQQData = qqClientDataManager.qqData;
            var lvArr : Array = qqdata.yellow.yellowLevelGift;
            if ( tencentLvPriviLege.level > qqClientDataManager.getPlayerLevel() ) {
                ObjectUtils.gray( itemUI.getBtn, true );
                itemUI.getBtn.label = "领取";
            } else {
                if ( lvArr.indexOf( tencentLvPriviLege.level ) != -1 ) {
                    itemUI.getBtn.clickHandler = null;
                    ObjectUtils.gray( itemUI.getBtn, true );
                    itemUI.getBtn.label = "已领取";
                } else {
                    itemUI.getBtn.label = "领取";
                    if ( txData.isYellowVip || txData.isYellowYearVip ) {
                        itemUI.getBtn.clickHandler = new Handler( _getLvGift, [ tencentLvPriviLege.level ] );
                        ObjectUtils.gray( itemUI.getBtn, false );
                    } else {
                        itemUI.getBtn.clickHandler = null;
                        ObjectUtils.gray( itemUI.getBtn, true );
                    }
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

        private function _renderYearItem( item : Component, idx : int ) : void {
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
            var itemUI : YellowDayItemUI = item as YellowDayItemUI;
            var rewardListData : CRewardListData = item.dataSource as CRewardListData;
            if ( !rewardListData )return;
            var itemList : List = itemUI.getChildByName( "rewardList" ) as List;
            itemList.repeatX = rewardListData.list.length;
            itemList.dataSource = rewardListData.list;
            itemList.renderHandler = itemList.renderHandler || new Handler( _dailyGenneryItem );
            itemUI.diamondClip.index = idx;
        }

        private function _dailyGenneryItem( item : Component, idx : int ) : void {
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
            itemUI.toolTip = new Handler( _showTips, [ itemNu, itemTable, itemData ] );

            itemUI.clip_bg.index = itemTable.quality;
        }

        private function _getDailyGift( btnName : String ) : void {
            if ( btnName == "getBtn1" ) {
                (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.DAILY, ENetQQ.YELLOW, ENetQQ.GENERAL );
            } else if ( btnName == "getBtn2" ) {
                (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.DAILY, ENetQQ.YELLOW, ENetQQ.YEAR );
            }
        }

        private function _getFreshGift() : void {
            (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.FRESH, ENetQQ.YELLOW, 0 );
        }

        //领取等级奖励
        private function _getLvGift( lv : int ) : void {
            (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.LEVEL, ENetQQ.YELLOW, lv );
        }

        private function _showTips( itemNu : int, itemTableData : Item, itemData : CItemData ) : void {
            _qqTipsView.showQQItemTips( itemNu, itemTableData, itemData );
        }


        private function _judgeRedImg() : void {
            if ( _judgeFreshRedImg() ) {
                _yellowView.img_red1.visible = true;
            } else {
                _yellowView.img_red1.visible = false;
            }
            if ( _judgeDailyRedImg() ) {
                _yellowView.img_red2.visible = true;
            } else {
                _yellowView.img_red2.visible = false;
            }
            if ( _judgeLvRedImg() ) {
                _yellowView.img_red3.visible = true;
            } else {
                _yellowView.img_red3.visible = false;
            }
        }

        private function _judgeLvRedImg() : Boolean {
            var _qqdata : CQQData = (_system.getBean( CQQClientDataManager ) as CQQClientDataManager).qqData;
            var lvPrivilegeArr : Array = [];
            var playerLv : int = (_system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.teamData.level;
            var alreadyCompareLv : int = 0;
            for ( var j : int = 0; j < lvPrivilegeArr.length; j++ ) {
                if ( lvPrivilegeArr[ j ].level ) {
                    var ylv : int = Math.min( playerLv, lvPrivilegeArr[ j ].level );
                    if ( _qqdata.yellow.yellowLevelGift.indexOf( ylv ) == -1 ) {
                        if ( playerLv < ylv ) {
                            return false;
                        }
                    } else {
                        continue;
                    }
                    alreadyCompareLv = lvPrivilegeArr[ j ].level;
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
            var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;
            var _qqdata : CQQData = (_system.getBean( CQQClientDataManager ) as CQQClientDataManager).qqData;
            if ( txData.isYellowYearVip ) {
                if ( _qqdata.yellow.yellowDailyGift.indexOf( false ) != -1 ) {
                    return true;
                }
            } else if ( txData.isYellowVip ) {
                if ( _qqdata.yellow.yellowDailyGift[ 0 ] != false ) {
                    return true;
                }
            }
            return false;
        }

        private function _judgeFreshRedImg() : Boolean {
            var _qqdata : CQQData = (_system.getBean( CQQClientDataManager ) as CQQClientDataManager).qqData;
            if ( !_qqdata.yellow.yellowFreshGift ) {
                return true;
            }
            return false;
        }
    }
}
