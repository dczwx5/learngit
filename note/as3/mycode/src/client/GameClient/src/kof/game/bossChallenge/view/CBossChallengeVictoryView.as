//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/30.
 */
package kof.game.bossChallenge.view {


import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import kof.framework.CViewHandler;
import kof.game.bossChallenge.CBossChallengeManager;
import kof.game.bossChallenge.CBossChallengeNetHandler;
import kof.game.bossChallenge.CBossChallengeSystem;
import kof.game.bossChallenge.data.CBossChallengeRewardData;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.master.BossChallenge.BossChallengeWinUI;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CBossChallengeVictoryView extends CViewHandler{
    private var m_iLeftTime : int;
    private var m_isInit : Boolean;
    public var isOpen : Boolean;
    private var m_victory : BossChallengeWinUI;
    public function CBossChallengeVictoryView()
    {
        super(false);
    }

    override public function get viewClass() : Array {
        return [BossChallengeWinUI];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override public function dispose() : void {
        super.dispose();

        if( m_victory )
            m_victory.remove();
        m_victory = null;
    }

    //重载初始化界面方法
    override protected function onInitializeView() : Boolean{
        if( !super.onInitializeView() )
            return false;
        if(!m_isInit)
            initialize();
        return m_isInit;
    }

    protected function initialize() : void{
        if( !m_victory ){
            m_victory = new BossChallengeWinUI();
            m_victory.ok2_btn.clickHandler = new Handler(_onClose);
            m_isInit = true;
        }
    }

    override protected function updateDisplay() : void{
        super.updateDisplay();
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addDisplay );
        isOpen = true;
    }

    private function _addDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if(!m_victory)  return;
        uiCanvas.addDialog( m_victory );
        system.stage.flashStage.addEventListener( KeyboardEvent.KEY_UP, _onKeyboardUp, false, 0, true );
        _onShow();
    }
    public function removeDisplay() : void {
        if ( this.m_victory ) {
            m_victory.close( Dialog.CLOSE );
            isOpen = false;
        }
    }
    override protected function updateData () : void{
        super.updateData();
    }

    private function _onClose() : void {
        system.stage.flashStage.removeEventListener( KeyboardEvent.KEY_UP, _onKeyboardUp);
        unschedule(_onScheduleHandler);
        _challengeNet.sendExitInstance(true);
    }
    private function _onShow():void
    {
        var _data : CBossChallengeRewardData = _challengeManger.getResultData();

        var rewardViewExternal:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternal.view as CRewardItemListView).ui = m_victory.self_reward;
        rewardViewExternal.show();
        rewardViewExternal.setData(_data.selfRewards);
        rewardViewExternal.updateWindow();
        m_victory.img_role.url = CPlayerPath.getUIHeroFacePath( _data.selfHeroID );

        if(_data.cooperateName && _data.cooperateHeroID)
        {
            m_victory.box_helper.visible = true;
            m_victory.lb_name.text = _data.cooperateName;
            m_victory.lb_dp.text = _data.cooperateDP + "%";

            var helpHero : CPlayerHeroData = _playerData.heroList.getHero( _data.cooperateHeroID);
            m_victory.clip_help.index = helpHero.qualityBaseType;
            m_victory.helpHeroItem.quality_clip.index = helpHero.qualityLevelValue;
            m_victory.helpHeroItem.icon_image.cacheAsBitmap = true;
            m_victory.helpHeroItem.hero_icon_mask.cacheAsBitmap = true;
            m_victory.helpHeroItem.icon_image.mask = m_victory.helpHeroItem.hero_icon_mask;
            m_victory.helpHeroItem.icon_image.url = CPlayerPath.getHeroItemFacePath(helpHero.prototypeID);

            var rewardViewExternalHelper:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
            (rewardViewExternalHelper.view as CRewardItemListView).ui = m_victory.help_reward;
            rewardViewExternalHelper.show();
            rewardViewExternalHelper.setData(_data.cooperateRewards);
            rewardViewExternalHelper.updateWindow();
        }
        else
        {
            m_victory.box_helper.visible = false;
        }
        m_iLeftTime = 30;
        schedule(1, _onScheduleHandler);
    }

    private function _onKeyboardUp( e:KeyboardEvent ) : void
    {
        if( e.keyCode == Keyboard.SPACE)
        {
            if (m_victory.ok2_btn.visible)
            {
                _onClose();
            }
        }
    }

    private function _onScheduleHandler(delta : Number):void
    {
        m_victory.txt_countDown.text = "("+m_iLeftTime + "s后自动关闭)";
        m_iLeftTime--;

        if(m_iLeftTime <= -1)
        {
            this._onClose();
        }
    }

    private function get _challengeNet() : CBossChallengeNetHandler
    {
        return system.getBean( CBossChallengeNetHandler ) as CBossChallengeNetHandler;
    }
    private function get _challengeManger() : CBossChallengeManager
    {
        return system.getBean( CBossChallengeManager ) as CBossChallengeManager;
    }
    private function get _playerData() : CPlayerData
    {
        return (system.stage.getSystem(CPlayerSystem ) as CPlayerSystem).playerData;
    }
}
}