//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/9/26.
 */
package kof.game.vip.view {

import flash.events.Event;

import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.game.common.hero.CHeroSpriteUtil;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.vip.CVIPManager;
import kof.game.vip.CVIPSystem;
import kof.table.VipLevel;
import kof.ui.CUISystem;
import kof.ui.master.Vip.VipBiliTipsUI;

import morn.core.components.SpriteBlitFrameClip;

public class CVIPBiliTipsView extends CViewHandler {

    private var m_TipsUI:VipBiliTipsUI;
    private var m_bViewInitialized : Boolean;

    private var m_pFrameClip : SpriteBlitFrameClip;

    public function CVIPBiliTipsView() {
        super( false );
    }

    override public function dispose():void {
        m_TipsUI.removeEventListener(Event.ADDED_TO_STAGE, _showHero);
        m_TipsUI.removeEventListener(Event.REMOVED_FROM_STAGE, _hideHero);
    }

    override public function get viewClass() : Array {
        return [ VipBiliTipsUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            this.initialize();
        }

        return m_bViewInitialized;
    }

    protected function initialize() : void {
        if ( m_TipsUI == null ) {
            m_TipsUI = new VipBiliTipsUI();
            m_TipsUI.addEventListener(Event.ADDED_TO_STAGE, _showHero);
            m_TipsUI.addEventListener(Event.REMOVED_FROM_STAGE, _hideHero);

            m_pFrameClip =  m_TipsUI.clip_character as SpriteBlitFrameClip;

            m_bViewInitialized = true;
        }
    }

    public function showTips():void {
        this.loadAssetsByView( viewClass, _addToDisplay )
    }

    private function _addToDisplay():void {

        if ( onInitializeView() ) {
            invalidate();
        }

        App.tip.addChild(m_TipsUI);
    }

    private function _showHero( e : Event ):void {
        var playerData : CPlayerData = vipManager.playSystem.playerData;
        var vipData: VipLevel = vipManager.getVipLevelTableByID( CVIPSystem.VIP_LEVEL_6 );
        var heroData : CPlayerHeroData = playerData.heroList.getHero(vipData.heroID);
        CHeroSpriteUtil.setSkin( system.stage.getSystem( CUISystem ) as CAppSystem, m_pFrameClip, heroData, false, "Idle_1", true );
    }

    private function _hideHero(e : Event) : void {
        CHeroSpriteUtil.setSkin( system.stage.getSystem( CUISystem ) as CAppSystem, m_pFrameClip, null, false);
    }

    private function get vipManager() : CVIPManager {
        return system.getBean( CVIPManager ) as CVIPManager;
    }

}
}
