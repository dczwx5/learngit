//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/28.
 */
package kof.game.bossChallenge.view {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.bossChallenge.CBossChallengeManager;
import kof.game.bossChallenge.CBossChallengeSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.master.BossChallenge.BossChallengeHeroBoxUI;
import kof.ui.master.BossChallenge.BossChallengeHeroItemUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CBossChallengeHeroBoxView extends CViewHandler{
    private var m_heroBox : BossChallengeHeroBoxUI;
    private var m_isInit : Boolean;

    public function CBossChallengeHeroBoxView() {
        super(false);
    }
    override public function get viewClass() : Array {
        return [BossChallengeHeroBoxUI];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override public function dispose() : void {
        super.dispose();
        if( m_heroBox )
            m_heroBox.remove();
        m_heroBox = null;
    }
    override protected function get additionalAssets() : Array{
        return [
                "frameclip_juesebk.swf"
        ];
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
        if ( !m_heroBox ) {
            m_heroBox = new BossChallengeHeroBoxUI();
            m_heroBox.list_hero.renderHandler = new Handler( _setHeroList );
            m_heroBox.list_hero.mouseHandler = new Handler( _listMouseHandler );
            m_heroBox.btn_close.clickHandler = new Handler( removeDisplay );
            m_heroBox.tab_title.selectHandler = new Handler( _selectHeroList );
        }
        m_isInit = true;
    }

    override protected function updateDisplay() : void{
        super.updateDisplay();
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addDisplay );
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
        if ( !m_heroBox )  return;
        uiCanvas.addPopupDialog( m_heroBox );
        m_heroBox.tab_title.selectedIndex = 0;
        _selectHeroList(0);
    }
    public function removeDisplay() : void {
        if( m_heroBox )
            m_heroBox.close( Dialog.CLOSE );
    }
    override protected function updateData () : void{
        super.updateData();
    }
    private function _selectHeroList(index : int) : void
    {
        var _playerList : Array = _challengeManager.getHeroListByPage(index);
        m_heroBox.list_hero.dataSource = _playerList;
        m_heroBox.panel_hero.scrollTo()
    }
    private function _setHeroList(item:BossChallengeHeroItemUI,index:int) : void
    {
        item.visible = true;
        item.box_effbg.visible = false;
        var heroData:CPlayerHeroData = item.dataSource as CPlayerHeroData;
        if(heroData)
        {
            item.icon_image.cacheAsBitmap = true;
            item.hero_icon_mask.cacheAsBitmap = true;
            item.icon_image.mask = item.hero_icon_mask;
            item.icon_image.url = CPlayerPath.getHeroBigconPath(heroData.prototypeID);
            item.clip_type.index = heroData.job;
            item.star_list.repeatX = heroData.star;
            item.clip_quality.index = heroData.qualityBaseType;
            item.toolTip = new Handler( _playerSystem.showHeroTips, [heroData]);
        }
        else
        {
            item.visible = false;
        }
    }

    private function _listMouseHandler(evt:Event,idx : int ) : void
    {
        if( evt.type == MouseEvent.MOUSE_DOWN )
        {
            for each(var item : BossChallengeHeroItemUI in m_heroBox.list_hero.cells)
            {
                item.box_effbg.visible = false;
            }
            var target : BossChallengeHeroItemUI = m_heroBox.list_hero.getCell(idx) as BossChallengeHeroItemUI;
            var heroData:CPlayerHeroData = target.dataSource as CPlayerHeroData;
            if(!heroData) return;
            target.box_effbg.visible = true;
            _challengeManager.recommendHero = heroData;//邀请者选择协助出阵格斗家
            (_challengeSystem.getBean( CBossChallengeInvitationView ) as CBossChallengeInvitationView ).refreshView();
        }
    }

    private function get _challengeManager() : CBossChallengeManager
    {
        return system.getBean( CBossChallengeManager ) as CBossChallengeManager;
    }
    private function get _playerSystem() : CPlayerSystem{
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
    private function get _challengeSystem() : CBossChallengeSystem
    {
        return system as CBossChallengeSystem;
    }
}
}
