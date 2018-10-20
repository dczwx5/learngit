//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/26.
 */
package kof.game.guildWar.view {

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.common.loading.CLoadingEvent;
import kof.game.common.status.CGameStatus;
import kof.game.guildWar.CGuildWarManager;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.data.CGuildWarMatchData;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.master.peak1v1.Peak1v1LoadingUI;

import morn.core.components.Clip;

import morn.core.components.Dialog;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.components.ProgressBar;

/**
 * 公会战进入副本加载界面
 */
public class CGuildWarLoadingViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:Peak1v1LoadingUI;

    private var _isFrist:Boolean = true;
    private var _isFirstUpdate:Boolean;
    private var _isMyLoadFinish:Boolean;
    private var _isEnemyLoadFinish:Boolean;
    private var _myVirtualRate:Number;
    private var _enemyVirtualRate:Number;
    private var _isLoadFinish:Boolean;

    public function CGuildWarLoadingViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ Peak1v1LoadingUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return [];
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
                m_pViewUI = new Peak1v1LoadingUI();

                _isFrist = true;
                m_pViewUI.p1_score_title_txt.text = "能源";
                m_pViewUI.p2_score_title_txt.text = "能源";

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        CGameStatus.setStatus(CGameStatus.Status_GuildWarLoading);

        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
//            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        if(m_pViewUI.parent == null)
        {
            _initView();
            _addListeners();
        }

        uiCanvas.addPopupDialog(m_pViewUI);
    }

    private function _addListeners():void
    {
    }

    private function _removeListeners():void
    {
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _isFirstUpdate = true;
            _isLoadFinish = false;
            _myVirtualRate = 0;
            _enemyVirtualRate = 0;
            _isMyLoadFinish = false;
            _isEnemyLoadFinish = false;

            _updateDisplay();

            schedule( 1 / 60, _onSchedule);
        }
    }

    private function _updateDisplay() : Boolean {

        if (_isFrist)
        {
            _isFrist = false;
        }

        if (_isFirstUpdate)
        {
            _isFirstUpdate = false;
            this.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.FIRST_UPDATE_VIEW, null));
        }

        var myRateTxt:Label;
        var myRateBar:ProgressBar;
        var myIconImg:Image;
        var myQualityClip:Clip;
        var myTeamNameTxt:Label;
        var myHeroNameTxt:Label;
        var myScore:Label;

        var enemyRateBTxt:Label;
        var enemyRateBar:ProgressBar;
        var enemyIconImg:Image;
        var enemyQualityClip:Clip;
        var enemyTeamNameTxt:Label;
        var enemyHeroNameTxt:Label;
        var enemyScore:Label;

        if (_guildWarData.matchData.myLocation == 1) {
            myRateTxt = m_pViewUI.p1_load_rate_txt;
            myRateBar = m_pViewUI.p1_load_rate_bar;
            myIconImg = m_pViewUI.p1_icon_img;
            myQualityClip = m_pViewUI.p1_quality_clip;
            myTeamNameTxt = m_pViewUI.p1_team_name;
            myHeroNameTxt = m_pViewUI.p1_hero_name_txt;
            myScore = m_pViewUI.p1_score_txt;

            enemyRateBTxt = m_pViewUI.p2_load_rate_txt;
            enemyRateBar = m_pViewUI.p2_load_rate_bar;
            enemyIconImg = m_pViewUI.p2_icon_img;
            enemyQualityClip = m_pViewUI.p2_quality_clip;
            enemyTeamNameTxt = m_pViewUI.p2_team_name;
            enemyHeroNameTxt = m_pViewUI.p2_hero_name_txt;
            enemyScore = m_pViewUI.p2_score_txt;
        } else {
            myRateTxt = m_pViewUI.p2_load_rate_txt;
            myRateBar = m_pViewUI.p2_load_rate_bar;
            myIconImg = m_pViewUI.p2_icon_img;
            myQualityClip = m_pViewUI.p2_quality_clip;
            myTeamNameTxt = m_pViewUI.p2_team_name;
            myHeroNameTxt = m_pViewUI.p2_hero_name_txt;
            myScore = m_pViewUI.p2_score_txt;

            enemyRateBTxt = m_pViewUI.p1_load_rate_txt;
            enemyRateBar = m_pViewUI.p1_load_rate_bar;
            enemyIconImg = m_pViewUI.p1_icon_img;
            enemyQualityClip = m_pViewUI.p1_quality_clip;
            enemyTeamNameTxt = m_pViewUI.p1_team_name;
            enemyHeroNameTxt = m_pViewUI.p1_hero_name_txt;
            enemyScore = m_pViewUI.p1_score_txt;
        }

        var pPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var myHeroList:Array = pPlayerData.embattleManager.getHeroListByType(EInstanceType.TYPE_GUILD_WAR);
        var myHeroData:CPlayerHeroData = myHeroList[0];

        var matchData:CGuildWarMatchData = _guildWarData.matchData;
        myIconImg.url = CPlayerPath.getPeakUIHeroFacePath(myHeroData.prototypeID);
        myQualityClip.index = myHeroData.qualityBaseType;
        myTeamNameTxt.text = pPlayerData.teamData.name;
        myRateTxt.text = CLang.Get("peak1v1_loading_process_tips", {v1:(int)(_guildWarData.myProgress/10000*100)});
        myRateBar.value = _guildWarData.myProgress/10000;
        myHeroNameTxt.text = myHeroData.heroNameWithColor;
        myScore.text = matchData.myScore.toString();

        var enemyHeroData:CPlayerHeroData = pPlayerData.heroList.createHero(matchData.enemyHeroData.prototypeID);
        enemyHeroData.quality = matchData.enemyHeroData.quality;
        enemyHeroData.level = matchData.enemyHeroData.level;
        enemyIconImg.url = CPlayerPath.getPeakUIHeroFacePath(enemyHeroData.prototypeID);
        enemyQualityClip.index = enemyHeroData.qualityBaseType;
        enemyTeamNameTxt.text = matchData.enemyName;
        enemyRateBTxt.text = CLang.Get("peak1v1_loading_process_tips", {v1:(int)(_guildWarData.enemyProgress/10000*100)});
        enemyRateBar.value = _guildWarData.enemyProgress/10000;
        enemyHeroNameTxt.text = enemyHeroData.heroNameWithColor;
        enemyScore.text = matchData.enemyScore.toString();

        return true;
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            unschedule(_onSchedule);

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

    //监听==========================================================================================================
    protected function _onSchedule(delta:Number) : void {
        if (_isLoadFinish) return ;

        _updatePlayerProgress(_guildWarData.myProgress, _guildWarData.enemyProgress);
        var myRateTxt:Label;
        var myRateBar:ProgressBar;
        var enemyRateBTxt:Label;
        var enemyRateBar:ProgressBar;

        if (_guildWarData.matchData.myLocation == 1) {
            myRateTxt = m_pViewUI.p1_load_rate_txt;
            myRateBar = m_pViewUI.p1_load_rate_bar;
            enemyRateBTxt = m_pViewUI.p2_load_rate_txt;
            enemyRateBar = m_pViewUI.p2_load_rate_bar;
        } else {
            myRateTxt = m_pViewUI.p2_load_rate_txt;
            myRateBar = m_pViewUI.p2_load_rate_bar;
            enemyRateBTxt = m_pViewUI.p1_load_rate_txt;
            enemyRateBar = m_pViewUI.p1_load_rate_bar;
        }

        myRateTxt.text = CLang.Get("peak1v1_loading_process_tips", {v1:(int)(_myVirtualRate*100)});
        myRateBar.value = _myVirtualRate;
        enemyRateBTxt.text = CLang.Get("peak1v1_loading_process_tips", {v1:(int)(_enemyVirtualRate*100)});
        enemyRateBar.value = _enemyVirtualRate;

        if (_isLoadVirtualFinish()) {
            this.dispatchEvent(new CLoadingEvent(CLoadingEvent.VIRTUAL_LOAD_FINISHED));
            _isLoadFinish = true;
        }
    }

    private function _updatePlayerProgress(myProgress:int, enemyProgress:int) : void {
        var reallyProgressRateP1:Number = myProgress/10000;
        var reallyProgressRateP2:Number = enemyProgress/10000;
        if (_isMyLoadFinish) {
            _myVirtualRate += _randomAddRate() * 10; // 即15%
        } else {
            if (_myVirtualRate < reallyProgressRateP1) {
                _myVirtualRate += _randomAddRate();
            }
        }

        if (_isEnemyLoadFinish) {
            _enemyVirtualRate += _randomAddRate() * 10; // 即15%
        } else {
            if (_enemyVirtualRate < reallyProgressRateP2) {
                _enemyVirtualRate += _randomAddRate();
            }
        }

        if (myProgress >= 10000) {
            _isMyLoadFinish = true;
        }
        if (enemyProgress >= 10000) {
            _isEnemyLoadFinish = true;
        }

        if (_myVirtualRate > 1) {
            _myVirtualRate = 1;
        }
        if (_enemyVirtualRate > 1) {
            _enemyVirtualRate = 1;
        }
    }
    private function _isLoadVirtualFinish() : Boolean {
        return _myVirtualRate > 0.999999 && _enemyVirtualRate > 0.999999;
    }
    private function _randomAddRate() : Number {
        return Math.random() * 100 / 10000 + 0.005;
    }


    //===================================get/set======================================
    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function isLoadFinish() : Boolean {
        return _isLoadFinish;
    }

    [Inline]
    private function get _guildWarData() : CGuildWarData
    {
        return (system.getHandler(CGuildWarManager) as CGuildWarManager).data;
    }

    [Inline]
    private function get _playerData() : CPlayerData
    {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
}
}
