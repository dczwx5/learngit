//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/26.
 */
package kof.game.bossChallenge.view {

import kof.framework.CViewHandler;
import kof.game.bossChallenge.CBossChallengeManager;
import kof.game.bossChallenge.CBossChallengeNetHandler;
import kof.game.bossChallenge.CBossChallengeSystem;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.master.BossChallenge.BossChallengeInvitationViewUI;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CBossChallengeInvitationView extends CViewHandler{

    private var m_invite : BossChallengeInvitationViewUI;
    private var m_isInit : Boolean;
    public var isOpen : Boolean;
    public function CBossChallengeInvitationView() {
        super(false);
    }

    override public function get viewClass() : Array {
        return [BossChallengeInvitationViewUI];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override public function dispose() : void {
        super.dispose();

        if( m_invite )
            m_invite.remove();
        m_invite = null;
    }

    //重载初始化界面方法
    override protected function onInitializeView() : Boolean{
        if( !super.onInitializeView() )
            return false;
        if(!m_isInit)
            initialize();
        return m_isInit;
    }

    protected function initialize() : void {
        if ( !m_invite ) {
            m_invite = new BossChallengeInvitationViewUI();
            //m_invite.list_reward.renderHandler = new Handler( _setRewardList );
            m_invite.btn_yes.clickHandler = new Handler( _gotoHelp );
            m_invite.btn_no.clickHandler = new Handler( _refuseHelp );
            m_invite.btn_close.clickHandler = new Handler( _refuseHelp );
            m_invite.btn_embattle.clickHandler = new Handler( _showHeroBox );
        }
        m_isInit = true;
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
        if ( !m_invite || !_challengeManager.baseTable)  return;
        uiCanvas.addPopupDialog( m_invite );
        m_invite.lb_boss.text = _challengeManager.baseTable.HeroName;
        m_invite.lb_name.text = _challengeManager.requesterName;
        m_invite.lb_count.text = _challengeManager.rewardCount + "/" + _challengeManager.baseTable.CooperatorRewardLimit;
        m_invite.lb_needPower.text = _challengeManager.needPower + "";

        var itemArr : Array = [];
        var idArr : Array = _challengeManager.baseTable.showReward.split( "," );
        for ( var j : int = 0; j < idArr.length; j++ ) {
            itemArr.push( _challengeManager.getItemForItemID( idArr[ j ] ) );
        }
        //奖励展示
        var rewardViewExternalHelper:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternalHelper.view as CRewardItemListView).ui = m_invite.list_reward;
        rewardViewExternalHelper.show();
        rewardViewExternalHelper.setData(itemArr);
        rewardViewExternalHelper.updateWindow();

        refreshView();
    }
    public function removeDisplay() : void {
        if( m_invite )
        {
            m_invite.close( Dialog.CLOSE );
            _challengeManager.dispose();
            isOpen = false;
        }
    }
    override protected function updateData () : void{
        super.updateData();
    }
    public function refreshView() : void
    {
        var selfHero : CPlayerHeroData = _challengeManager.recommendHero;
        if(selfHero && selfHero.battleValue >= _challengeManager.needPower)
        {
            m_invite.lb_tips.visible = false;
            m_invite.box_hero.visible = true;
            m_invite.btn_yes.disabled = false;
            m_invite.btn_no.disabled = false;

            m_invite.clip_self.index = selfHero.qualityBaseType;
            m_invite.selfHeroItem.quality_clip.index = selfHero.qualityLevelValue;
            m_invite.selfHeroItem.icon_image.cacheAsBitmap = true;
            m_invite.selfHeroItem.hero_icon_mask.cacheAsBitmap = true;
            m_invite.selfHeroItem.icon_image.mask = m_invite.selfHeroItem.hero_icon_mask;
            m_invite.selfHeroItem.icon_image.url = CPlayerPath.getHeroItemFacePath(selfHero.prototypeID);
            m_invite.selfHeroItem.toolTip = new Handler( _playerSystem.showHeroTips, [selfHero]);
            m_invite.num_power.num = selfHero.battleValue;
            _challengeManager.helperHeroID = selfHero.prototypeID;
        }
        else
        {
            m_invite.lb_tips.visible = true;
            m_invite.box_hero.visible = false;
            m_invite.btn_yes.disabled = true;
            m_invite.btn_no.disabled = true;
        }
    }

    /**
     * 打开格斗家选择框
     */
    private function _showHeroBox() : void
    {
        (_challengeSystem.getBean( CBossChallengeHeroBoxView ) as CBossChallengeHeroBoxView ).addDisplay();
    }
    private function _gotoHelp() : void
    {
        _challengeNetHandler.setHeroRequest(_challengeManager.requesterID,_challengeManager.bossID,_challengeManager.helperHeroID);
    }

    /**
     * 拒绝
     */
    private function _refuseHelp() : void
    {
        if(_challengeManager.helperHeroID > 0 && _challengeManager.isDirectInvite)//通过好友邀请的拒绝才给反馈
        {
            _challengeNetHandler.refuseInviteRequest(_challengeManager.requesterID,_challengeManager.bossID);
        }
        removeDisplay();
    }
    private function get _challengeSystem() : CBossChallengeSystem
    {
        return system as CBossChallengeSystem;
    }
    private function get _challengeManager() : CBossChallengeManager
    {
        return system.getBean( CBossChallengeManager ) as CBossChallengeManager;
    }
    private function get _challengeNetHandler() : CBossChallengeNetHandler
    {
        return system.getBean( CBossChallengeNetHandler ) as CBossChallengeNetHandler;
    }
    private function get _playerSystem() : CPlayerSystem{
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
}
}
