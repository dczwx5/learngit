//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/22.
 */
package kof.game.bossChallenge.view {

import QFLib.Utils.StringUtil;

import kof.game.KOFSysTags;
import kof.game.bossChallenge.CBossChallengeManager;
import kof.game.bossChallenge.CBossChallengeNetHandler;
import kof.game.bossChallenge.CBossChallengeSystem;
//import kof.game.bossChallenge.treeUI.SynthTree;
//import kof.game.bossChallenge.treeUI.SynthTreeRender;
//import kof.game.bossChallenge.treeUI.SynthTreeVO;
import kof.game.common.CLang;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.CViewExternalUtil;
import kof.game.im.CIMHandler;
import kof.game.im.CIMSystem;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
//import kof.table.CooperationBossProperty;
//import kof.ui.component.tree.TreeEvent;
import kof.ui.instance.InstanceScenarioUI;
import kof.ui.master.BossChallenge.BossChallengeMainViewUI;

import morn.core.handlers.Handler;

public class CBossChallengeMainView extends CTweenViewHandler{

    private var m_isInit:Boolean;
    private var m_mainView:BossChallengeMainViewUI;
    private var _closeHandler:Handler;
    public var m_viewExternal:CViewExternalUtil;
    public var isOpen:Boolean;

    private var m_pOtherHeroData:CPlayerHeroData;

    public function CBossChallengeMainView() {
        super(false);
    }
    override public function get viewClass() : Array {
        return [BossChallengeMainViewUI, InstanceScenarioUI];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override public function dispose() : void {
        super.dispose();

        if( m_mainView )
            m_mainView.remove();
        m_mainView = null;
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
        if( !m_mainView ){
            m_mainView = new BossChallengeMainViewUI();
            m_mainView.btn_close.clickHandler = new Handler( _onClose );
            m_mainView.btn_team.clickHandler = new Handler( _startFight );
            m_mainView.btn_embattle.clickHandler = new Handler( _btnClick );
            m_mainView.btn_help.clickHandler = new Handler( _btnClick );
            m_mainView.img_help.toolTip = CLang.Get("boss_challenge");
            m_isInit = true;
        }
    }

    override protected function updateDisplay() : void{
        super.updateDisplay();
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addDisplay );
        var imsystem : CIMSystem = system.stage.getSystem(CIMSystem) as CIMSystem;
        (imsystem.getHandler(CIMHandler) as CIMHandler).onFriendInfoListRequest();
        isOpen = true;
    }

    private function _addDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            _challengeNetHandler.createRoomRequest(_challengeManager.bossID);
            callLater( _addToDisplay );
        } else {
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if(!m_mainView)  return;
        setTweenData(KOFSysTags.BOSS_CHALLENGE);
        showDialog(m_mainView,false);

        m_mainView.clip_item.index = _challengeManager.bossID;
        m_mainView.lb_costItem.text = _challengeManager.costItem.name + " x 1";
        m_mainView.lb_costNum.text = CLang.Get(StringUtil.format(CLang.LANG_00401,_challengeManager.costNum));
        m_mainView.img_boss.url = "icon/bossChallenge/" + _challengeManager.baseTable.image + ".png";
        m_mainView.lb_boss.text = _challengeManager.baseTable.HeroName;

        var itemArr : Array = [];
        var idArr : Array = _challengeManager.baseTable.showReward.split( "," );
        for ( var j : int = 0; j < idArr.length; j++ ) {
            itemArr.push( _challengeManager.getItemForItemID( idArr[ j ] ) );
        }

        //奖励展示
        var rewardViewExternalHelper:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternalHelper.view as CRewardItemListView).ui = m_mainView.list_reward;
        rewardViewExternalHelper.show();
        rewardViewExternalHelper.setData(itemArr);
        rewardViewExternalHelper.updateWindow();
//        _treeView = new SynthTree();
//        _treeView.itemRenderer = SynthTreeRender;
//        _treeView.itemVO = SynthTreeVO;
//        _treeView.dataProvider = _challengeManager.getTreeData();
//        _treeView.addEventListener(TreeEvent.CLICK_NODE,_onTreeNodeClicked);
//        _treeView.normalOpenHandle();
//        if(!m_mainView.tree_panel.contains(_treeView))
//            m_mainView.tree_panel.addChild(_treeView);
//        m_mainView.tree_panel.commitMeasure();
    }
//    private var _treeView : SynthTree;
//    private function _onTreeNodeClicked(e : TreeEvent) : void
//    {
//        var render : SynthTreeRender = e.target as SynthTreeRender;
//        var vo : SynthTreeVO = render.dataVO as SynthTreeVO;
//        if(vo.childNodes == null)
//        {
//            var data : CooperationBossProperty = vo.conf;
//            if(data)
//            m_mainView.test1.text = "Boss模板：" + data.TemplateID1;
//            m_mainView.test2.text = "建议战力：" + data.SuggestBattleValue1 + "";
//        }
//        m_mainView.tree_panel.commitMeasure();
//    }
    public function removeDisplay() : void {
        if ( this.m_mainView ) {
            closeDialog(_onFinished);
            _challengeManager.dispose();
            isOpen = false;
        }
    }
    private function _onFinished() : void {
        m_mainView.remove();

        if(m_pOtherHeroData)
        {
            m_pOtherHeroData.dispose();
            m_pOtherHeroData = null;
        }
    }
    override protected function updateData () : void{
        super.updateData();
    }
    public function get closeHandler() : Handler {
        return _closeHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        _closeHandler = value;
    }

    private function _onClose() : void {
        if(_challengeManager.getHelperData())
        {
            var str:String = _challengeManager.getGamePromptStr(3610);//有队友协助作战，确定要退出挑战吗？
            uiCanvas.showMsgBox( str, _confirmClose,null,true,null,null,true,"3610" );
        }
        else
        {
            _confirmClose();
        }
    }
    private function _confirmClose() : void
    {
        if ( this._closeHandler ) {
            this._closeHandler.execute();
            _challengeNetHandler.dissolveRoomRequest(_challengeManager.bossID);
        }
    }
    /**
     * 开始挑战，如果没有队友则跳转布阵界面
     */
    private function _startFight() : void
    {
        var helpData:Object = _challengeManager.getHelperData();
        var selfData : CPlayerHeroData = _challengeManager.recommendHero;
        if(helpData)
        {
            if(selfData.battleValue < _challengeManager.configPower && helpData.power < _challengeManager.configPower)
            {
                var str:String = _challengeManager.getGamePromptStr( 3615 );//战力不足挑战boss？
                uiCanvas.showMsgBox( str, gotoChallenge,null,true,null,null,true,"3615" );
            }
            else
            {
                gotoChallenge();
            }
        }
        else
        {
            _btnClick();
        }
    }
    private function gotoChallenge():void
    {
        _challengeNetHandler.bossChallengeRequest( _challengeManager.recommendHero.ID );
    }
    /**
     * 打开队伍编制和邀请界面
     */
    private function _btnClick() : void
    {
        (_challengeSystem.getBean( CBossChallengeEmbattle ) as CBossChallengeEmbattle ).addDisplay();
    }

    /**
     * 刷新界面
     */
    public function refreshView():void
    {
        if(!m_mainView)  return;
        //设置自己上阵的格斗家
        var selfHero : CPlayerHeroData = _challengeManager.recommendHero;
        if(selfHero)
        {
            m_mainView.clip_self.index = selfHero.qualityBaseType;
            m_mainView.selfHeroItem.quality_clip.index = selfHero.qualityLevelValue;
            m_mainView.selfHeroItem.icon_image.cacheAsBitmap = true;
            m_mainView.selfHeroItem.hero_icon_mask.cacheAsBitmap = true;
            m_mainView.selfHeroItem.icon_image.mask = m_mainView.selfHeroItem.hero_icon_mask;
            m_mainView.selfHeroItem.icon_image.url = CPlayerPath.getHeroItemFacePath(selfHero.prototypeID);
            m_mainView.selfHeroItem.toolTip = new Handler( _playerSystem.showHeroTips, [selfHero]);
        }

        if(m_pOtherHeroData)
        {
            m_pOtherHeroData.dispose();
            m_pOtherHeroData = null;
        }

        //设置协助者提供的格斗家
        var helpData:Object = _challengeManager.getHelperData();
        if(helpData)
        {
//            var helpHero : CPlayerHeroData = _playerData.heroList.getHero(helpData.heroID);
            var helpHero : CPlayerHeroData = _playerData.heroList.createHero(helpData.heroID);
            m_pOtherHeroData = helpHero;

            if(helpHero)
            {
                helpHero.star = helpData.star;
                m_mainView.clip_help.index = helpHero.qualityBaseType;
                m_mainView.clip_help.visible = true;
                m_mainView.helpHeroItem.quality_clip.index = helpHero.qualityLevelValue;
                m_mainView.helpHeroItem.icon_image.cacheAsBitmap = true;
                m_mainView.helpHeroItem.hero_icon_mask.cacheAsBitmap = true;
                m_mainView.helpHeroItem.icon_image.mask = m_mainView.helpHeroItem.hero_icon_mask;
                m_mainView.helpHeroItem.icon_image.url = CPlayerPath.getHeroItemFacePath(helpHero.prototypeID);
                m_mainView.helpHeroItem.toolTip = new Handler( _playerSystem.showHeroTips, [helpHero]);
                m_mainView.btn_help.visible = false;
                m_mainView.btn_team.label = "开始挑战";
            }
        }
        else
        {
            m_mainView.img_assist.visible = true;
            m_mainView.clip_help.visible = false;
            m_mainView.helpHeroItem.quality_clip.index = 7;
            m_mainView.helpHeroItem.icon_image.url = "";
            m_mainView.btn_help.visible = true;
            m_mainView.btn_team.label = "组队挑战";
        }

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
    private function get _playerSystem():CPlayerSystem{
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData
    {
        return _playerSystem.playerData;
    }
}
}
