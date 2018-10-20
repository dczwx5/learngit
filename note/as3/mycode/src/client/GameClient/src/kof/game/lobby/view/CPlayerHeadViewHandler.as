//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.lobby.view {

import com.greensock.TweenMax;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bargainCard.CBargainCardManager;
import kof.game.bargainCard.CBuyMonthCardSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLogUtil;
//import kof.game.currency.monthAndWeekCard.CMonthCardViewHandler;
//import kof.game.currency.monthAndWeekCard.CWeekCardViewHandler;
import kof.game.currency.tipview.CTipsViewHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.shop.enum.EShopType;
import kof.game.vip.CVIPSystem;
import kof.table.PlayerConstant;
import kof.ui.CUISystem;
import kof.ui.components.KOFNum;
import kof.ui.master.JueseAndEqu.RoleItem03UI;
import kof.ui.master.main.HeadUI;
import kof.ui.master.main.MainHeroTipUI;
import kof.util.CAssertUtils;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Component;
import morn.core.components.Label;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
     * 玩家头像区域视图控制器管理
     *
     * @author Jeremy (jeremy@qifun.com)
     */
    public class CPlayerHeadViewHandler extends CViewHandler {

        private var m_pHeadView : HeadUI;
        private var m_pHerosTipView : MainHeroTipUI;

        private var m_sPlayerName : String;
        private var m_nLevel : uint;
        private var m_nFightScore : Number;
        private var m_nMoney : Number;
        private var m_nBindingMoney : Number;
        private var m_nGold : Number;
        private var m_nVipLevel : uint;
        private var m_sHeadIcon : String;
        private var m_fStrength : Number;
        private var m_fStrengthMax : Number;
        private var m_fExpCurr:Number;
        private var m_fExpMax:Number;

        /**
         * Creates a new CPlayerHeadViewHandler.
         */
        public function CPlayerHeadViewHandler() {
            super();
        }

        /**
         * @inheritDoc
         */
        override public function dispose() : void {
            super.dispose();

            if ( m_pHeadView )
                m_pHeadView = null;

            if ( m_pHerosTipView )
                m_pHerosTipView = null;
        }

        override protected virtual function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();

            // Reset the initialization values.
            this.playerName = "";
            this.level = 0;
            this.fightScore = 0;
            this.money = 0;
            this.bindingMoney = 0;
            this.gold = 0;
            this.vipLevel = 0;
            this.headIcon = "";
            this.strength = 0;
            this.strengthMax = 0;
            this.expCurr = 0;
            this.expMax = 0;

            return ret;
        }

        override public function get viewClass() : Array {
            return [ HeadUI, MainHeroTipUI ];
        }

        internal function initWith( headView : HeadUI ) : void {
            CAssertUtils.assertNull( m_pHeadView );
            this.m_pHeadView = headView;

            this.loadAssetsByView( viewClass );
        }

        override protected virtual function onAssetsLoadCompleted() : void {
            super.onAssetsLoadCompleted();
            this.onInitializeView();
        }

        override protected function onInitializeView() : Boolean {
            var allTagComponent : Array = findAllTagChildes( m_pHeadView );

            for each ( var comp : DisplayObject in allTagComponent ) {
                comp.addEventListener( MouseEvent.CLICK, _onSystemBundleRequestHandler, false, CEventPriority.DEFAULT, true );
            }

            m_pHeadView.diamondBox.toolTip = new Handler( showTips, [ CTipsViewHandler.BLUE_DIAMOND ] );
            m_pHeadView.purpleBox.toolTip = new Handler( showTips, [ CTipsViewHandler.PURPLE_DIAMOND ] );
            m_pHeadView.goldBox.toolTip = new Handler( showTips, [ CTipsViewHandler.GOLD ] );
            m_pHeadView.box_power.toolTip = new Handler( showTips, [ CTipsViewHandler.PHYSCAL_POWER ] );
            m_pHeadView.btn_week.toolTip = new Handler( showTips, [ CTipsViewHandler.WEEK_CARD ] );
            m_pHeadView.btn_month.toolTip = new Handler( showTips, [ CTipsViewHandler.MONTH_CARD ] );

            var pMaskDisplayObject : DisplayObject = m_pHeadView.getChildByName( 'mask' );
            if ( pMaskDisplayObject ) {
                m_pHeadView.imgIcon.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                m_pHeadView.imgIcon.mask = pMaskDisplayObject;
            }

            m_pHeadView.btnVIP.toolTip = new Handler( showVipTips );

            m_pHeadView.boxZhanli.toolTip = new Handler( _onFightScoreTipHandler );

            if ( !m_pHerosTipView ) {
                m_pHerosTipView = new MainHeroTipUI();
            }

            m_pHerosTipView.listEmBattle.renderHandler = new Handler( _listEmBattle_renderHandler );
            //充值返钻
            m_pHeadView.btn_rechargeRebate.clickHandler = new Handler( _onShowRechargeRebateView );
            var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.RECHARGEREBATE ) ) );
            m_pHeadView.btn_rechargeRebate.visible = iStateValue == CSystemBundleContext.STATE_STARTED ;

            m_pHeadView.btn_exchange.clickHandler = new Handler(_onExpExchangeHandler);
            m_pHeadView.strength_btn.clickHandler = new Handler(_onStrengthen);

            this.invalidate();

            return Boolean( m_pHeadView );
        }

        private function showTips( type : int ) : void {
            system.stage.getSystem( CUISystem ).getBean( CTipsViewHandler ).show( type );
        }

        private function showVipTips():void{
            (system.stage.getSystem( CVIPSystem ) as CVIPSystem).showTips();
        }

        override protected function onShutdown() : Boolean {
            var ret : Boolean = super.onShutdown();
            if ( ret && m_pHeadView ) {
                var allTagComponent : Array = findAllTagChildes( m_pHeadView );

                for each ( var comp : DisplayObject in allTagComponent ) {
                    comp.removeEventListener( MouseEvent.CLICK, _onSystemBundleRequestHandler );
                }
            }
            return ret;
        }

        private function findAllTagChildes( comp : DisplayObjectContainer ) : Array {
            var ret : Array = [];

            if ( comp ) {
                var numChildren : int = comp.numChildren;
                for ( var i : int = 0; i < numChildren; ++i ) {
                    var pChild : DisplayObject = comp.getChildAt( i );
                    if ( pChild ) {
                        var idBundle : * = SYSTEM_ID( pChild.name );
                        if ( null == idBundle || undefined == idBundle )
                            continue;
                        ret.push( pChild );
                        if ( pChild is DisplayObjectContainer ) {
                            var subRet : Array = findAllTagChildes( pChild as DisplayObjectContainer );
                            if ( subRet && subRet.length )
                                ret.concat( subRet );
                        }
                    }
                }
            }

            return ret;
        }

        override protected virtual function updateData() : void {
            super.updateData();

            if ( !m_pHeadView ) return;
            m_pHeadView.numFightScore.num = this.fightScore;

            var vipSystem : CVIPSystem = system.stage.getSystem( CVIPSystem ) as CVIPSystem;
            var lvl : int = _playerSystem.playerData.vipData.vipLv;
            if(vipSystem){
                m_pHeadView.vipRedIcon.visible = lvl > 0 ? !vipSystem.vipManager.isGetEverydayReward(lvl) : false;
            }

            var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.BUY_MONTH_CARD ) ) );

            m_pHeadView.btn_week.visible = m_pHeadView.btn_month.visible = iStateValue;
            if(iStateValue)//如果系统开启了才显示
            {
                var cardManager : CBargainCardManager = (system.stage.getSystem(CBuyMonthCardSystem) as CBuyMonthCardSystem).getBean(CBargainCardManager);

                var silverCardState : Boolean = _playerSystem.playerData.monthAndWeekCardData.silverCardState;//0未激活1已激活
                ObjectUtils.gray(m_pHeadView.btn_week,!silverCardState);
                m_pHeadView.weekRed.visible = cardManager.silverRewardState || !silverCardState;

                var goldCardState : Boolean = _playerSystem.playerData.monthAndWeekCardData.goldCardState;//0未激活1已激活
                ObjectUtils.gray(m_pHeadView.btn_month,!goldCardState);
                m_pHeadView.monthRed.visible = cardManager.goldRewardState || !goldCardState;

            }

            m_pHeadView.lblLevel.text = this.level.toString();
            m_pHeadView.lblMoneyText.text = this.money.toString();
            m_pHeadView.lblBindMoneyText.text = this.bindingMoney.toString();
            m_pHeadView.lblGoldText.text = this.gold.toString();
            var expProgressValue : Number = this.expCurr / this.expMax;
            m_pHeadView.barStrength.value =  expProgressValue;
            m_pHeadView.lblVitality.isHtml = true;
            m_pHeadView.lblVitality.color = 0xe5e3d6;
            if ( expProgressValue > 1.0 ) {
                m_pHeadView.lblVitality.text = '<font color="#50FF58">' + this.expCurr + "</font>/" + this.expMax;
            } else {
                m_pHeadView.lblVitality.text = this.expCurr + '/' + this.expMax;
            }

            m_pHeadView.txt_powerValue.isHtml = true;
            if(strength > strengthMax)
            {
                m_pHeadView.txt_powerValue.text = "<font color='#00ff00'>" + this.strength + "</font>" + "/" + strengthMax;
            }
            else
            {
                m_pHeadView.txt_powerValue.text = "<font color='#e5e3d6'>" + this.strength + "/" + strengthMax + "</font>";
            }

            m_pHeadView.imgIcon.skin = this.headIcon;

            var playerData:CPlayerData = _playerSystem.playerData;
            m_pHeadView.btn_exchange.visible = level >= _getExchangeOpenLevel();
            m_pHeadView.img_fullBar.visible = level >= playerData.maxTeamLevel;

            if(level >= playerData.maxTeamLevel)
            {
                m_pHeadView.img_fullBar.toolTip = "当前等级上限为" + playerData.maxTeamLevel + "级";
            }
            else
            {
                m_pHeadView.img_fullBar.toolTip = null;
            }

            this.updatePlatformVipInfo();
        }

        private function _getExchangeOpenLevel():int
        {
            var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            var table:IDataTable = dataBase.getTable(KOFSysTags.PLAYER_CONSTANT);
            if(table)
            {
                var data:PlayerConstant = table.findByPrimaryKey(1) as PlayerConstant;
                if(data)
                {
                    return data.maxLevel;
                }
            }

            return 0;
        }

        private function updatePlatformVipInfo() : void {
            if ( !m_pHeadView || !m_pHeadView.signature )
                return;

            var pPlayerSystem:CPlayerSystem = ((uiCanvas as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem);
            pPlayerSystem.platform.signatureRender.renderSignature(pPlayerSystem.playerData.vipData.vipLv, pPlayerSystem.platform.data, m_pHeadView.signature, playerName);

            this.invalidateDisplay();
        }

        override protected virtual function updateDisplay() : void {
            super.updateDisplay();
        }

        final public function get playerName() : String {
            return m_sPlayerName;
        }

        final public function set playerName( playerName : String ) : void {
            if ( m_sPlayerName == playerName )
                return;
            m_sPlayerName = playerName;
            invalidateData();
        }

        final public function get level() : uint {
            return m_nLevel;
        }

        final public function set level( value : uint ) : void {
            if ( m_nLevel == value )
                return;
            m_nLevel = value;
            invalidateData();
        }

        final public function get fightScore() : Number {
            return m_nFightScore;
        }

        final public function set fightScore( value : Number ) : void {
            if ( m_nFightScore == value )
                return;
            m_nFightScore = value;
            invalidateData();
        }

        final public function get money() : Number {
            return m_nMoney
        }

        final public function set money( value : Number ) : void {
            if ( m_nMoney == value )
                return;
            m_nMoney = value;
            invalidateData();
        }

        final public function get bindingMoney() : Number {
            return m_nBindingMoney;
        }

        final public function set bindingMoney( value : Number ) : void {
            if ( m_nBindingMoney == value )
                return;
            m_nBindingMoney = value;
            invalidateData();
        }

        final public function get gold() : Number {
            return m_nGold;
        }

        final public function set gold( value : Number ) : void {
            if ( m_nGold == value )
                return;
            m_nGold = value;
            invalidateData();
        }

        final public function get vipLevel() : uint {
            return m_nVipLevel;
        }

        final public function set vipLevel( value : uint ) : void {
            if ( m_nVipLevel == value )
                return;
            m_nVipLevel = value;
            invalidateData();
        }

        final public function get headIcon() : String {
            return m_sHeadIcon;
        }

        final public function set headIcon( value : String ) : void {
            if ( m_sHeadIcon == value )
                return;
            m_sHeadIcon = value;
            invalidateData();
        }

        final public function get strength() : Number {
            return m_fStrength;
        }

        final public function set strength( strength : Number ) : void {
            if ( m_fStrength == strength )
                return;
            m_fStrength = strength;
            invalidateData();
        }

        final public function get strengthMax() : Number {
            return m_fStrengthMax;
        }

        final public function set strengthMax( strength : Number ) : void {
            if ( m_fStrengthMax == strength )
                return;
            m_fStrengthMax = strength;
            invalidateData();
        }

        final public function get expCurr() : Number {
            return m_fExpCurr;
        }

        final public function set expCurr( value : Number ) : void {
            if ( m_fExpCurr == value )
                return;
            m_fExpCurr = value;
            invalidateData();
        }

        final public function get expMax() : Number {
            return m_fExpMax;
        }

        final public function set expMax( value : Number ) : void {
            if ( m_fExpMax == value )
                return;
            m_fExpMax = value;
            invalidateData();
        }

        private function _onSystemBundleRequestHandler( event : MouseEvent ) : void {
            var pDisplayObject : DisplayObject = event.currentTarget as DisplayObject;
            if ( pDisplayObject ) {
                _systemBundleActivatedHandler( pDisplayObject.name );

                if(pDisplayObject.name == "BUY_WEEK_CARD" || pDisplayObject.name == "BUY_MONTH_CARD")
                {
                    CLogUtil.recordLinkLog(system, 10013);
                }
            }
        }

        private function _systemBundleActivatedHandler( sTag : String ) : void {
            var idBundle : * = SYSTEM_ID( sTag );
            if ( null == idBundle || undefined == idBundle )
                return;

            var pCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( !pCtx )
                return;

            var pSystemBundle : ISystemBundle = pCtx.getSystemBundle( idBundle );
            if ( !pSystemBundle )
                return;
            var vCurrent : Boolean = pCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
            pCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );
            if(sTag == KOFSysTags.BUY_MONTH_CARD)//月卡特殊处理
            {
                idBundle = SYSTEM_ID( KOFSysTags.BARGAINCARD );
                if ( null == idBundle || undefined == idBundle ) return;
                pSystemBundle = pCtx.getSystemBundle( idBundle );
                if ( !pSystemBundle ) return;
                var iStateValue : int = pCtx.getSystemBundleState( pCtx.getSystemBundle( idBundle ) );
                if(iStateValue)
                    pCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );
            }
        }

        private function _onFightScoreTipHandler() : void {
            var vPlayerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
            if ( !vPlayerSystem )
                return;

            if ( vPlayerSystem.playerData && vPlayerSystem.playerData.heroList ) {
                var emListData:CEmbattleListData = vPlayerSystem.playerData.embattleManager.getByType(EInstanceType.TYPE_MAIN);
                var heroListData : Array = [];
                if (emListData) {
                    for (var i:int = 0; i < 3; i++) {
                        var emData:CEmbattleData = emListData.getByPos(i+1);
                        if (emData) {
                            heroListData[i] = vPlayerSystem.playerData.heroList.getHero(emData.prosession);
                        } else {
                            heroListData[i] = null;
                        }
                    }
                }

                m_pHerosTipView.listEmBattle.dataSource = heroListData;
                App.tip.addChild( m_pHerosTipView );
            }
        }

        final private function _listEmBattle_renderHandler( comp : Component, idx : int ) : void {
            if ( !(comp is Box )) {
                comp.visible = false;
                return;
            }

            var roleData : CPlayerHeroData = comp.dataSource as CPlayerHeroData;

            var headComp : RoleItem03UI = comp.getChildByName( "roleHead" ) as RoleItem03UI;
            var lblName : Label = comp.getChildByName( "lblName" ) as Label;
            var boxFightScore : Box = comp.getChildByName( "boxFightScore" ) as Box;
            var numFightScore : KOFNum = boxFightScore ? boxFightScore.getChildByName("numFightScore") as KOFNum : null;

            if ( numFightScore ) {
                numFightScore.num = roleData ? roleData.battleValue : 0;
            }

            if ( lblName ) {
                lblName.isHtml = true;
                lblName.text = roleData ? roleData.heroNameWithColor : "";
            }

            if ( headComp ) {
                var item : RoleItem03UI = headComp;
                item.icon_image.visible = false;

                var heroData:CPlayerHeroData = roleData;
                if (!heroData) {
                    item.quality_clip.index = 0;
                    item.hero_icon_mask.visible = false;
                    item.icon_image.mask = null;
                    item.icon_image.url = "";
                    item.star_list.visible = false;
                    item.clip_career.visible = false;
                    item.clip_intell.visible = false;
                } else {
                    item.icon_image.visible = true;
                    item.quality_clip.index = heroData.qualityLevelValue;
                    item.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(heroData.prototypeID);
                    item.hero_icon_mask.visible = true;
                    item.icon_image.mask = item.hero_icon_mask;
                    item.star_list.visible = true;
                    item.star_list.repeatX = heroData.star;
                    item.clip_career.visible = true;
                    item.clip_career.index = heroData.job;
                    (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showCareerTips(item.clip_career);
                    item.clip_intell.visible = true;
                    item.clip_intell.index = heroData.qualityBaseType;

//                    var playerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
//                    item.toolTip = new Handler(playerSystem.showHeroTips, [heroData]);
                }
            }

            comp.visible = true;
        }

    private function _onShowRechargeRebateView():void{

        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var systemBundle : ISystemBundle = bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.RECHARGEREBATE ) );
        bundleCtx.setUserData( systemBundle, CBundleSystem.ACTIVATED, true );
    }

        private function _onExpExchangeHandler():void
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.MALL));
            bundleCtx.setUserData(systemBundle, "shop_type", [EShopType.SHOP_TYPE_17]);
            if(bundleCtx.getUserData(systemBundle, CBundleSystem.ACTIVATED))
            {
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, false);
            }
            else
            {
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
            }
        }
        private function _onStrengthen() : void {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.STRENGTHEN));
            var lastValue:Boolean = bundleCtx.getUserData(systemBundle, CBundleSystem.ACTIVATED);
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, !lastValue);

        }

        public function get viewUI():HeadUI
        {
            return m_pHeadView;
        }

        public function updateCombat(newCombat:int):void
        {
            if(m_pHeadView && m_pHeadView.parent)
            {
                if(TweenMax.isTweening(m_pHeadView.numFightScore))
                {
                    TweenMax.killTweensOf(m_pHeadView.numFightScore);
                }

                if(newCombat > m_nFightScore)
                {
                    TweenMax.to(m_pHeadView.numFightScore, 1, {num:newCombat});
                }
                else
                {
                    m_pHeadView.numFightScore.num = newCombat;
                }
            }

            m_nFightScore = newCombat;
        }

        private function get _playerSystem() : CPlayerSystem
        {
            return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
        }
    }
}
