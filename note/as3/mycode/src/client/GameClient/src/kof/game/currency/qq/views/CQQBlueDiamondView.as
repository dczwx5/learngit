//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/27.
 * Time: 12:21
 */
package kof.game.currency.qq.views {

    import flash.events.MouseEvent;
    import kof.framework.CAppSystem;
import kof.game.KOFSysTags;

import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.CTweenViewHandler;
import kof.game.currency.CCurrencyHandler;
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
    import kof.ui.platform.qq.BlueDayItemUI;
    import kof.ui.platform.qq.BlueDiamondUI;
    import kof.ui.platform.qq.BlueLvItemUI;

    import morn.core.components.Box;
    import morn.core.components.Button;

    import morn.core.components.Component;
import morn.core.components.Image;

import morn.core.components.List;

    import morn.core.handlers.Handler;
    import morn.core.utils.ObjectUtils;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/27
     */
    public class CQQBlueDiamondView {
        private var _uiCanvas : IUICanvas = null;
        private var _blueDiamondView : BlueDiamondUI = null;
        private var _qqTipsView : CQQTipsView = null;
        private var _system : CAppSystem = null;

        public function CQQBlueDiamondView( sys : CAppSystem ) {
            this._system = sys;
            _blueDiamondView = new BlueDiamondUI();
            _blueDiamondView.btngroup.selectHandler = new Handler( _selectCallBack );
            _blueDiamondView.dayBox.visible = false;
            _blueDiamondView.lvList.visible = false;
            _blueDiamondView.newBox.visible = false;
            _blueDiamondView.gotoGuanWang.addEventListener( MouseEvent.CLICK, _gotoGuanWang );
            with ( _blueDiamondView.tequanBox ) {
                (getChildByName( "btn1" ) as Button).clickHandler = new Handler( _changeTab, [ "btn1" ] );
                (getChildByName( "btn2" ) as Button).clickHandler = new Handler( _changeTab, [ "btn2" ] );
                (getChildByName( "btn3" ) as Button).clickHandler = new Handler( _changeTab, [ "btn3" ] );
            }

            _qqTipsView = new CQQTipsView();
        }

        private function _gotoGuanWang( e : MouseEvent ) : void {
            _system.getBean( CQQClientDataManager ).navigateToGuanWang();
        }

        private function _recharge( type : int ) : void {
            _system.getBean( CQQClientDataManager ).navigateToQQRecharge( type );
        }

        private function _changeTab( btnName : String ) : void {
            if ( btnName == "btn1" ) {
                _blueDiamondView.btngroup.selectedIndex = 1;
            } else if ( btnName == "btn2" ) {
                _blueDiamondView.btngroup.selectedIndex = 2;
            } else if ( btnName == "btn3" ) {
                _blueDiamondView.btngroup.selectedIndex = 3;
            }
        }

        private function _initConfigData() : void {
            //新手礼包配置数据
            var freshRewardList : List = _blueDiamondView.newBox.getChildByName( "itemList" ) as List;
            freshRewardList.renderHandler = freshRewardList.renderHandler || new Handler( _renderFreshItem );
            var tencentFreshPrivilege : TencentFreshPrivilege = CQQTableDataManager.instance.getTencentFreshPrivilege( EQQGiftType.BLUE_DIAMOND );
            var freshRewardID : int = tencentFreshPrivilege.reward;
            var freshRewardListData : CRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, freshRewardID );
            var itemListArr : Array = freshRewardListData.list;
            freshRewardList.repeatX = itemListArr.length;
            freshRewardList.centerX = 0;
            freshRewardList.dataSource = itemListArr;
            //每日礼包配置数据
            //普通蓝钻
            var dailyRewardList : List = _blueDiamondView.dayBox.getChildByName( "itemList" ) as List;
            dailyRewardList.renderHandler = dailyRewardList.renderHandler || new Handler( _renderDayItem );
            var tencentDailyPrivilege : TencentDailyPrivilege = CQQTableDataManager.instance.getTencentDailyPrivilege( EQQGiftType.BLUE_DIAMOND );
            var rewardIDArr : Array = tencentDailyPrivilege.reward.split( "," );
            var arr : Array = [];
            var dailyRewardListData : CRewardListData = null;
            for ( var i : int = 0; i < 7; i++ ) { //蓝钻只有7个等级
                dailyRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, int( rewardIDArr[ i ] ) );
                arr.push( dailyRewardListData );
            }
            dailyRewardList.dataSource = arr;
            //豪华蓝钻
            dailyRewardList = (_blueDiamondView.dayBox.getChildByName( "superBox" ) as Box).getChildByName( "superList" ) as List;
            dailyRewardList.renderHandler = dailyRewardList.renderHandler || new Handler( _renderSuperItem );
            tencentDailyPrivilege = CQQTableDataManager.instance.getTencentDailyPrivilege( EQQGiftType.BLUE_DIAMOND );
            var dailyRewardID : int = int( tencentDailyPrivilege.superReward );
            dailyRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, dailyRewardID );
            dailyRewardList.repeatX = itemListArr.length;
            dailyRewardList.centerX = 0;
            dailyRewardList.dataSource = dailyRewardListData.list;
            //年费蓝钻
            dailyRewardList = (_blueDiamondView.dayBox.getChildByName( "yearBox" ) as Box).getChildByName( "yearList" ) as List;
            dailyRewardList.renderHandler = dailyRewardList.renderHandler || new Handler( _renderYearItem );
            tencentDailyPrivilege = CQQTableDataManager.instance.getTencentDailyPrivilege( EQQGiftType.BLUE_DIAMOND );
            dailyRewardID = int( tencentDailyPrivilege.yearReward );
            dailyRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, dailyRewardID );
            dailyRewardList.repeatX = itemListArr.length;
            dailyRewardList.centerX = 0;
            dailyRewardList.dataSource = dailyRewardListData.list;
            //等级礼包
            var lvRewardList : List = _blueDiamondView.lvList;
            lvRewardList.renderHandler = lvRewardList.renderHandler || new Handler( _renderLvItem );
            var lvPrivilegeArr : Array = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.BLUE_DIAMOND );
            lvRewardList.dataSource = lvPrivilegeArr;
        }

        private function _renderLvItem( item : Component, idx : int ) : void {
            var itemUI : BlueLvItemUI = item as BlueLvItemUI;
            var tencentLvPriviLege : TencentLevelPrivilege = item.dataSource as TencentLevelPrivilege;
            if ( !tencentLvPriviLege )return;
            var dailyRewardID : int = int( tencentLvPriviLege.reward );
            var dailyRewardListData : CRewardListData = CRewardUtil.createByDropPackageID( CQQTableDataManager.instance.system.stage, dailyRewardID );
            itemUI.list.repeatX = dailyRewardListData.list.length;
            itemUI.list.dataSource = dailyRewardListData.list;
            itemUI.list.renderHandler = itemUI.list.renderHandler || new Handler( _lvRewardRender );
            itemUI.lvtxt.num = tencentLvPriviLege.level;
            var qqClientDataManager : CQQClientDataManager = _system.getBean( CQQClientDataManager ) as CQQClientDataManager;
            var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;

            var qqdata : CQQData = qqClientDataManager.qqData;
            var lvArr : Array = qqdata.blue.blueLevelGift;
            if ( tencentLvPriviLege.level > qqClientDataManager.getPlayerLevel() ) {
                ObjectUtils.gray( itemUI.getBtn, true );
                itemUI.getBtn.label = "领取";
                itemUI.getBtn.visible = true;
                itemUI.getedImg.visible = false;
            } else {
                if ( lvArr.indexOf( tencentLvPriviLege.level ) != -1 ) {
                    itemUI.getBtn.clickHandler = null;
                    ObjectUtils.gray( itemUI.getBtn, true );
                    itemUI.getBtn.label = "已领取";
                    itemUI.getBtn.visible = false;
                    itemUI.getedImg.visible = true;
                } else {
                    itemUI.getBtn.label = "领取";
                    itemUI.getBtn.visible = true;
                    itemUI.getedImg.visible = false;
                    if ( txData.isBlueVip || txData.isBlueYearVip || txData.isSuperBlueVip ) {
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

            var itemTable : Item = _system.getBean( CQQClientDataManager ).getItemForItemID( rewardData.ID );
            var itemNu : int = _system.getBean( CQQClientDataManager ).getItemNuForBag( rewardData.ID );
            var itemData : CItemData = _system.getBean( CQQClientDataManager ).getItemDataForItemID( rewardData.ID );
            itemUI.toolTip = itemUI.toolTip || new Handler( _showTips, [ itemNu, itemTable, itemData ] );

            itemUI.bg_clip.index = itemTable.quality;
        }

        private function _renderYearItem( item : Component, idx : int ) : void {
            var itemUI : RewardItemUI = item as RewardItemUI;
            var rewardData : CRewardData = item.dataSource as CRewardData;
            if ( !rewardData )return;
            itemUI.icon_image.url = rewardData.iconSmall;
            itemUI.num_lable.text = rewardData.num + "";

            var itemTable : Item = _system.getBean( CQQClientDataManager ).getItemForItemID( rewardData.ID );
            var itemNu : int = _system.getBean( CQQClientDataManager ).getItemNuForBag( rewardData.ID );
            var itemData : CItemData = _system.getBean( CQQClientDataManager ).getItemDataForItemID( rewardData.ID );
            itemUI.toolTip = itemUI.toolTip || new Handler( _showTips, [ itemNu, itemTable, itemData ] );

            itemUI.bg_clip.index = itemTable.quality;
        }

        private function _renderSuperItem( item : Component, idx : int ) : void {
            var itemUI : RewardItemUI = item as RewardItemUI;
            var rewardData : CRewardData = item.dataSource as CRewardData;
            if ( !rewardData )return;
            itemUI.icon_image.url = rewardData.iconSmall;
            itemUI.num_lable.text = rewardData.num + "";

            var itemTable : Item = _system.getBean( CQQClientDataManager ).getItemForItemID( rewardData.ID );
            var itemNu : int = _system.getBean( CQQClientDataManager ).getItemNuForBag( rewardData.ID );
            var itemData : CItemData = _system.getBean( CQQClientDataManager ).getItemDataForItemID( rewardData.ID );
            itemUI.toolTip = itemUI.toolTip || new Handler( _showTips, [ itemNu, itemTable, itemData ] );

            itemUI.bg_clip.index = itemTable.quality;
        }

        private function _renderDayItem( item : Component, idx : int ) : void {
            var itemUI : BlueDayItemUI = item as BlueDayItemUI;
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

            var itemTable : Item = _system.getBean( CQQClientDataManager ).getItemForItemID( rewardData.ID );
            var itemNu : int = _system.getBean( CQQClientDataManager ).getItemNuForBag( rewardData.ID );
            var itemData : CItemData = _system.getBean( CQQClientDataManager ).getItemDataForItemID( rewardData.ID );
            itemUI.toolTip = itemUI.toolTip || new Handler( _showTips, [ itemNu, itemTable, itemData ] );

            itemUI.bg_clip.index = itemTable.quality;
        }

        private function _renderFreshItem( item : Component, idx : int ) : void {
            var itemUI : ItemUIUI = item as ItemUIUI;
            var rewardData : CRewardData = item.dataSource as CRewardData;
            if ( !rewardData )return;
            itemUI.img.url = rewardData.iconBig;
            itemUI.txt_num.text = rewardData.num + "";

            var qqClientManager : CQQClientDataManager = _system.getBean( CQQClientDataManager ) as CQQClientDataManager;
            var itemTable : Item = qqClientManager.getItemForItemID( rewardData.ID );
            var itemNu : int = qqClientManager.getItemNuForBag( rewardData.ID );
            var itemData : CItemData = qqClientManager.getItemDataForItemID( rewardData.ID );
            itemUI.toolTip = itemUI.toolTip || new Handler( _showTips, [ itemNu, itemTable, itemData ] );

            itemUI.clip_bg.index = itemTable.quality;
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
            _blueDiamondView.tequanBox.visible = true;
            _blueDiamondView.dayBox.visible = false;
            _blueDiamondView.lvList.visible = false;
            _blueDiamondView.newBox.visible = false;
        }

        private function _showNoviceGift() : void {
            _blueDiamondView.tequanBox.visible = false;
            _blueDiamondView.dayBox.visible = false;
            _blueDiamondView.lvList.visible = false;
            _blueDiamondView.newBox.visible = true;
        }

        private function _showDayGift() : void {
            _blueDiamondView.tequanBox.visible = false;
            _blueDiamondView.dayBox.visible = true;
            _blueDiamondView.lvList.visible = false;
            _blueDiamondView.newBox.visible = false;
        }

        private function _showLvGift() : void {
            _blueDiamondView.tequanBox.visible = false;
            _blueDiamondView.dayBox.visible = false;
            _blueDiamondView.lvList.visible = true;
            _blueDiamondView.newBox.visible = false;
        }

        public function set uiCanvas( value : IUICanvas ) : void {
            _uiCanvas = value;
        }

        public function set closeHandler( value : Handler ) : void {
            _blueDiamondView.closeHandler = value;
        }

        public function close() : void {
            var pViewHandler:CTweenViewHandler = _system.getBean(CTweenViewHandler);
            pViewHandler.closeDialog();
        }

        public function show() : void {
            //等级礼包

            var pViewHandler:CTweenViewHandler = _system.getBean(CTweenViewHandler);
            pViewHandler.setTweenData(KOFSysTags.QQ_BLUE_DIAMOND);
            pViewHandler.showDialog(_blueDiamondView);
        }

        public function update() : void {
            _judgeRedImg();

            _initConfigData();

            var qqdata : CQQData = _system.getBean( CQQClientDataManager ).qqData;
            var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;

            var freshGetBtn : Button = _blueDiamondView.newBox.getChildByName( "getBtn" ) as Button;
            var getReward:Image = _blueDiamondView.newBox.getChildByName( "getedImg" ) as Image;
            if ( qqdata.blue.blueFreshGift ) {
                freshGetBtn.clickHandler = null;
                ObjectUtils.gray( freshGetBtn, true );
                freshGetBtn.label = "已领取";
                freshGetBtn.visible = false;
                getReward.visible = true;
            } else {
                freshGetBtn.label = "领取";
                freshGetBtn.visible = true;
                getReward.visible = false;
                if ( txData.isBlueVip || txData.isBlueYearVip || txData.isSuperBlueVip ) {
                    freshGetBtn.clickHandler = freshGetBtn.clickHandler || new Handler( _getFreshGift );
                    ObjectUtils.gray( freshGetBtn, false );
                } else {
                    freshGetBtn.clickHandler = null;
                    ObjectUtils.gray( freshGetBtn, true );
                }
            }
            var dailyGetBtnStateArr : Array = qqdata.blue.blueDailyGift;
            var dailyGetBtn : Button = null;
            if ( dailyGetBtnStateArr.length == 0 ) {
                dailyGetBtn = _blueDiamondView.dayBox.getChildByName( "getBtn1" ) as Button;
                ObjectUtils.gray( dailyGetBtn, true );
                dailyGetBtn = _blueDiamondView.dayBox.getChildByName( "getBtn2" ) as Button;
                ObjectUtils.gray( dailyGetBtn, true );
                dailyGetBtn = _blueDiamondView.dayBox.getChildByName( "getBtn3" ) as Button;
                ObjectUtils.gray( dailyGetBtn, true );
            } else {
                for ( var i : int = 1; i <= dailyGetBtnStateArr.length; i++ ) {
                    if ( i == 1 ) {
                        dailyGetBtn = _blueDiamondView.dayBox.getChildByName( "getBtn1" ) as Button;
                        if ( txData.isBlueVip || txData.isBlueYearVip || txData.isSuperBlueVip || txData.isSuperBlueYearVip ) {
                            if ( dailyGetBtnStateArr[ i - 1 ] ) {
                                dailyGetBtn.clickHandler = null;
                                ObjectUtils.gray( dailyGetBtn, true );
                                dailyGetBtn.label = "已领取";
                                dailyGetBtn.visible = false;
                                _blueDiamondView.getedImg1.visible = true;
                            } else {
                                dailyGetBtn.clickHandler = dailyGetBtn.clickHandler || new Handler( _getDailyGift, [ "getBtn1" ] );
                                ObjectUtils.gray( dailyGetBtn, false );
                                dailyGetBtn.label = "领取";
                                dailyGetBtn.visible = true;
                                _blueDiamondView.getedImg1.visible = false;
                            }
                        } else {
                            dailyGetBtn.clickHandler = null;
                            ObjectUtils.gray( dailyGetBtn, true );
                            dailyGetBtn.visible = true;
                            _blueDiamondView.getedImg1.visible = false;
                        }
                    }
                    if ( i == 2 ) {
                        dailyGetBtn = _blueDiamondView.dayBox.getChildByName( "getBtn2" ) as Button;
                        if ( txData.isSuperBlueVip || txData.isSuperBlueYearVip ) {
                            if ( dailyGetBtnStateArr[ i - 1 ] ) {
                                dailyGetBtn.clickHandler = null;
                                ObjectUtils.gray( dailyGetBtn, true );
                                dailyGetBtn.label = "已领取";
                                dailyGetBtn.visible = false;
                                _blueDiamondView.getedImg2.visible = true;
                            } else {
                                dailyGetBtn.clickHandler = dailyGetBtn.clickHandler || new Handler( _getDailyGift, [ "getBtn2" ] );
                                ObjectUtils.gray( dailyGetBtn, false );
                                dailyGetBtn.label = "领取";
                                dailyGetBtn.visible = true;
                                _blueDiamondView.getedImg2.visible = false;
                            }
                        } else {
                            dailyGetBtn.clickHandler = null;
                            ObjectUtils.gray( dailyGetBtn, true );
                            dailyGetBtn.visible = true;
                            _blueDiamondView.getedImg2.visible = false;
                        }
                    }
                    if ( i == 3 ) {
                        dailyGetBtn = _blueDiamondView.dayBox.getChildByName( "getBtn3" ) as Button;
                        if ( txData.isBlueYearVip || txData.isSuperBlueYearVip ) {
                            if ( dailyGetBtnStateArr[ i - 1 ] ) {
                                dailyGetBtn.clickHandler = null;
                                ObjectUtils.gray( dailyGetBtn, true );
                                dailyGetBtn.label = "已领取";
                                dailyGetBtn.visible = false;
                                _blueDiamondView.getedImg3.visible = true;
                            } else {
                                dailyGetBtn.clickHandler = dailyGetBtn.clickHandler || new Handler( _getDailyGift, [ "getBtn3" ] );
                                ObjectUtils.gray( dailyGetBtn, false );
                                dailyGetBtn.label = "领取";
                                dailyGetBtn.visible = true;
                                _blueDiamondView.getedImg3.visible = false;
                            }
                        } else {
                            dailyGetBtn.clickHandler = null;
                            ObjectUtils.gray( dailyGetBtn, true );
                            dailyGetBtn.visible = true;
                            _blueDiamondView.getedImg3.visible = false;
                        }
                    }
                }
            }
            //等级礼包
            var lvRewardList : List = _blueDiamondView.lvList;
            lvRewardList.renderHandler = lvRewardList.renderHandler || new Handler( _renderLvItem );
            var lvPrivilegeArr : Array = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.BLUE_DIAMOND );
            lvRewardList.dataSource = lvPrivilegeArr;
            var qqDataManager : CQQClientDataManager = _system.getBean( CQQClientDataManager ) as CQQClientDataManager;
            if ( txData.isBlueVip || txData.isSuperBlueVip ) {
                _blueDiamondView.recharge.visible = false;
                _blueDiamondView.pr.visible = true;
                _blueDiamondView.pr.clickHandler = _blueDiamondView.pr.clickHandler || new Handler( _recharge, [ EQQRechargeType.BLUE ] );
            } else {
                _blueDiamondView.recharge.visible = true;
                _blueDiamondView.pr.visible = false;
                _blueDiamondView.recharge.clickHandler = _blueDiamondView.recharge.clickHandler || new Handler( _recharge, [ EQQRechargeType.BLUE ] );
            }
            if ( txData.isBlueYearVip || txData.isSuperBlueYearVip ) {
                _blueDiamondView.pry.visible = true;
                _blueDiamondView.rechargeYear.visible = false;
                _blueDiamondView.pry.clickHandler = _blueDiamondView.pry.clickHandler || new Handler( _recharge, [ EQQRechargeType.BLUE_YEAR ] );
            } else {
                _blueDiamondView.pry.visible = false;
                _blueDiamondView.rechargeYear.visible = true;
                _blueDiamondView.rechargeYear.clickHandler = _blueDiamondView.rechargeYear.clickHandler || new Handler( _recharge, [ EQQRechargeType.BLUE_YEAR ] );
            }
        }

        private function _getDailyGift( btnName : String ) : void {
            if ( btnName == "getBtn1" ) {
                (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.DAILY, ENetQQ.BLUE, ENetQQ.GENERAL );
            } else if ( btnName == "getBtn2" ) {
                (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.DAILY, ENetQQ.BLUE, ENetQQ.LUXURY );
            } else if ( btnName == "getBtn3" ) {
                (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.DAILY, ENetQQ.BLUE, ENetQQ.YEAR );
            }
        }

        private function _getFreshGift() : void {
            (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.FRESH, ENetQQ.BLUE, 0 );
        }

        //领取等级奖励
        private function _getLvGift( lv : int ) : void {
            (_system.getBean( CCurrencyHandler ) as CCurrencyHandler).requestTencentGift( ENetQQ.LEVEL, ENetQQ.BLUE, lv );
        }

        private function _showTips( itemNu : int, itemTableData : Item, itemData : CItemData ) : void {
            _qqTipsView.showQQItemTips( itemNu, itemTableData, itemData );
        }

        private function _judgeRedImg() : void {
            if ( _judgeFreshRedImg() ) {
                _blueDiamondView.img_red1.visible = true;
            } else {
                _blueDiamondView.img_red1.visible = false;
            }
            if ( _judgeDailyRedImg() ) {
                _blueDiamondView.img_red2.visible = true;
            } else {
                _blueDiamondView.img_red2.visible = false;
            }
            if ( _judgeLvRedImg() ) {
                _blueDiamondView.img_red3.visible = true;
            } else {
                _blueDiamondView.img_red3.visible = false;
            }
        }

        private function _judgeLvRedImg() : Boolean {
            var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;
            if (!txData) return false;

            var _qqdata : CQQData = (_system.getBean( CQQClientDataManager ) as CQQClientDataManager).qqData;
            if(txData.isSuperBlueYearVip||txData.isBlueYearVip||txData.isSuperBlueVip||txData.isBlueVip){
                var lvPrivilegeArr : Array = [];
                var playerLv : int = (_system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.teamData.level;
                var alreadyCompareLv : int = 0;
                lvPrivilegeArr = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.BLUE_DIAMOND );
                alreadyCompareLv = 0;
                for ( var i : int = 0; i < lvPrivilegeArr.length; i++ ) {
                    if ( lvPrivilegeArr[ i ].level ) {
                        var lv : int = Math.min( playerLv, lvPrivilegeArr[ i ].level );
                        if ( _qqdata.blue.blueLevelGift.indexOf( lv ) == -1 ) {
                            if ( playerLv < lv ) {
                                return false;
                            }
                        }
                        else {
                            continue;
                        }
                        alreadyCompareLv = lvPrivilegeArr[ i ].level;
                        if ( alreadyCompareLv > playerLv ) {
                            return false;
                        } else {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        private function _judgeDailyRedImg() : Boolean {
            var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;
            if (!txData) return false;

            var _qqdata : CQQData = (_system.getBean( CQQClientDataManager ) as CQQClientDataManager).qqData;
            if ( txData.isSuperBlueYearVip ) {
                if ( _qqdata.blue.blueDailyGift.indexOf( false ) != -1 ) {
                    return true;
                }
            } else if ( txData.isBlueYearVip ) {
                if ( _qqdata.blue.blueDailyGift[ 0 ] == false || _qqdata.blue.blueDailyGift[ 2 ] == false ) {
                    return true;
                }
            } else if ( txData.isSuperBlueVip ) {
                if ( _qqdata.blue.blueDailyGift[ 0 ] == false || _qqdata.blue.blueDailyGift[ 1 ] == false ) {
                    return true;
                }
            } else if ( txData.isBlueVip ) {
                if ( _qqdata.blue.blueDailyGift[ 0 ] == false ) {
                    return true;
                }
            }
            return false;
        }

        private function _judgeFreshRedImg() : Boolean {
            var pPlayerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;
            if (!txData) return false;

            var _qqdata : CQQData = (_system.getBean( CQQClientDataManager ) as CQQClientDataManager).qqData;
            if(txData.isSuperBlueYearVip||txData.isBlueYearVip||txData.isSuperBlueVip||txData.isBlueVip){
                if ( !_qqdata.blue.blueFreshGift ) {
                    return true;
                }
            }
            return false;
        }
    }
}
