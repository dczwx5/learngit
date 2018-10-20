//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/23.
 */
package kof.game.player {

import flash.events.Event;

import kof.SYSTEM_ID;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CChildSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyPointEffect;
import kof.game.common.system.CAppSystemImp;
import kof.game.currency.CCurrencyHandler;
import kof.game.currency.buyMoney.CBuyMoneyViewHandler;
import kof.game.currency.buyPower.CBuyPowerViewHandler;
//import kof.game.currency.monthAndWeekCard.CMonthCardViewHandler;
//import kof.game.currency.monthAndWeekCard.CWeekCardViewHandler;
import kof.game.currency.qq.CQQBlueDiamondViewHandler;
import kof.game.currency.qq.CQQHallViewHandler;
import kof.game.currency.qq.CQQYellowDiamondViewHandler;
import kof.game.currency.qq.data.netData.CQQClientDataManager;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.mainInstance.view.instanceScenario.CInstanceScenarioView;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.platform.CPlatformHandler;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CSkillData;
import kof.game.player.enum.EPlayerWndType;
import kof.game.player.view.heroGet.CHeroGetViewHandler;
import kof.game.player.view.heroGet.CPlayerHeroGetView;
import kof.game.player.view.playerNew.CHeroCareerTipsView;
import kof.game.player.view.playerNew.CHeroListViewHandler;
import kof.game.player.view.playerNew.CPlayerMainViewHandler;
import kof.game.player.view.playerNew.CSkillTagViewHandler;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.game.player.view.playerNew.util.CPlayerTipHandler;
import kof.game.player.view.playerNew.CHeroSkillTipsView;
import kof.game.player.view.playerNew.view.CCombatUpViewHandler;
import kof.game.player.view.playerNew.view.CSkillVideoViewHandler;
import kof.game.player.view.playerNew.view.heroDevelop.CCollectAttrDescViewHandler;
import kof.game.player.view.playerNew.view.heroDevelop.CHeroSkillTipsSmallView;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.CHeroTipsView;
import kof.game.player.view.skillup.CSkillUpHandler;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CPlayerSystem extends CAppSystemImp {
    public function CPlayerSystem() {
        super();
    }

    public override function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.ROLE );
    }

    public override function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && _isDataInitialize;
        return ret;
    }

    // ====================================================================
    override public function initialize() : Boolean {
        var ret : Boolean = super.initialize();
        if ( !ret ) {
        } else {
            this.addBean( _playerManager = new CPlayerManager() );


            this.addBean( _equipNetHandler = new CEquipmentNetHandler() );
            this.addBean( _heroNetHandler = new CHeroNetHandler() );
            this.addBean( _playerHandler = new CPlayerHandler() );


            this.addBean( _uiHandler = new CPlayerUIHandler() );
            this.addBean( _skillUpHandler = new CSkillUpHandler() );
//          this.addBean( _skillUpHandler = new CSkillUpHandler() );

            //####### add by sprite #######
            this.addBean( _heroListView = new CHeroListViewHandler() );
            _heroListView.closeHandler = new Handler(_onViewClosed);
            addBean( _helper = new CPlayerHelpHandler() );
            addBean( _playerMainView = new CPlayerMainViewHandler() );
            addBean(_playerTipHandler = new CPlayerTipHandler());
            addBean(_combatUpViewHandler = new CCombatUpViewHandler());
            addBean(_skillTagView = new CSkillTagViewHandler());
            addBean(_skillVideoView = new CSkillVideoViewHandler());

            this.addBean( new CPlayerKeyboard() );
            addBean(_platform = new CPlatformHandler());

            addBean( new CBuyMoneyViewHandler() );
            addBean( new CCurrencyHandler() );
            addBean( new CBuyPowerViewHandler() );
//            addBean( new CMonthCardViewHandler() );
//            addBean( new CWeekCardViewHandler() );
            addBean( new CQQHallViewHandler() );
            addBean( new CQQBlueDiamondViewHandler() );
            addBean( new CQQYellowDiamondViewHandler() );
            addBean( new CQQClientDataManager(this) );
            addBean( new CHeroGetViewHandler() );
            addBean( new CCollectAttrDescViewHandler() );

            this.registerEventType( CPlayerEvent.HERO_ADD );
            this.registerEventType( CPlayerEvent.HERO_DATA );
            this.registerEventType( CPlayerEvent.RANDOM_NAME );
            this.registerEventType( CPlayerEvent.PLAYER_DATA );
            this.registerEventType( CPlayerEvent.PLAYER_LEVEL_UP );
            this.registerEventType( CPlayerEvent.SKILL_BREAK );
            this.registerEventType( CPlayerEvent.CREATE_TEAM );
            this.registerEventType( CPlayerEvent.SKILL_LVUP );
        }
        return ret;
    }

    public function inverseBuyVitView() : void {
        var view : CBuyPowerViewHandler = getBean( CBuyPowerViewHandler ) as CBuyPowerViewHandler;
        view.inverseWindow();
    }

    // bundle
    override protected function onActivated( a_bActivated : Boolean ) : void {
        super.onActivated( a_bActivated );
        if ( isActived ) {
            _heroListView.addDisplay();
        } else {
            _heroListView.removeDisplay();
        }
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,_playerTipHandler.isCanDevelop());
        }

        var pHeadView : CPlayerHeadViewHandler = stage.getSystem(CLobbySystem ).getHandler(CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
        if ( pHeadView )
        {
            pHeadView.fightScore = playerData.teamData.battleValue;
        }

        addEventListeners();
    }

    protected function addEventListeners() : void
    {
        this.stage.getSystem(CBagSystem).addEventListener(CBagEvent.BAG_UPDATE, _onUpdateTipInfoHandler);
        this.addEventListener(CPlayerEvent.EQUIP_DATA,_onUpdateTipInfoHandler);
        this.addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);
        this.addEventListener(CPlayerEvent.SKILL_BREAK,_onUpdateTipInfoHandler);
        this.addEventListener(CPlayerEvent.SKILL_LVUP,_onUpdateTipInfoHandler);
        this.addEventListener(CPlayerEvent.SKILL_DATA,_onUpdateTipInfoHandler);
        this.addEventListener(CPlayerEvent.HERO_DATA,_onUpdateTipInfoHandler);
        this.addEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY,_onUpdateTipInfoHandler);
        this.addEventListener(CChildSystemBundleEvent.CHILD_BUNDLE_START, _onUpdateTipInfoHandler);
        this.addEventListener(CPlayerEvent.HERO_ADD,_onHeroAddHandler);
        this.addEventListener(CPlayerEvent.SHOWHIDE_COMBAT_EFFECT,_showHideCombatEffectHandler);
        this.addEventListener(CPlayerEvent.OPEN_AND_SELHERO, _openAndSelHeroHandler);
        stage.getSystem(CEmbattleSystem).addEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onUpdateTipInfoHandler);
    }

    protected function removeEventListeners() : void
    {
        this.stage.getSystem(CBagSystem).removeEventListener(CBagEvent.BAG_UPDATE, _onUpdateTipInfoHandler);
        this.removeEventListener(CPlayerEvent.EQUIP_DATA,_onUpdateTipInfoHandler);
        this.removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);
        this.removeEventListener(CPlayerEvent.SKILL_BREAK,_onUpdateTipInfoHandler);
        this.removeEventListener(CPlayerEvent.SKILL_LVUP,_onUpdateTipInfoHandler);
        this.removeEventListener(CPlayerEvent.SKILL_DATA,_onUpdateTipInfoHandler);
        this.removeEventListener(CPlayerEvent.HERO_DATA,_onUpdateTipInfoHandler);
        this.removeEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY,_onUpdateTipInfoHandler);
        this.removeEventListener(CChildSystemBundleEvent.CHILD_BUNDLE_START, _onUpdateTipInfoHandler);
        this.removeEventListener(CPlayerEvent.HERO_ADD,_onHeroAddHandler);
        this.removeEventListener(CPlayerEvent.SHOWHIDE_COMBAT_EFFECT,_showHideCombatEffectHandler);
        this.removeEventListener(CPlayerEvent.OPEN_AND_SELHERO, _openAndSelHeroHandler);
        stage.getSystem(CEmbattleSystem).removeEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onUpdateTipInfoHandler);
    }

//====================================================监听==============================================================
    /**
     * 小红点提示
     * @param e
     */
    private function _onUpdateTipInfoHandler(e:Event):void
    {
        _helper.updateEmbattleInfo();
        _updateTipState();
    }

    private function _updateTipState():void
    {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( null != pSystemBundleCtx )
        {
            var curState:Boolean = pSystemBundleCtx.getUserData(this,CBundleSystem.NOTIFICATION,false);
            var isCanDevelop:Boolean = _playerTipHandler.isCanDevelop();
            if(curState != isCanDevelop)
            {
                pSystemBundleCtx.setUserData(this,CBundleSystem.NOTIFICATION,isCanDevelop);
            }
        }
    }

    private function _onHeroAddHandler(e:CPlayerEvent):void
    {
        if(e.type == CPlayerEvent.HERO_ADD)
        {
            _helper.updateHiredHeroList();
        }
    }

    private function _showHideCombatEffectHandler(e:CPlayerEvent):void
    {
        var isShow:Boolean = e.data as Boolean;

        var combatUpView:CCombatUpViewHandler = getHandler(CCombatUpViewHandler) as CCombatUpViewHandler;
        if(combatUpView)
        {
            combatUpView.visible = isShow;
        }

//        if(CFlyPointEffect.instance.isPlaying)
//        {
            CFlyPointEffect.instance.visible = isShow;
//        }
    }

    private function _openAndSelHeroHandler(e:CPlayerEvent):void
    {
        var bundleCtx:ISystemBundleContext = stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.ROLE));
        var currState:Boolean = bundleCtx.getUserData(systemBundle,CBundleSystem.ACTIVATED);
        if(!currState)
        {
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
        }

        var heroId:int = e.data as int;
        var heroData:CPlayerHeroData = playerData.heroList.getHero(heroId);
        if(heroData && heroData.hasData)
        {
            var playerMainView:CPlayerMainViewHandler = getHandler(CPlayerMainViewHandler) as CPlayerMainViewHandler;
            if(playerMainView.isViewShow)
            {
                dispatchEvent(new CPlayerEvent(CPlayerEvent.SWITCH_HERO, heroData));
            }
            else
            {
                _heroListView.tweenShowEndHandler = new Handler(showMainWin);
                function showMainWin():void
                {
                    playerMainView.showByPanelName("HeroDevelop", heroData);
                }
            }
        }
    }

//====================================================get/set===========================================================
    // get/set
    public function get playerData() : CPlayerData {
        return _playerManager.playerData;
    }

    public function get netHandler() : CPlayerHandler {
        return _playerHandler;
    }
    public function get heroNetHandler() : CHeroNetHandler {
        return _heroNetHandler;
    }
    public function get equipNetHandler() : CEquipmentNetHandler {
        return _equipNetHandler;
    }

    public function get uiHandler() : CPlayerUIHandler {
        return _uiHandler;
    }

    public function get isDataInitialize() : Boolean {
        return _isDataInitialize;
    }

    public function set isDataInitialize( value : Boolean ) : void {
        _isDataInitialize = value;
        if ( _isDataInitialize ) {
            this.makeStarted();
        }
    }

//====================================================tips==============================================================
    public function showHeroTips( heroData : CPlayerHeroData, item : Component = null, isSelf:Boolean = true ) : void {
        _uiHandler.addTips( CHeroTipsView, item, [ heroData, isSelf ] );
    }
    public function showHeroSkillTips( skillData : CSkillData, skillID : int = 0, skillPosition : int = 0, item : Component = null ) : void {
        _uiHandler.addTips( CHeroSkillTipsView, item, [ skillData,skillID,skillPosition ] );
    }

    public function showHeroSkillSmallTips(skillInfo : Object, item : Component = null):void
    {
        _uiHandler.addTips(CHeroSkillTipsSmallView, item, [skillInfo]);
    }

    public function showCareerTips(item:Component = null):void
    {
        if(item)
        {
            item.toolTip = new Handler(addTips);
            function addTips():void
            {
                _uiHandler.addTips( CHeroCareerTipsView, item, [] );
            }
        }
    }



    public function isHeroMainNewShow() : Boolean {
        return _playerMainView && _playerMainView.isViewShow;
    }

    public function showHeroMainNew(tab:int = 0, heroID:int = -1) : void {
        if (_helper && _playerMainView) {
            var tabName:String = _helper.getTabNameByIndex(tab);

            var heroData:CPlayerHeroData = null;
            if (-1 == heroID) {
                heroData = playerData.heroList.getHero(heroID);
            }
            _playerMainView.showByPanelName(tabName, heroData);
        }
    }

    public function isHeroMainNiewShow() : Boolean {
        if (_playerMainView) {
            return _playerMainView.isViewShow;
        }
        return false;
    }

    public function showHeroMainWinByName(tabName:String, heroId:int = 0):void
    {
        if (_helper && _playerMainView)
        {
            var heroData:CPlayerHeroData;
            if(heroId == 0)
            {
                heroData = _helper.getDefaultHeroData();
            }
            else
            {
                heroData = playerData.heroList.getHero(heroId);
            }

            _playerMainView.showByPanelName(tabName, heroData);
        }
    }

    /**
     * 战力提升提示
     */
    public function playCombatUpEffect():void
    {
        var combatUpView:CCombatUpViewHandler = this.getHandler(CCombatUpViewHandler) as CCombatUpViewHandler;
        if(combatUpView)
        {
            combatUpView.setData(oldTeamCombat, playerData.teamData.battleValue);
            combatUpView.addDisplay();
            combatUpView.visible = _isShowCombatUpEffect();
        }
    }

    private function _isShowCombatUpEffect():Boolean
    {
        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            if(!instanceSystem.isMainCity)
            {
                return false;
            }
        }

//        var heroGetView:CPlayerHeroGetView = uiHandler.getCreatedWindow(EPlayerWndType.WND_PLAYER_HERO_GET) as CPlayerHeroGetView;
//        if(heroGetView && heroGetView._ui && heroGetView._ui.parent)
//        {
//            return false;
//        }

        var heroGetView:CHeroGetViewHandler = getHandler(CHeroGetViewHandler) as CHeroGetViewHandler;
        if(heroGetView && heroGetView.isViewShow)
        {
            return false;
        }

        var instanceUIHandler:CInstanceUIHandler = stage.getSystem(CInstanceSystem ).getHandler(CInstanceUIHandler) as CInstanceUIHandler;
        var instanceView:CInstanceScenarioView = instanceUIHandler.getCreatedWindow(EInstanceWndType.WND_INSTANCE_SCENARIO) as CInstanceScenarioView;
        if(instanceView && instanceView._ui && instanceView._ui.parent)
        {
            return false;
        }

        var instanceView2:CInstanceScenarioView = instanceUIHandler.getCreatedWindow(EInstanceWndType.WND_INSTANCE_ELITE) as CInstanceScenarioView;
        if(instanceView2 && instanceView2._ui && instanceView2._ui.parent)
        {
            return false;
        }

        return true;
    }

    public function set oldTeamCombat(value:int):void
    {
        _oldTeamCombat = value;
    }

    public function get oldTeamCombat():int
    {
        return _oldTeamCombat;
    }

    [Inline]
    public function get platform() : CPlatformHandler {
        return _platform;
    }
    [Inline]
    public function createPlatfromData(data:Object) : CPlatformBaseData {
        return platform.builder.build(data);
    }

    // ==================================property====================================
    private var _playerHandler : CPlayerHandler;
    private var _heroNetHandler : CHeroNetHandler;
    private var _equipNetHandler : CEquipmentNetHandler;

    private var _playerManager : CPlayerManager;
    private var _uiHandler : CPlayerUIHandler;
    private var _skillUpHandler : CSkillUpHandler;
    private var _playerTipHandler : CPlayerTipHandler;
    private var _combatUpViewHandler : CCombatUpViewHandler;

    //####### add by sprite #######
    private var _heroListView : CHeroListViewHandler;
    private var _playerMainView : CPlayerMainViewHandler;
    private var _oldTeamCombat:int;

    private var _isDataInitialize:Boolean;
    private var _helper:CPlayerHelpHandler;

    private var _skillTagView : CSkillTagViewHandler;
    private var _skillVideoView : CSkillVideoViewHandler;
    private var _platform:CPlatformHandler;


}
}