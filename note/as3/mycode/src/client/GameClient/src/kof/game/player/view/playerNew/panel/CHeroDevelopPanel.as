//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/16.
 */
package kof.game.player.view.playerNew.panel {

import com.greensock.TweenMax;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

import kof.SYSTEM_ID;

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CBitmapNumberText;
import kof.game.common.CLang;
import kof.game.common.CUIFactory;
import kof.game.fightui.compoment.Sector;
import kof.game.player.CHeroNetHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.CPlayerMainViewHandler;
import kof.game.player.view.playerNew.CSkillTagViewHandler;
import kof.game.player.view.playerNew.util.CHeroDevelopState;
import kof.game.player.view.playerNew.view.heroDevelop.CHeroDetailPropViewHandler;
import kof.game.player.view.playerNew.view.heroDevelop.CHeroDevelopPart;
import kof.game.player.view.playerNew.view.heroDevelop.CHeroLevelUpStuffView;
import kof.game.player.view.playerNew.view.heroDevelop.CHeroQualitySuccViewHandler;
import kof.game.player.view.playerNew.view.heroDevelop.CHeroStarSuccViewHandler;
import kof.game.player.view.playerNew.view.reborn.CRebornRuleView;
import kof.game.player.view.playerNew.view.reborn.CRebornInfoView;
import kof.game.playerCard.util.CTransformSpr;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.game.story.CStorySystem;
import kof.game.switching.CSwitchingSystem;
import kof.table.PlayerDisplay;
import kof.table.PlayerSkill;
import kof.table.Skill;
import kof.ui.CUISystem;
import kof.ui.demo.SkillItemIIUI;
import kof.ui.demo.SkillItemUI;
import kof.ui.master.jueseNew.panel.HeroDevelopPanelUI;
import kof.ui.master.jueseNew.view.HeroLevelUpStuffViewUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
 * 格斗家养成
 */
public class CHeroDevelopPanel extends CPlayerPanelBase {

    private var m_pHeroData : CPlayerHeroData;
    private var m_pDevelopPart : CHeroDevelopPart;
    private var m_pLevelUpStuffView : CHeroLevelUpStuffView;
    private var m_pTransformSpr : CTransformSpr;
    private var m_pDetailPropView : CHeroDetailPropViewHandler;
    private var m_rebornRuleView : CRebornRuleView;
    private var m_rebornInfoView : CRebornInfoView;
//    private var m_pBmpNumberTxt:CBitmapNumberText;

    public function CHeroDevelopPanel() {
        super();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        ret = this.addBean( m_pDevelopPart = new CHeroDevelopPart() );
        ret = this.addBean( m_pLevelUpStuffView = new CHeroLevelUpStuffView() );
        ret = this.addBean( m_pDetailPropView = new CHeroDetailPropViewHandler() );
        ret = this.addBean( m_rebornInfoView = new CRebornInfoView() );
        ret = this.addBean( m_rebornRuleView = new CRebornRuleView() );

        return ret;
    }

    override public function initializeView() : void {
        super.initializeView();

        m_pViewUI = new HeroDevelopPanelUI();
        m_pDevelopPart.view = _viewUI.view_develop;
        m_pLevelUpStuffView.view = new HeroLevelUpStuffViewUI();

        _viewUI.btn_left.clickHandler = new Handler( _onClickLeftHandler );
        _viewUI.btn_right.clickHandler = new Handler( _onClickRightHandler );
        _viewUI.list_skill.renderHandler = new Handler( _renderSkillInfo );
        _viewUI.list_skill.mouseHandler = new Handler( _listMouseHandler );
        _viewUI.reset_hero_btn.clickHandler = new Handler( _onClickRebornBtn );
        _viewUI.btn_skillTag.clickHandler = new Handler( onSkillTagHandler );
        _viewUI.story_btn.clickHandler = new Handler(_onStoryClick);
        _viewUI.story_btn.visible = true;

        m_pDevelopPart.initializeView();
        m_pLevelUpStuffView.initializeView();

        m_pTransformSpr = new CTransformSpr();
        m_pTransformSpr.objWidth = 657;
        m_pTransformSpr.objHeight = 517;
        m_pTransformSpr.transformObj = _viewUI.img_hero_white;
        _viewUI.box_heroImg.addChild( m_pTransformSpr );
        m_pTransformSpr.alpha = 0;


        var colorTransform : ColorTransform = new ColorTransform();
        colorTransform.color = 0xFFFFFF;
        _viewUI.img_hero_white.transform.colorTransform = colorTransform;
//        _viewUI.num_combat.visible = false;

        _viewUI.reset_hero_btn.toolTip = CLang.Get("hero_reborn_tips", {v1:CPlayerHeroData.REBORN_LEVEL});
        // 重生按钮开启 不按功能开启做了
//        var isRebornOpen:Boolean = (system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(KOFSysTags.REBORN);
//        _viewUI.reset_hero_btn.visible = isRebornOpen;
//        if (!isRebornOpen) {
//            var pCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
//            if ( pCtx ) {
//                var idBundle : * = SYSTEM_ID( KOFSysTags.REBORN );
//                var pSystemBundle : ISystemBundle = pCtx.getSystemBundle( idBundle );
//                if ( pSystemBundle ) {
//                    pSystemBundle.addEventListener(CSystemBundleEvent.BUNDLE_START, _onRebornBundleStarted);
//                }
//            }
//        }
    }

//    private function _onRebornBundleStarted(e:CSystemBundleEvent) : void {
//        e.bundle.removeEventListener(CSystemBundleEvent.BUNDLE_START, _onRebornBundleStarted);
//        _viewUI.reset_hero_btn.visible = true;
//    }

    override protected function _addListeners() : void {
        super._addListeners();

        m_pDevelopPart.addListeners();

        (system as CPlayerSystem).addEventListener( CPlayerEvent.HERO_DATA, _onHeroDataUpdateHandler );
        system.addEventListener( CPlayerEvent.HERO_LEVEL_UP, _onHeroLevelUpHandler );
        system.addEventListener( CPlayerEvent.HERO_QUALITY_UP, _onHeroQualitySuccHandler );
        system.addEventListener( CPlayerEvent.HERO_STAR_UP, _onHeroStarSuccHandler );
        system.addEventListener( CPlayerEvent.HERO_RESET, _onNetHeroRebornSucess );
        system.addEventListener( CPlayerEvent.HERO_RESET_INFO, _onNetHeroRebornInfoSucess );
        m_rebornInfoView.addEventListener( "DoReborn", _onDoReborn ); // info界面点了重生
        m_rebornRuleView.addEventListener( "OkConfirm", _onConfirmToOpenReborn );  // 确定界面点了ok
        m_rebornRuleView.addEventListener( "StopPopupRuleEvent", _onStopPopupRule );

        _viewUI.view_bigSkill.addEventListener( MouseEvent.CLICK, _onShowSkillVideo, false, 0, true );
        _viewUI.view_bigSkill.addEventListener( MouseEvent.ROLL_OVER, _onShowLookUpTag, false, 0, true );
        _viewUI.view_bigSkill.addEventListener( MouseEvent.ROLL_OUT, _onShowLookUpTag, false, 0, true );

    }

    override protected function _removeListeners() : void {
        super._removeListeners();

        m_pDevelopPart.removeListeners();

        (system as CPlayerSystem).removeEventListener( CPlayerEvent.HERO_DATA, _onHeroDataUpdateHandler );
        system.removeEventListener( CPlayerEvent.HERO_LEVEL_UP, _onHeroLevelUpHandler );
        system.removeEventListener( CPlayerEvent.HERO_QUALITY_UP, _onHeroQualitySuccHandler );
        system.removeEventListener( CPlayerEvent.HERO_STAR_UP, _onHeroStarSuccHandler );
        system.removeEventListener( CPlayerEvent.HERO_RESET, _onNetHeroRebornSucess );
        system.removeEventListener( CPlayerEvent.HERO_RESET_INFO, _onNetHeroRebornInfoSucess );
        m_rebornInfoView.removeEventListener( "DoReborn", _onDoReborn );
        m_rebornRuleView.removeEventListener( "OkConfirm", _onConfirmToOpenReborn );
        m_rebornRuleView.removeEventListener( "StopPopupRuleEvent", _onStopPopupRule );

        _viewUI.view_bigSkill.removeEventListener( MouseEvent.CLICK, _onShowSkillVideo );
        _viewUI.view_bigSkill.removeEventListener( MouseEvent.ROLL_OVER, _onShowLookUpTag );
        _viewUI.view_bigSkill.removeEventListener( MouseEvent.ROLL_OUT, _onShowLookUpTag );

    }

    override protected function _initView() : void {
        if ( m_pHeroData == null ) {
            data = _playerHelper.getDefaultHeroData();
        }

//        if(m_pBmpNumberTxt == null)
//        {
//            var url:String = "png.common.nums.kofnum_zhandouli1";
//            m_pBmpNumberTxt = CUIFactory.gBitmapNumberText(71, 2, 18, 26, url, _viewUI.box_combat);
//        }

        _updateView();
        m_pDevelopPart.initView();

        m_pTransformSpr.alpha = 0;
        _viewUI.clip_upEffect.visible = false;
    }

    private function _updateView() : void {
        if ( m_pHeroData ) {
            updateDisplay();
        }
        else {
            clear();
        }
    }

    override public function set data( value : * ) : void {
        m_pHeroData = value as CPlayerHeroData;

        m_pDevelopPart.data = value as CPlayerHeroData;
    }

    override protected function updateDisplay() : void {
        _updateIntelligence();
        _updateHeroImg();
        _updateBtnState();
        _updateCombat();
        _updateSkill();

        if ( m_pHeroData ) {
            ObjectUtils.gray( _viewUI.reset_hero_btn, m_pHeroData.level < CPlayerHeroData.REBORN_LEVEL );

            var playerManager:CPlayerManager = _playerSystem.getBean(CPlayerManager);
            var isGet:Boolean = playerManager.playerData.heroList.hasHero(m_pHeroData.prototypeID);
            _viewUI.story_btn.visible = isGet;
        }

        m_pDevelopPart.updateDevelopInfo();
    }

    override public function removeDisplay() : void {
        super.removeDisplay();

        if ( m_pLevelUpStuffView ) {
            m_pLevelUpStuffView.removeDisplay();
        }

        if ( m_pDetailPropView && m_pDetailPropView.isViewShow ) {
            m_pDetailPropView.removeDisplay();
        }

        if ( TweenMax.isTweening( m_pTransformSpr ) ) {
            TweenMax.killTweensOf( m_pTransformSpr );
        }

        if ( _viewUI.clip_upEffect.isPlaying ) {
            _viewUI.clip_upEffect.stop();
        }

//        if(m_pBmpNumberTxt)
//        {
//            m_pBmpNumberTxt.dispose();
//            m_pBmpNumberTxt = null;
//        }

        CHeroDevelopState.reset();

        _playerHelper.clear();

        if ( m_rebornRuleView && m_rebornRuleView.isViewShow ) {
            m_rebornRuleView.removeDisplay();
        }

        if ( m_rebornInfoView && m_rebornInfoView.isViewShow ) {
            m_rebornInfoView.removeDisplay();
        }

    }

    //界面信息更新=============================================================================
    private function _updateIntelligence() : void {
        _viewUI.clip_intelligence.index = m_pHeroData.qualityBaseType;
        _viewUI.txt_intelligence.text = "资质：" + m_pHeroData.qualityBase;

        //操作难度
        var playerDisplay:PlayerDisplay = _playerDisplay.findByPrimaryKey(m_pHeroData.prototypeID) as PlayerDisplay;
        _viewUI.clip_LearningDifTxt.index =
                _viewUI.clip_LearningDifImg.index = playerDisplay.LearningDif - 1;
    }

    private function _updateHeroImg() : void {
        _viewUI.img_hero.url = CPlayerPath.getUIHeroFacePath( m_pHeroData.prototypeID );
        _viewUI.img_hero_white.url = CPlayerPath.getUIHeroFacePath( m_pHeroData.prototypeID );
    }

    private function _updateBtnState() : void {
        if ( _playerHelper.isFirstHero( m_pHeroData.prototypeID ) ) {
            _viewUI.btn_left.disabled = true;
        }
        else {
            _viewUI.btn_left.disabled = false;
        }

        if ( _playerHelper.isLastHero( m_pHeroData.prototypeID ) ) {
            _viewUI.btn_right.disabled = true;
        }
        else {
            _viewUI.btn_right.disabled = false;
        }
    }

    private function _updateCombat() : void {
        _viewUI.box_combatInfo.visible = m_pHeroData.hasData;
        _viewUI.num_combat.num = m_pHeroData.battleValue;
        _viewUI.box_combat.centerX = 0;

//        m_pBmpNumberTxt.rollingToValue(m_pHeroData.battleValue);
    }

    private function _updateSkill() : void {
        var skillArr : Array = _playerHelper.getHeroSkills( m_pHeroData.prototypeID );
        _viewUI.list_skill.dataSource = skillArr;
        _renderBigSkill( _viewUI.view_bigSkill, skillArr[ 3 ] );
    }

    //render=============================================================================
    private static const KEY_ARY : Array = [ "U", "I", "O", "space" ];

    private function _renderSkillInfo( item : Component, index : int ) : void {
        if ( !(item is SkillItemUI) ) {
            return;
        }

        var render : SkillItemUI = item as SkillItemUI;
        var skillId : int = render.dataSource as int;
        if ( skillId ) {
            var db : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
            var skillTable : IDataTable = db.getTable( KOFTableConstants.SKILL );
            var skill : Skill = skillTable.findByPrimaryKey( skillId );
            if ( skill ) {
                render.txt_key.text = KEY_ARY[ index ];
                render.img.url = CPlayerPath.getSkillBigIcon( skill.IconName );
//                render.clip_SuperScript.visible = skill.SuperScript > 0 ;
//                if( render.clip_SuperScript.visible )
//                {
//                    render.clip_SuperScript.index = skill.SuperScript - 1;
//                }
            }

            if ( index < 3 ) {
                render.clip_zhi.visible = false;
                render.maskimg.visible =
                        render.maskimgII.visible =
                                render.maskimgH.visible = false;
                render.box_dou.visible = false;
                //todo UI改版后删掉
                var pMaskDisplayObject : DisplayObject;
                pMaskDisplayObject = render.maskimgII;
                if ( pMaskDisplayObject ) {
                    render.img.cacheAsBitmap = true;
                    pMaskDisplayObject.cacheAsBitmap = true;
                    render.img.mask = pMaskDisplayObject;
                }
            }

            var skillInfo : Object = {};
            var skillData : CSkillData = getSkillDataByID( skillId );
            skillInfo[ "skillData" ] = skillData;
            skillInfo[ "skillId" ] = skillId;
            var playerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;

            if ( m_pHeroData.hasData ) {
                render.toolTip = new Handler( playerSystem.showHeroSkillTips, [ skillData ] );
            }
            else {
                render.toolTip = new Handler( playerSystem.showHeroSkillSmallTips, [ skillInfo ] );
            }
        }
        else {

        }
    }

    private function _renderBigSkill( skillItem : SkillItemIIUI, skillId : int ) : void {
        var db : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var skillTable : IDataTable = db.getTable( KOFTableConstants.SKILL );
        var skill : Skill = skillTable.findByPrimaryKey( skillId );
        if ( skill ) {
            skillItem.img.url = CPlayerPath.getSkillBigIcon( skill.IconName );
        }

        var pMaskDisplayObject : DisplayObject = skillItem.maskimgII;
        if ( pMaskDisplayObject ) {
            skillItem.img.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            skillItem.img.mask = pMaskDisplayObject;
            skillItem.eff_fire1.autoPlay = false;
            skillItem.eff_fire2.autoPlay = false;
            skillItem.eff_fire1.visible = false;
            skillItem.eff_fire2.visible = false;
            skillItem.box_dou_1.visible = false;
            skillItem.box_dou_2.visible = false;
            skillItem.box_dou_3.visible = false;
        }

        var skillInfo : Object = {};
        var skillData : CSkillData = getSkillDataByID( skillId );
        skillInfo[ "skillData" ] = skillData;
        skillInfo[ "skillId" ] = skillId;
        var playerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;

        if ( m_pHeroData.hasData ) {
            skillItem.toolTip = new Handler( playerSystem.showHeroSkillTips, [ skillData ] );
        }
        else {
            skillItem.toolTip = new Handler( playerSystem.showHeroSkillSmallTips, [ skillInfo ] );
        }
    }

    private function getSkillDataByID( skillID : int ) : CSkillData {
        var skillData : CSkillData;
        var playerData : CPlayerData = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData;
        var skillAry : Array = playerData.heroList.getHero( m_pHeroData.prototypeID ).skillList.list;
        if ( skillAry ) {
            for each ( skillData in skillAry ) {
                if ( skillData.skillID == skillID ) {
                    return skillData;
                }
            }
        }
        return null;
    }
    private var _videoIndex : int;
    private function _listMouseHandler( evt : Event, idx : int ) : void {
        var skillItemUI : SkillItemUI = _viewUI.list_skill.getCell( idx ) as SkillItemUI;
        if ( evt.type == MouseEvent.CLICK ) {
            _videoIndex = idx;
            _onShowSkillVideo();
        }else if( evt.type == MouseEvent.ROLL_OVER ){
            skillItemUI.btn_lookup.visible = true;
        }else if( evt.type == MouseEvent.ROLL_OUT ){
            skillItemUI.btn_lookup.visible = false;
        }
    }

    private function _onShowLookUpTag( evt : MouseEvent ):void{
        var skillItemUI : SkillItemIIUI = evt.currentTarget as SkillItemIIUI;
        if( evt.type == MouseEvent.ROLL_OVER ){
            skillItemUI.btn_lookup.visible = true;
        }else if( evt.type == MouseEvent.ROLL_OUT ){
            skillItemUI.btn_lookup.visible = false;
        }
    }
    private function _onShowSkillVideo( evt : MouseEvent = null ) : void {
        if( evt )
            _videoIndex = 3;
        (system.getHandler( CPlayerMainViewHandler ) as CPlayerMainViewHandler).showSkillVideoView( _videoIndex );
    }

    //监听===============================================================================

    private function _onClickLeftHandler() : void {
        if ( m_pHeroData ) {
            data = _playerHelper.getPrevOrNextHeroData( m_pHeroData.prototypeID, 1 );
//            (system.getHandler(CPlayerMainViewHandler) as CPlayerMainViewHandler).currSelHeroData = m_pHeroData;
            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.SWITCH_HERO, m_pHeroData ) );
//            _updateView();
        }
    }

    private function _onClickRightHandler() : void {
        if ( m_pHeroData ) {
            data = _playerHelper.getPrevOrNextHeroData( m_pHeroData.prototypeID, 2 );
//            (system.getHandler(CPlayerMainViewHandler) as CPlayerMainViewHandler).currSelHeroData = m_pHeroData;
            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.SWITCH_HERO, m_pHeroData ) );
//            _updateView();
        }
    }

    override protected function _onSwitchHeroHandler( e : CPlayerEvent ) : void {
        var heroData : CPlayerHeroData = e.data as CPlayerHeroData;
        data = heroData;

        _updateView();
    }

    /**
     * 升级、升品、升星后的更新
     */
    private function _onHeroDataUpdateHandler( e : CPlayerEvent ) : void {
        if ( e.type == CPlayerEvent.HERO_DATA && m_pHeroData.hasData ) {
            _updateCombat();
        }
        if ( m_pHeroData ) {
            ObjectUtils.gray( _viewUI.reset_hero_btn, m_pHeroData.level < CPlayerHeroData.REBORN_LEVEL );
        }
    }

    /**
     * 升级成功表现
     * @param e
     */
    private function _onHeroLevelUpHandler( e : CPlayerEvent ) : void {
        if ( TweenMax.isTweening( m_pTransformSpr ) ) {
            TweenMax.killTweensOf( m_pTransformSpr );
        }

        if ( _viewUI.clip_upEffect.isPlaying ) {
            _viewUI.clip_upEffect.stop();
        }

        m_pTransformSpr.scale = 1;
        TweenMax.fromTo( m_pTransformSpr, 0.6, {alpha : 0}, {alpha : 1, onComplete : completeHandler} );
        function completeHandler() : void {
            TweenMax.fromTo( m_pTransformSpr, 0.4, {alpha : 1, scale : 1}, {alpha : 0, scale : 1.5} );
        }

        _viewUI.clip_upEffect.visible = true;
        _viewUI.clip_upEffect.playFromTo( null, null, new Handler( _onPlayCompl ) );
        function _onPlayCompl() : void {
            _viewUI.clip_upEffect.visible = false;
        }
    }

    /**
     * 升品成功
     */
    private function _onHeroQualitySuccHandler( e : CPlayerEvent ) : void {
        var pReciprocalSystem : CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if ( pReciprocalSystem ) {
            pReciprocalSystem.addEventPopWindow( EPopWindow.POP_WINDOW_6, function () : void {
                (system.getHandler( CHeroQualitySuccViewHandler ) as CHeroQualitySuccViewHandler).addDisplay();
            } );
        }
    }

    /**
     * 升星成功
     */
    private function _onHeroStarSuccHandler( e : CPlayerEvent ) : void {
        var pReciprocalSystem : CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if ( pReciprocalSystem ) {
            pReciprocalSystem.addEventPopWindow( EPopWindow.POP_WINDOW_5, function () : void {
                (system.getHandler( CHeroStarSuccViewHandler ) as CHeroStarSuccViewHandler).addDisplay();
            } );
        }

    }

    // =========================================重生
    private function _onClickRebornBtn() : void {
        if ( m_pHeroData && m_pHeroData.level >= CPlayerHeroData.REBORN_LEVEL ) {
            _heroNetHandler.sendGetResetHeroInfo( m_pHeroData.prototypeID );
        } else {
            uiCanvas.showMsgAlert(CLang.Get("hero_reborn_tips", {v1:CPlayerHeroData.REBORN_LEVEL}));
        }
    }
    private function _onStoryClick() : void {
        if (m_pHeroData) {
            var pStorySystem:CStorySystem = system.stage.getSystem(CStorySystem) as CStorySystem;
            if (pStorySystem) {
                var isHasHero:Boolean = pStorySystem.data.hasHero(m_pHeroData.prototypeID);
                if (isHasHero) {
                    const pCtx:ISystemBundleContext = pStorySystem.ctx;
                    pCtx.setUserData(pStorySystem, CBundleSystem.HERO_ID, m_pHeroData.prototypeID);
                    pCtx.setUserData( pStorySystem, CBundleSystem.ACTIVATED, true );
                } else {
                    uiCanvas.showMsgAlert(CLang.Get("story_hero_not_open"));
                }
            }
        }
    }

    private function _onNetHeroRebornInfoSucess( e : CPlayerEvent ) : void {
        if ( m_pHeroData ) {
            var dataList : Array = e.data as Array;
            var heroID : int = dataList[ 0 ];
            var rewardData : Array = dataList[ 1 ];
            var consumeValue : int = dataList[ 2 ] as int;
            if ( !rewardData || rewardData.length == 0 ) {
                // 没返回材料, 不能重生
                uiCanvas.showMsgAlert( CLang.Get( "hero_reborn_need_not_to_reborn_tips" ) );
            } else {
                if ( _isStopPopupRule ) {
                    m_rebornInfoView.addDisplay( m_pHeroData, rewardData, consumeValue );
                } else {
                    if ( m_pHeroData ) {
                        m_rebornRuleView.addDisplay( m_pHeroData, rewardData, consumeValue ); // 提示rule
                    }
                }
            }
        }
    }

    private function _onDoReborn( e : Event ) : void {
        _heroNetHandler.sendResetHero( m_pHeroData.prototypeID );
    }

    private function _onConfirmToOpenReborn( e : Event ) : void {
        if ( m_pHeroData ) {
            m_rebornInfoView.addDisplay( m_pHeroData, m_rebornRuleView.rewardData, m_rebornRuleView.consumeValue );
        }
    }

    private var _isStopPopupRule : Boolean;

    private function _onStopPopupRule( e : Event ) : void {
        _isStopPopupRule = true;
    }

    private function _onNetHeroRebornSucess( e : CPlayerEvent ) : void {
        (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "hero_reborn_success_tips" ) );
    }

    private function get _heroNetHandler() : CHeroNetHandler {
        return system.getHandler( CHeroNetHandler ) as CHeroNetHandler;
    }

    // =================================================
    override public function clear() : void {
        m_pHeroData = null;

        m_pDevelopPart.clear();
    }

    //property===============================================================================
    private function get _viewUI() : HeroDevelopPanelUI {
        return view as HeroDevelopPanelUI;
    }

    public function get heroCombat() : int {
        if ( m_bViewInitialized ) {
//            return _viewUI.num_combat.num;
            return m_pHeroData.battleValue;
        }

        return 0;
    }

    private function onSkillTagHandler():void{
        (_playerSystem.getBean( CSkillTagViewHandler ) as CSkillTagViewHandler ).addDisplay();
    }
    override public function dispose() : void {
        super.dispose();

        m_pHeroData = null;
        m_pDevelopPart = null;

        m_pDevelopPart.dispose();
        m_rebornRuleView.dispose();
        m_rebornRuleView = null;

        m_rebornInfoView.dispose();
        m_rebornInfoView = null;
    }

    private function get _playerDisplay():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_DISPLAY);
    }
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }
    private function get _playerSystem() : CPlayerSystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

}
}
