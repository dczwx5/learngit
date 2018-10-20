//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/15.
 */
package kof.game.common.view.resultWin {

import QFLib.Foundation.CKeyboard;

import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Shape;

import flash.events.Event;
import flash.events.KeyboardEvent;

import flash.geom.ColorTransform;

import flash.ui.Keyboard;


import kof.framework.CViewHandler;
import kof.framework.IDatabase;
import kof.game.GMReport.CGMReportData;
import kof.game.GMReport.CGMReportSystem;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.GMReport.view.CGMReportViewHandler;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.EffectItem2UI;
import kof.ui.imp_common.EmbattleSmallItemUI;
import kof.ui.master.arena.ArenaRewardWin2UI;

import morn.core.components.Box;
import morn.core.components.Clip;

import morn.core.components.Component;
import morn.core.components.Label;

import morn.core.handlers.Handler;

/**
 * 多人PVP结算界面
 */
public class CMultiplePVPResultViewHandler extends CViewHandler {

    protected var m_bViewInitialized : Boolean;
    protected var m_pViewUI:ArenaRewardWin2UI;
    protected var m_pData:CPVPResultData;
    protected var m_pKeyBoard:CKeyboard;
    protected var m_pMask:Shape;
    protected var m_iLeftTime:int;
    protected var m_sEnemyName:String;
    protected var m_sFightUID:String;
    protected var m_iInstanceType:int;

    public function CMultiplePVPResultViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ ArenaRewardWin2UI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_arenawin.swf","frameclip_starAdvance.swf", "pvpResult.swf", "peak_game_item.swf"];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new ArenaRewardWin2UI();
//                m_pViewUI.closeHandler = new Handler(_closeHandler);
                m_pViewUI.list_hero_self.renderHandler = new Handler(_renderHero);
                m_pViewUI.list_hero_enemy.renderHandler = new Handler(_renderHero);
                m_pViewUI.list_reward.renderHandler = new Handler(_renderItem);
                m_pViewUI.list_reward_pk1v1.renderHandler = new Handler(_renderItem);
                m_pViewUI.list_extraReward.renderHandler = new Handler(_renderItem2);
                m_pViewUI.btn_confirm.clickHandler = new Handler(_onClickConfirmHandler);
                m_pViewUI.btn_report.clickHandler = new Handler(_onClickReportHandler);

                m_pKeyBoard = new CKeyboard(system.stage.flashStage);
                m_pMask = m_pMask || new Shape();

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        if(m_pData)
        {
            this.loadAssetsByView( viewClass, _showDisplay );
        }
        else
        {
            _exitInstance();
        }
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    protected function _addToDisplay() : void
    {
//        uiCanvas.addPopupDialog( m_pViewUI );
        var pUISystem : CUISystem = system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISystem ) {
//            App.dialog.addChildAt(m_pMask, 0);
//            App.dialog.addChild(m_pViewUI);

            pUISystem.loadingLayer.addChildAt( m_pMask, 0 );
            pUISystem.loadingLayer.addChild( m_pViewUI );
        }

        _initView();
        _startAnimation();
        _addListeners();
        _onStageResize();
    }

    protected function _initView():void
    {
        m_pViewUI.box_fightInfo1.visible = false;
        m_pViewUI.box_fightInfo2.visible = false;
        m_pViewUI.box_point_1v1.visible = false;
        m_pViewUI.view_peakGame.visible = false;
        m_pViewUI.img_vsBg.visible = false;
        m_pViewUI.box_roleLeft.visible = false;
        m_pViewUI.box_roleMid.visible = false;
        m_pViewUI.box_roleRight.visible = false;
        m_pViewUI.box_cultRoleLeft.visible = false;
        m_pViewUI.box_cultRoleRight.visible = false;
        m_pViewUI.box_btn.visible = false;
        m_pViewUI.img_vsIcon.visible = false;
        m_pViewUI.txt_countDown.text = "";
        m_pViewUI.img_cultFailInfo.visible = false;
        m_iLeftTime = _isEndlessTower() ? 5 : 30;
    }

    protected function _addListeners():void
    {
        system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
    }

    protected function _removeListeners():void
    {
//        m_pKeyBoard.unregisterKeyCode(false, Keyboard.SPACE, _onKeyDown);
        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp);

        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
    }

    public function set data(value:CPVPResultData):void
    {
        m_pData = value;
    }

    private function _startAnimation():void
    {
        _bgAnimation();
    }

    private function _bgAnimation():void
    {
        m_pViewUI.clip_animation.visible = true;
        m_pViewUI.clip_animation.playFromTo(null,null,new Handler(_onBgAnimationCompl));
    }

    private function _onBgAnimationCompl():void
    {
        m_pViewUI.clip_animation.stop();
        m_pViewUI.clip_animation.visible = false;

        _roleAnimation();
    }

    private function _roleAnimation():void
    {
        m_pViewUI.box_roleLeft.visible = !_isClimp;
        m_pViewUI.box_roleMid.visible = !_isClimp;
        m_pViewUI.box_roleRight.visible = !_isClimp;

        m_pViewUI.box_cultRoleLeft.visible = _isClimp;
        m_pViewUI.box_cultRoleRight.visible = _isClimp;

        if(_isClimp)// 试炼之镜
        {
            TweenMax.fromTo(m_pViewUI.box_cultRoleLeft,0.4,{x:-694},{x:677});
            var targetX:int = !m_pViewUI.img_cultRoleLeft.url ? 412 : 129;
            TweenMax.fromTo(m_pViewUI.box_cultRoleRight,0.4,{x:1500},{x:targetX,onComplete:_onRoleAnimationCompl});
        }
        else
        {
            TweenMax.fromTo(m_pViewUI.box_roleMid,0.2,{x:1500},{x:712-300,ease:Linear.easeNone});
            TweenMax.fromTo(m_pViewUI.box_roleLeft,0.5,{x:0-500},{x:462-400+15,ease:Linear.easeNone});
            TweenMax.fromTo(m_pViewUI.box_roleRight,0.5,{x:0},{x:962-100-15,ease:Linear.easeNone,onComplete:_onRoleAnimationCompl});
        }
    }

    private function _onRoleAnimationCompl():void
    {
        _vsAnimation();
    }

    private function _vsAnimation():void
    {
        m_pViewUI.img_vsBg.visible = true;
        TweenMax.fromTo(m_pViewUI.img_vsBg,0.5,{width:0},{width:1500,onComplete:_vsAnimationCompl});
    }

    private function _vsAnimationCompl():void
    {
        m_pViewUI.box_fightInfo1.visible = !_isPeak1v1() && !_isGuildWar && !_isStreetFighter;
        m_pViewUI.box_point_1v1.visible = _isPeak1v1() && _isGuildWar && !_isStreetFighter;

        m_pViewUI.box_fightInfo2.visible = !_isPeak() && !_isPeak1v1() && !_isGuildWar && !_isStreetFighter;
        m_pViewUI.view_peakGame.visible = _isPeak() || _isPeak1v1() || _isGuildWar || _isStreetFighter;
        m_pViewUI.img_getExtraReward.visible = (_isPeakNotPk() || _isPeak1v1() || _isGuildWar || _isStreetFighter)
                && m_pData.extraRewards && m_pData.extraRewards.length > 0;
        m_pViewUI.box_multiple.visible = _isPeakNotPk() && m_pData.scoreActivityStart && m_pViewUI.img_getExtraReward.visible;

        m_pViewUI.list_extraReward.visible = _isPeakNotPk() || _isPeak1v1() || _isGuildWar || _isStreetFighter;
        m_pViewUI.img_upRank.visible = _isArena();
        m_pViewUI.num_changeValue_self.visible = _isArena();
        m_pViewUI.img_currRank.visible = _isArena();
        m_pViewUI.img_currPoint.visible = _isPeakNotPk() || _isPeak1v1() || _isGuildWar || _isStreetFighter;
        m_pViewUI.num_currRank.visible = _isArena() || (_isPeakNotPk()) || _isPeak1v1() || _isGuildWar || _isStreetFighter;

        m_pViewUI.img_stjl.visible = _isEndlessTower() && m_pData.isFirstPass && _hasRewards();// 首通奖励
        m_pViewUI.img_tgjl.visible = _isEndlessTower() && !m_pData.isFirstPass && _hasRewards();// 通关奖励

        m_pViewUI.txt_selfRankLabel.visible = _isArena();
        m_pViewUI.txt_value_self.visible = _isArena();
        m_pViewUI.clip_arrow_self.visible = _isArena() && m_pData.selfChangeValue != 0;
        m_pViewUI.txt_enemyRankLabel.visible = _isArena();
        m_pViewUI.txt_value_enemy.visible = _isArena();
        m_pViewUI.clip_arrow_enemy.visible = _isArena() && m_pData.selfChangeValue != 0;

        m_pViewUI.img_vsBg.visible = true;
        m_pViewUI.box_btn.visible = true;
        m_pViewUI.img_vsIcon.visible = true;

        m_pViewUI.btn_report.visible = _isPeak() || _isPeak1v1() || _isGuildWar || _isStreetFighter;
        m_pViewUI.btn_confirm.x = (_isPeak() || _isPeak1v1() || _isGuildWar || _isStreetFighter) ? 145 : 75;
        m_pViewUI.txt_countDown.x = (_isPeak() || _isPeak1v1() || _isGuildWar || _isStreetFighter) ? 158 : 88;

        m_pViewUI.img_cultFailInfo.visible = _isClimp && m_pData.result == EPVPResultType.FAIL;

        system.stage.flashStage.addEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp, false, 0, true);

        TweenMax.fromTo(m_pViewUI.num_currRank,0.8,{num:0},{num:m_pData.selfValue});
        TweenMax.fromTo(m_pViewUI.num_changeValue_self,0.8,{num:0},{num:m_pData.selfChangeValue});

        if(_isPeak1v1() || _isGuildWar || _isStreetFighter)
        {
            _showPeak1v1RewardItem();
        }
        else
        {
            _showCommonRewardItem();
        }

        var len:int = m_pViewUI.list_extraReward.dataSource == null ? 0 : m_pViewUI.list_extraReward.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item2:Box = m_pViewUI.list_extraReward.getCell(i) as Box;
            if(item2)
            {
                item2.visible = false;
                _showExtraRewardItem(item2, 0.3 * i);
            }
        }

        schedule(1, _onScheduleHandler);
    }

    private function _showCommonRewardItem():void
    {
        var len:int = m_pViewUI.list_reward.dataSource == null ? 0 : m_pViewUI.list_reward.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:EffectItem2UI = m_pViewUI.list_reward.getCell(i) as EffectItem2UI;
            if(item)
            {
                item.visible = false;
                _showRewardItem(item, 0.2 * i);
            }
        }
    }

    private function _showPeak1v1RewardItem():void
    {
        var len:int = m_pViewUI.list_reward_pk1v1.dataSource == null ? 0 : m_pViewUI.list_reward_pk1v1.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:EffectItem2UI = m_pViewUI.list_reward_pk1v1.getCell(i) as EffectItem2UI;
            if(item)
            {
                item.visible = false;
                _showRewardItem(item, 0.2 * i);
            }
        }
    }

    private function _showRewardItem(item:EffectItem2UI,delay:Number):void
    {
        if(item)
        {
            delayCall(delay,_onDelay);
            function _onDelay():void
            {
                item.visible = true;
                item.effct_item.visible = true;
                item.effct_item.mouseEnabled = false;
                item.effct_item.interval = 10;
                item.effct_item.playFromTo(null,null,new Handler(_onPlayEnd));
            }

            function _onPlayEnd():void
            {
                item.effct_item.visible = false;
                item.effct_item.mouseEnabled = false;
            }
        }
    }

    private function _showExtraRewardItem(item:Box,delay:Number):void
    {
        if(item)
        {
            delayCall(delay,_onDelay);
            function _onDelay():void
            {
                item.visible = true;

                delayCall(0.1, showPoint);
                delayCall(0.2, showArrow);
            }

            function showPoint():void
            {
                item.getChildAt(1).visible = true;
            }

            function showArrow():void
            {
                item.getChildAt(2).visible = true;
            }
        }
    }

    override protected function updateDisplay():void
    {
        super.updateDisplay();

        if(m_pData)
        {
            _updateResult();
            _updateHeroInfo();

            if(_isPeak1v1() || _isGuildWar || _isStreetFighter)
            {
                _updatePeak1V1PointInfo();
            }
            else
            {
                _updateRankChangeInfo();
                _updateRewardInfo();
            }

            if(_isPeak() || _isPeak1v1() || _isGuildWar || _isStreetFighter)
            {
                _updatePeakGameSelfAndEnemyInfo();
                _updateExtraRewardInfo();
            }
            else
            {
                _updateSelfAndEnemyInfo();
            }
        }
    }

    /**
     * 胜负BG
     */
    private function _updateResult():void
    {
        switch (m_pData.result)
        {
            case EPVPResultType.FAIL:
                m_pViewUI.clip_resultBg.index = 2;
                break;
            case EPVPResultType.WIN:
                m_pViewUI.clip_resultBg.index = 1;
                break;
            case EPVPResultType.TIE:
                m_pViewUI.clip_resultBg.index = 0;
                break;
            case EPVPResultType.FULL_WIN:
                m_pViewUI.clip_resultBg.index = 1;
                break;
        }
    }

    /**
     * 半身像
     */
    private function _updateHeroInfo():void
    {
        var heroList:Array;
        if(m_pData.result == EPVPResultType.FAIL)
        {
            heroList = m_pData.enemyHeroList;
        }
        else
        {
            heroList = m_pData.selfHeroList;
        }

        var heroInfo:CResultHeroInfo = heroList[0] as CResultHeroInfo;
        if(heroInfo)
        {
            if(_isClimp)// 试炼之镜
            {
                m_pViewUI.img_cultRoleRight.url = CPlayerPath.getUIHeroFacePath(heroInfo.heroId);
            }
            else
            {
                m_pViewUI.img_roleMid.url = CPlayerPath.getUIHeroFacePath(heroInfo.heroId);
            }
        }

        heroInfo = heroList[1] as CResultHeroInfo;
        if(heroInfo)
        {
            if(_isClimp)
            {
                m_pViewUI.img_cultRoleLeft.url = CPlayerPath.getUIHeroFacePath(heroInfo.heroId);
            }
            else
            {
                m_pViewUI.img_roleLeft.url = CPlayerPath.getUIHeroFacePath(heroInfo.heroId);
                m_pViewUI.img_roleLeft.transform.colorTransform = new ColorTransform(0.75,0.75,0.75);
            }
        }
        else
        {
            m_pViewUI.img_roleLeft.url = "";
            m_pViewUI.img_roleLeft.transform.colorTransform = new ColorTransform();
            m_pViewUI.img_cultRoleLeft.url = "";
        }

        heroInfo = heroList[2] as CResultHeroInfo;
        if(heroInfo && !_isClimp)
        {
            m_pViewUI.img_roleRight.url = CPlayerPath.getUIHeroFacePath(heroInfo.heroId);
            m_pViewUI.img_roleRight.transform.colorTransform = new ColorTransform(0.75,0.75,0.75);
        }
        else
        {
            m_pViewUI.img_roleRight.url = "";
            m_pViewUI.img_roleRight.transform.colorTransform = new ColorTransform();
        }
    }

    // 排名、积分变化信息
    private function _updateRankChangeInfo():void
    {
        m_pViewUI.num_changeValue_self.num = m_pData.selfChangeValue > 0 ? m_pData.selfChangeValue : 0;
        m_pViewUI.num_currRank.num = m_pData.selfValue;
    }

    // 奖励信息
    private function _updateRewardInfo():void
    {
        m_pViewUI.list_reward.repeatX = m_pData.rewards ? m_pData.rewards.length : 3;
        m_pViewUI.list_reward.dataSource = m_pData.rewards;
        m_pViewUI.img_getReward.visible = !_isEndlessTower() && _hasRewards();
    }

    private function _hasRewards():Boolean
    {
        return m_pData.rewards && m_pData.rewards.length > 0;
    }

    // 额外积分(巅峰赛)、额外奖励信息
    private function _updateExtraRewardInfo():void
    {
        m_pViewUI.list_extraReward.dataSource = m_pData.extraRewards;
        m_pViewUI.img_getExtraReward.visible = m_pData.extraRewards && m_pData.extraRewards.length > 0;

        if(m_pData)
        {
            m_pViewUI.box_multiple.visible = m_pData.scoreActivityStart && m_pViewUI.img_getExtraReward.visible;
            if(m_pViewUI.box_multiple.visible)
            {
                m_pViewUI.list_extraReward.x = m_pViewUI.box_multiple.x + m_pViewUI.box_multiple.width + 12;
            }
            else
            {
                m_pViewUI.list_extraReward.x = 263;
            }

            if (m_pData.scoreActivityBaseMultiple == 2) {
                m_pViewUI.clip_multiple.index = 0;
            } else if (m_pData.scoreActivityBaseMultiple == 3) {
                m_pViewUI.clip_multiple.index = 1;
            } else {
                m_pViewUI.clip_multiple.index = 2;
            }
        }
    }

    // 巅峰对决/公会战/街头争霸 积分信息
    private function _updatePeak1V1PointInfo():void
    {
        m_pViewUI.num_currPoint_1v1.num = m_pData.selfValue;
        m_pViewUI.num_combatPoint_1v1.num = m_pData.damageScore;
        m_pViewUI.num_killPoint_1v1.num = m_pData.rebelKillScore;
        m_pViewUI.num_winPoint_1v1.num = m_pData.alwaysWinScore;

        m_pViewUI.num_combatPoint_1v1.visible = m_pData.damageScore > 0;
        m_pViewUI.num_killPoint_1v1.visible = m_pData.rebelKillScore > 0;
        m_pViewUI.num_winPoint_1v1.visible = m_pData.alwaysWinScore > 0;

        m_pViewUI.img_zdjf.visible = m_pData.damageScore > 0;
        m_pViewUI.img_lsjf.visible = m_pData.alwaysWinScore > 0;
//        m_pViewUI.img_fsjf.visible = m_pData.rebelKillScore > 0;
        m_pViewUI.img_fsjf.visible = false;

        if(m_pData.rewards)
        {
            m_pViewUI.list_reward_pk1v1.repeatX = m_pData.rewards.length;
            m_pViewUI.list_reward_pk1v1.dataSource = m_pData.rewards;
            m_pViewUI.img_getReward_pk1v1.visible = m_pData.rewards.length > 0;
        }
        else
        {
            m_pViewUI.list_reward_pk1v1.dataSource = null;
            m_pViewUI.list_reward_pk1v1.visible = false;
        }
    }

    private function _updateSelfAndEnemyInfo():void
    {
        switch (m_pData.result)
        {
            case EPVPResultType.FAIL:
                m_pViewUI.clip_selfResultIcon.index = 1;
                m_pViewUI.clip_enemyResultIcon.index = 0;
                break;
            case EPVPResultType.WIN:
                m_pViewUI.clip_selfResultIcon.index = 0;
                m_pViewUI.clip_enemyResultIcon.index = 1;

                m_pViewUI.view_peakGame.clip_result_self.index = 0;
                m_pViewUI.view_peakGame.clip_result_enemy.index = 1;
                break;
            case EPVPResultType.TIE:
                m_pViewUI.clip_selfResultIcon.index = 2;
                m_pViewUI.clip_enemyResultIcon.index = 2;
                break;
            case EPVPResultType.FULL_WIN:
                m_pViewUI.clip_selfResultIcon.index = 0;
                m_pViewUI.clip_enemyResultIcon.index = 1;

                m_pViewUI.view_peakGame.clip_result_self.index = 0;
                m_pViewUI.view_peakGame.clip_result_enemy.index = 1;
                break;
        }

        m_pViewUI.txt_roleName_self.text = m_pData.selfRoleName;
        m_pViewUI.txt_roleName_enemy.text = m_pData.enemyRoleName;
        m_pViewUI.list_hero_self.dataSource = m_pData.selfHeroList;
        m_pViewUI.list_hero_enemy.dataSource = m_pData.enemyHeroList;
        m_pViewUI.txt_value_self.text = m_pData.selfValue.toString();
        m_pViewUI.txt_value_enemy.text = m_pData.enemyValue.toString();

        m_pViewUI.clip_arrow_self.x = m_pViewUI.txt_value_self.x + m_pViewUI.txt_value_self.textField.textWidth;
        m_pViewUI.clip_arrow_enemy.x = m_pViewUI.txt_value_enemy.x + m_pViewUI.txt_value_enemy.textField.textWidth;

        m_pViewUI.clip_arrow_self.visible = m_pData.selfChangeValue != 0;
        if(m_pData.selfChangeValue > 0)
        {
            m_pViewUI.clip_arrow_self.index = 0;
        }
        else if(m_pData.selfChangeValue < 0)
        {
            m_pViewUI.clip_arrow_self.index = 1;
        }

        m_pViewUI.clip_arrow_enemy.visible = m_pData.enemyChangeValue != 0;
        if(m_pData.enemyChangeValue > 0)
        {
            m_pViewUI.clip_arrow_enemy.index = 0;
        }
        else if(m_pData.enemyChangeValue < 0)
        {
            m_pViewUI.clip_arrow_enemy.index = 1;
        }

        m_sEnemyName = m_pData.enemyRoleName;
    }

    private function _updatePeakGameSelfAndEnemyInfo():void
    {
        switch (m_pData.result)
        {
            case EPVPResultType.FAIL:
                m_pViewUI.view_peakGame.clip_result_self.index = 1;
                m_pViewUI.view_peakGame.clip_result_enemy.index = 0;
                break;
            case EPVPResultType.WIN:
                m_pViewUI.view_peakGame.clip_result_self.index = 0;
                m_pViewUI.view_peakGame.clip_result_enemy.index = 1;
                break;
            case EPVPResultType.TIE:
                m_pViewUI.view_peakGame.clip_result_self.index = 2;
                m_pViewUI.view_peakGame.clip_result_enemy.index = 2;
                break;
            case EPVPResultType.FULL_WIN:
                m_pViewUI.view_peakGame.clip_result_self.index = 0;
                m_pViewUI.view_peakGame.clip_result_enemy.index = 1;
                break;
        }

        m_pViewUI.view_peakGame.txt_roleName_self.text = m_pData.selfRoleName;
        m_pViewUI.view_peakGame.txt_roleName_self_center.text = m_pData.selfRoleName;
        m_pViewUI.view_peakGame.txt_roleName_self.visible = !(m_pViewUI.view_peakGame.txt_roleName_self_center.visible = _isPeakPk());

        m_pViewUI.view_peakGame.txt_roleName_enemy.text = m_pData.enemyRoleName;
        m_pViewUI.view_peakGame.txt_roleName_enemy_center.text = m_pData.enemyRoleName;
        m_pViewUI.view_peakGame.txt_roleName_enemy.visible = !(m_pViewUI.view_peakGame.txt_roleName_enemy_center.visible = _isPeakPk());

        m_pViewUI.view_peakGame.txt_value_self.text = m_pData.selfChangeValue.toString();
        m_pViewUI.view_peakGame.txt_value_self.color = m_pData.selfChangeValue >= 0 ? 0xff18 : 0xf93434;
        m_pViewUI.view_peakGame.txt_RankLabel_self.visible = m_pViewUI.view_peakGame.txt_value_self.visible = !(_isPeakPk());
        m_pViewUI.view_peakGame.txt_RankLabel_self.text = _isGuildWar == true ? "能源" : "积分";

        m_pViewUI.view_peakGame.txt_value_enemy.text = m_pData.enemyChangeValue.toString();
        m_pViewUI.view_peakGame.txt_value_enemy.color = m_pData.enemyChangeValue >= 0 ? 0xff18 : 0xf93434;
        m_pViewUI.view_peakGame.txt_RankLabel_enemy.visible = m_pViewUI.view_peakGame.txt_value_enemy.visible = !(_isPeakPk());
        m_pViewUI.view_peakGame.txt_RankLabel_enemy.text = _isGuildWar == true ? "能源" : "积分";

        m_pViewUI.view_peakGame.clip_arrow_self.x = m_pViewUI.view_peakGame.txt_value_self.x
                + m_pViewUI.view_peakGame.txt_value_self.textField.textWidth;
        m_pViewUI.view_peakGame.clip_arrow_enemy.x = m_pViewUI.view_peakGame.txt_value_enemy.x
                + m_pViewUI.view_peakGame.txt_value_enemy.textField.textWidth;

        m_pViewUI.view_peakGame.clip_arrow_self.visible = m_pData.selfChangeValue != 0;
        if(m_pData.selfChangeValue > 0)
        {
            m_pViewUI.view_peakGame.clip_arrow_self.index = 0;
        }
        else if(m_pData.selfChangeValue < 0)
        {
            m_pViewUI.view_peakGame.clip_arrow_self.index = 1;
        }

        m_pViewUI.view_peakGame.clip_arrow_enemy.visible = m_pData.enemyChangeValue != 0;
        if(m_pData.enemyChangeValue > 0)
        {
            m_pViewUI.view_peakGame.clip_arrow_enemy.index = 0;
        }
        else if(m_pData.enemyChangeValue < 0)
        {
            m_pViewUI.view_peakGame.clip_arrow_enemy.index = 1;
        }

        // 段位信息
        if(_isPeak())
        {
            m_pViewUI.view_peakGame.view_self.visible = true;
            m_pViewUI.view_peakGame.view_enemy.visible = true;
            CPeakGameLevelItemUtil.setValue(m_pViewUI.view_peakGame.view_self, m_pData.selfSegment.levelId, m_pData.selfSegment.subLevelId, m_pData.selfSegment.levelName, m_pData.selfSegment.isShowName);
            CPeakGameLevelItemUtil.setValue(m_pViewUI.view_peakGame.view_enemy, m_pData.enemySegment.levelId, m_pData.enemySegment.subLevelId, m_pData.enemySegment.levelName, m_pData.enemySegment.isShowName);
        }
        else
        {
            m_pViewUI.view_peakGame.view_self.visible = false;
            m_pViewUI.view_peakGame.view_enemy.visible = false;
        }

        m_sEnemyName = m_pData.enemyRoleName;
        m_iInstanceType = m_pData.instanceType;
        m_sFightUID = m_pData.fightUUID;
    }

    protected function _onKeyDown(keyCode:uint):void
    {
        switch (keyCode)
        {
            case Keyboard.SPACE:
                _closeHandler();
                break;
        }
    }

    private function _onKeyboardUp(e:KeyboardEvent) : void
    {
        if(e.keyCode == Keyboard.SPACE)
        {
            _closeHandler();
        }
    }

    protected function _closeHandler(type:String = null):void
    {
        _removeListeners();

        _clear();

        if(m_pViewUI && m_pViewUI.parent)
        {
//            m_pViewUI.close( Dialog.CLOSE );
            m_pViewUI.parent.removeChild(m_pViewUI);
        }

        if(m_pMask && m_pMask.parent)
        {
            m_pMask.parent.removeChild(m_pMask);
        }

        unschedule(_onScheduleHandler);

        (system.stage.getSystem(CUISystem) as CUISystem).showSceneLoading();

        _exitInstance();
    }

    protected function _exitInstance():void
    {
        (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).exitInstance();
    }

    private function _onScheduleHandler(delta : Number):void
    {
        m_pViewUI.txt_countDown.text = m_iLeftTime + "s后自动关闭";
        m_iLeftTime--;

        if(m_iLeftTime <= -1)
        {
            _closeHandler();
        }
    }

    private function _onClickConfirmHandler():void
    {
        _closeHandler();
    }

    private function _onClickReportHandler():void
    {
        (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).callWhenInMainCity(openGMReport,[],CGMReportViewHandler,
                CInstanceExitProcess.FLAG_GM_REPORT,9999);

        function openGMReport():void
        {
            var reportData:CGMReportData = new CGMReportData();
            reportData.playerName = m_sEnemyName;
            reportData.instanceType = m_iInstanceType;
            reportData.fightUUID = m_sFightUID;
            (system.stage.getSystem(CGMReportSystem) as CGMReportSystem).dispatchEvent(new CGMReportEvent(CGMReportEvent.OpenReportWin, reportData));
        }

        _closeHandler();
    }

    private function _onStageResize( event : Event = null ) : void
    {
        this.redrawMask();

        var stageWidth:int = system.stage.flashStage.stageWidth;
        var stageHeight:int = system.stage.flashStage.stageHeight;

        m_pViewUI.x = stageWidth - m_pViewUI.width >> 1;
        m_pViewUI.y = stageHeight - m_pViewUI.height >> 1;
    }

    private function redrawMask() : void
    {
        if ( !m_pMask )
            return;
        m_pMask.graphics.clear();
        m_pMask.graphics.beginFill( 0x0 );
        m_pMask.graphics.drawRect( 0, 0, system.stage.flashStage.stageWidth, system.stage.flashStage.stageHeight );
        m_pMask.graphics.endFill();
    }


// render===============================================================================================
    private function _renderHero(item:Component, index:int):void
    {
        if(!(item is EmbattleSmallItemUI))
        {
            return;
        }

        var render:EmbattleSmallItemUI = item as EmbattleSmallItemUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var heroInfo:CResultHeroInfo = render.dataSource as CResultHeroInfo;
        if(null != heroInfo)
        {
            var heroData:CPlayerHeroData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.createHero(heroInfo.heroId);
            render.item.icon_image.url = CPlayerPath.getHeroSmallIconPath(heroData.prototypeID);
            render.item.quality_clip.index = 0;
            render.btn_add.visible = false;
            render.base_quality_clip.visible = true;
            render.base_quality_clip.index = heroData.qualityBaseType;
        }
        else
        {
            render.item.icon_image.url = "";
            render.item.quality_clip.index = 0;
            render.btn_add.visible = false;
            render.base_quality_clip.visible = false;
        }
    }

    private function _renderItem(item:Component, index:int):void
    {
        if(!(item is EffectItem2UI))
        {
            return;
        }

        var render:EffectItem2UI = item as EffectItem2UI;
        render.mouseChildren = false;
        render.mouseEnabled = true;
        var rewardData:CResultRewardInfo = render.dataSource as CResultRewardInfo;

        if(null != rewardData)
        {
            var itemData:CItemData = new CItemData();
            itemData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            itemData.updateDataByData(CItemData.createObjectData(rewardData.itemId));
            if(rewardData.itemNum > 1)
            {
                render.txt_num.text = rewardData.itemNum.toString();
            }
            else
            {
                render.txt_num.text = "";
            }

            render.img_icon.url = itemData.iconSmall;
            render.clip_bg.index = itemData.quality;
            render.effct_item.visible = false;
            render.clip_eff.visible = itemData.effect;

            render.toolTip = new Handler( _showTips, [render, rewardData.itemId] );
        }
        else
        {
            render.txt_num.text = "";
            render.img_icon.url = "";
            render.toolTip = null;
            render.effct_item.visible = false;
            render.clip_eff.visible = false;
        }
    }

    /**
     * 物品tips
     * @param item
     */
    private function _showTips(item:Component,itemId:int):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item,[itemId]);
    }

    private function _renderItem2(item:Component, index:int):void
    {
        if(!(item is Box))
        {
            return;
        }

        var render:Box = item as Box;
        render.mouseChildren = false;
        render.mouseEnabled = false;
        var clip:Clip = render.getChildAt(0) as Clip;
        var type:int = render.dataSource as int;
        clip.index = type;

        render.visible = false;
        var label:Label = render.getChildAt(1) as Label;
        if(index == 0)
        {
            label.text = "10";
        }
        else if(index == 1)
        {
            label.text = "5";
        }
        else
        {
            label.text = "";
        }

        render.getChildAt(1).visible = false;
        render.getChildAt(2).visible = false;
    }

    private function _clear():void
    {
        m_pViewUI.num_changeValue_self.num = 0;
        m_pViewUI.num_currRank.num = 0;
        m_pViewUI.num_combatPoint_1v1.num = 0;
        m_pViewUI.num_currPoint_1v1.num = 0;
        m_pViewUI.num_killPoint_1v1.num = 0;
        m_pViewUI.num_winPoint_1v1.num = 0;
        m_pViewUI.list_reward.dataSource = [];
        m_pViewUI.list_reward_pk1v1.dataSource = [];
        m_pViewUI.list_extraReward.dataSource = [];
        m_pViewUI.clip_selfResultIcon.index = 0;
        m_pViewUI.clip_enemyResultIcon.index = 0;
        m_pViewUI.txt_roleName_self.text = "";
        m_pViewUI.txt_roleName_enemy.text = "";
        m_pViewUI.txt_value_self.text = "";
        m_pViewUI.txt_value_enemy.text = "";
        m_pViewUI.clip_arrow_self.visible = false;
        m_pViewUI.clip_arrow_enemy.visible = false;
        m_pViewUI.list_hero_self.dataSource = [];
        m_pViewUI.list_hero_enemy.dataSource = [];
        m_pViewUI.img_roleLeft.url = "";
        m_pViewUI.img_roleMid.url = "";
        m_pViewUI.img_roleRight.url = "";

        m_pData = null;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pData = null;
        m_pViewUI = null;
        m_pKeyBoard = null;
        m_pMask = null;
    }

    /**
     * 巅峰赛
     * @return
     */
    private function _isPeak() : Boolean {
        return EInstanceType.isPeakGame(m_pData.instanceType) || EInstanceType.isPeakPK(m_pData.instanceType);
    }
    private function _isPeakNotPk() : Boolean {
        return EInstanceType.isPeakGame(m_pData.instanceType);
    }
    private function _isPeakPk() : Boolean {
        return EInstanceType.isPeakPK(m_pData.instanceType);
    }

    /**
     * 试炼之镜
     * @return
     */
    private function get _isClimp():Boolean
    {
        return EInstanceType.isClimp(m_pData.instanceType);
    }

    /**
     * 竞技场
     * @return
     */
    private function _isArena():Boolean
    {
        return EInstanceType.isArena(m_pData.instanceType);
    }

    /**
     * 无尽之塔
     * @return
     */
    private function _isEndlessTower():Boolean
    {
        return EInstanceType.isEndLessTower(m_pData.instanceType);
    }

    /**
     * 巅峰对决
     * @return
     */
    private function _isPeak1v1():Boolean
    {
        return EInstanceType.isPeak1v1(m_pData.instanceType);
    }

    /**
     * 公会战
     * @return
     */
    private function get _isGuildWar():Boolean
    {
        return EInstanceType.isGuildWar(m_pData.instanceType);
    }

    /**
     * 街头争霸
     */
    private function get _isStreetFighter():Boolean
    {
        return EInstanceType.isStreetFighter(m_pData.instanceType);
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }
}
}
