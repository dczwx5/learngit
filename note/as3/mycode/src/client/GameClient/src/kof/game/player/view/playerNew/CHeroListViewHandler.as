//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/7.
 */
package kof.game.player.view.playerNew {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.CLang;
import kof.game.common.view.CTweenViewHandler;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.impression.CImpressionManager;
import kof.game.impression.CImpressionSystem;
import kof.game.impression.util.CImpressionUtil;
import kof.game.instance.enum.EInstanceType;
import kof.game.itemGetPath.CItemGetSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EHeroIntelligence;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.game.player.view.playerNew.util.CPlayerTipHandler;
import kof.game.player.view.playerNew.view.CSkillVideoViewHandler;
import kof.game.player.view.playerNew.view.heroDevelop.CCollectAttrDescViewHandler;
import kof.game.shop.enum.EShopType;
import kof.game.switching.CSwitchingHandler;
import kof.game.switching.CSwitchingSystem;
import kof.game.teaching.CTeachingInstanceManager;
import kof.game.teaching.CTeachingInstanceSystem;
import kof.ui.master.jueseNew.HeroListWinUI;
import kof.ui.master.jueseNew.render.HeroListRenderUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CHeroListViewHandler extends CTweenViewHandler{

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:HeroListWinUI;
    private var m_pCloseHandler:Handler;
    private var m_pTweenShowEndHandler:Handler;
    private var m_bScrollEnable:Boolean = true;
    private var m_listEmbattleId:Array;
    private var m_attrLabelArr:Array;// 收集总加成属性label

    public function CHeroListViewHandler()
    {
    }

    override public function get viewClass() : Array
    {
        return [ HeroListWinUI ];
    }

    override protected function get additionalAssets():Array
    {
        return ["frameClip_heroCard.swf"];
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
                m_pViewUI = new HeroListWinUI();
                m_pViewUI.name = "HeroListWinUI";
                m_pViewUI.closeHandler = new Handler(_onCloseHandler);

                m_pViewUI.list_hasGet.renderHandler = new Handler(_renderItem);
                m_pViewUI.list_hasGet.mouseHandler = new Handler(_onClickListHandler);

                m_pViewUI.list_notGet.renderHandler = new Handler(_renderItem);
                m_pViewUI.list_notGet.mouseHandler = new Handler(_onClickListHandler);

                m_pViewUI.btn_gotoHire.clickHandler = new Handler(_onGotoHireHandler);
                m_pViewUI.btn_impression.clickHandler = new Handler(_onOpenImpressionSystem);
                m_pViewUI.btn_teaching.clickHandler = new Handler(_onOpenTeaching);
                m_pViewUI.link_collect.clickHandler = new Handler(_onClickLinkHandler);

                m_pViewUI.box_hasGet.addEventListener(Event.RESIZE, _onResize);
                m_pViewUI.panel.vScrollBar.changeHandler = new Handler(_onScrollChange);

                m_attrLabelArr = [];
                m_attrLabelArr[0] = m_pViewUI.txt_life;
                m_attrLabelArr[1] = m_pViewUI.txt_attack;
                m_attrLabelArr[2] = m_pViewUI.txt_defense;

                _updateScrollState();

                _renderList = {};

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
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
        m_pViewUI.list_hasGet.dataSource = [];
        m_pViewUI.list_notGet.dataSource = [];

        setTweenData(KOFSysTags.ROLE);
        showDialog(m_pViewUI,false, _onShowEnd);
    }

    private function _onShowEnd() : void
    {
//        if(m_pViewUI.parent == null)
//        {
            invalidate();
            _initView();
            _addListeners();
//        }

        var playerMainWin:CPlayerMainViewHandler = system.getHandler(CPlayerMainViewHandler) as CPlayerMainViewHandler;
        if(playerMainWin.isViewShow)
        {
            playerMainWin.addDisplay();
        }

        if(m_pTweenShowEndHandler)
        {
            m_pTweenShowEndHandler.execute();
        }
    }

    private function _initView():void
    {
        m_pViewUI.panel.vScrollBar.value = 0;
    }

    private function _addListeners():void
    {
        system.stage.getSystem(CPlayerSystem ).addEventListener(CPlayerEvent.HERO_ADD,_onHeroAddHandler);
        system.stage.getSystem(CBagSystem).addEventListener(CBagEvent.BAG_UPDATE, _onBagItemUpdateHandler);
        system.addEventListener(CPlayerEvent.EQUIP_DATA,_onUpdateTipInfoHandler);
        system.addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);
        system.addEventListener(CPlayerEvent.SKILL_BREAK,_onUpdateTipInfoHandler);
        system.addEventListener(CPlayerEvent.SKILL_LVUP,_onUpdateTipInfoHandler);
        system.addEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY,_onUpdateTipInfoHandler);
        system.addEventListener(CPlayerEvent.HERO_DATA,_onHeroInfoUpdateHandler);
        system.stage.getSystem(CEmbattleSystem).addEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onUpdateTipInfoHandler);
    }

    private function _removeListeners():void
    {
        system.stage.getSystem(CPlayerSystem ).removeEventListener(CPlayerEvent.HERO_ADD,_onHeroAddHandler);
        system.stage.getSystem(CBagSystem).removeEventListener(CBagEvent.BAG_UPDATE, _onBagItemUpdateHandler);
        system.removeEventListener(CPlayerEvent.EQUIP_DATA,_onUpdateTipInfoHandler);
        system.removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);
        system.removeEventListener(CPlayerEvent.SKILL_BREAK,_onUpdateTipInfoHandler);
        system.removeEventListener(CPlayerEvent.SKILL_LVUP,_onUpdateTipInfoHandler);
        system.removeEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY,_onUpdateTipInfoHandler);
        system.removeEventListener(CPlayerEvent.HERO_DATA,_onHeroInfoUpdateHandler);
        system.stage.getSystem(CEmbattleSystem).removeEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onUpdateTipInfoHandler);
    }

    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            m_bScrollEnable = true;

            var playerMainWin:CPlayerMainViewHandler = system.getHandler(CPlayerMainViewHandler) as CPlayerMainViewHandler;
            if(playerMainWin.isViewShow)
            {
                playerMainWin.removeDisplay();
            }

            m_listEmbattleId = null;

            m_pViewUI.list_hasGet.dataSource = [];
            m_pViewUI.list_notGet.dataSource = [];

            m_pTweenShowEndHandler = null;
        }
    }

    override protected function updateDisplay():void
    {
        _updateWindow();
    }

    private function _updateWindow():void
    {
        _renderList = {};

        // 看能不能优化一下, 不要每次都排序
        var list:Array = _playerData.displayList;

        var existFilter:Function = function (item:CPlayerHeroData, idx:int, arr:Array) : Boolean {
            return item.hasData || (item.hasData == false && item.enoughToHire);
        };
        var unHireFilter:Function = function (item:CPlayerHeroData, idx:int, arr:Array) : Boolean {
            return item.hasData == false && item.enoughToHire == false;
        };
        var hireList:Array = list.filter(existFilter);
        var unHireList:Array = list.filter(unHireFilter);
        hireList.sort(_playerData.heroList.compare);
        unHireList.sort(_playerData.heroList.compare);
        // list 排序
        var unlockRepeatY:int = m_pViewUI.list_hasGet.repeatY;
        var curUnlockRepeatY:int = (hireList.length-1) / m_pViewUI.list_hasGet.repeatX + 1;
        m_pViewUI.list_hasGet.dataSource = hireList;
        if (unlockRepeatY != curUnlockRepeatY)
        {
            m_pViewUI.list_hasGet.repeatY = curUnlockRepeatY;
        }

        var lockRepeatY:int = m_pViewUI.list_notGet.repeatY;
        var curLockRepeatY:int = (unHireList.length-1) / m_pViewUI.list_notGet.repeatX + 1;
        m_pViewUI.list_notGet.dataSource = unHireList;
        if (lockRepeatY != curLockRepeatY)
        {
            m_pViewUI.list_notGet.repeatY = curLockRepeatY;
        }
        m_pViewUI.list_notGet.visible = unHireList.length != 0;

        _onResize(null);

        _lastScrollValue = m_pViewUI.panel.vScrollBar.value+1;
        m_pViewUI.panel.refresh();

        var ownAndEnoughNum:int = m_pViewUI.list_hasGet.dataSource.length;
        var hasNum:int = _playerData.heroList.list.length;
        var notNum:int = m_pViewUI.list_notGet.dataSource.length;
        var totalNum:int = ownAndEnoughNum + notNum;
        m_pViewUI.txt_hireInfo.text = "已招募：" + hasNum + "/" + totalNum;

        var manager:CTeachingInstanceManager = system.stage.getSystem( CTeachingInstanceSystem ).getHandler(CTeachingInstanceManager) as CTeachingInstanceManager;
        var bool:Boolean = manager.showRedPoint(1) || manager.showRedPoint(2);
        showTeachingRedPoint(bool);

        _updateCollectionAttr();
    }

    private function _renderItem(item:Component, idx:int) : void {
        if (!(item is HeroListRenderUI)) {
            return ;
        }
        var heroItem:HeroListRenderUI = item as HeroListRenderUI;
        var heroData:CPlayerHeroData = heroItem.dataSource as CPlayerHeroData;
        var isInRect:Boolean = _isItemInScrollRect(heroItem);
        if (isInRect) {
            _renderItemB(heroItem);
        }
        heroItem.btn_skillVideo.toolTip = '点击查看连招视频';
        heroItem.btn_skillVideo.clickHandler = new Handler( _onShowSkillVideo,[heroData] );
    }

    private function _renderItemB(heroItem:HeroListRenderUI) : void {
        var heroData:CPlayerHeroData = heroItem.dataSource as CPlayerHeroData;
        if (heroData == null) {
            return ;
        }
        if (heroData.prototypeID in _renderList) {
            return ;
        }
        var isHeroExist:Boolean = heroData != null && heroData.hasData;
        var playerName:String = heroData.heroNameWithColor;

        heroItem.img_hero_mask.cacheAsBitmap = true;
        heroItem.img_hero.mask = heroItem.img_hero_mask;
        heroItem.clip_intelligence.index = heroData.qualityBaseType;
        heroItem.clip_career.index = heroData.job;
        heroItem.clip_career.mouseEnabled = true;
        (system as CPlayerSystem).showCareerTips(heroItem.clip_career);
        heroItem.txt_heroName.isHtml = true;
        heroItem.img_chips.visible = false;
        heroItem.txt_chipsNum.visible = false;
        heroItem.img_dian.visible = false;
        heroItem.btn_getWay.visible = false;
        heroItem.clip_logo.visible = false;
        heroItem.clip_effect.visible = isHeroExist && heroData.qualityBase == EHeroIntelligence.SSS;
        heroItem.clip_effect.autoPlay = isHeroExist && heroData.qualityBase == EHeroIntelligence.SSS;
        if(heroItem.clip_effect && heroItem.clip_effect.visible)
        {
            heroItem.clip_effect.gotoAndPlay(1);
        }

//        heroItem.txt_intelligence.text = "资质" + heroData.qualityBase;

        heroItem.img_common_piece.visible = false;

        if(isHeroExist)
        {
            heroItem.img_hero.url = CPlayerPath.getPeakUIHeroFacePath(heroData.prototypeID);
            heroItem.txt_lvLabel.visible = true;
            heroItem.txt_lvLabel.y = 8-15;
            heroItem.txt_level.visible = true;
            heroItem.txt_level.y = 0-15;
            heroItem.list_star.visible = true;
            heroItem.list_star_null.visible = true;
            heroItem.list_star.centerX = 0;
            heroItem.list_star_null.centerX = 0;
            heroItem.box_progress.y = 146+8;
            heroItem.box_progress.visible = true;
            heroItem.btn_zhaomu.visible = false;
            heroItem.clip_logo.visible = _isInEmbattle(heroData.prototypeID);

            var progressValue:Number = 0;
            var piceData:CBagData = _bagManager.getBagItemByUid(heroData.pieceID);
            var currValue:int = piceData == null ? 0 : piceData.num;
            var totalValue:int = heroData.nextStarPieceCost;

            if(heroData.star >= CPlayerHeroData.MAX_STAR_LEVEL)//满星
            {
                progressValue = 1;
                heroItem.progress_chips.label = CLang.Get("highStarLv");
            }
            else
            {
                //更新显示万能碎片进度，并取得用于补足的万能碎片数量:
                var commonPieceCostNum:int = _updateCommonPiece(heroItem, heroData, currValue, totalValue);

                if(totalValue > 0)
                {
                    progressValue = currValue / totalValue;
                    heroItem.progress_chips.label = (currValue + commonPieceCostNum) + "/" + totalValue;
                }
                else
                {
                    progressValue = 1;
                    heroItem.progress_chips.label = currValue + "";
                }
            }

            heroItem.progress_chips.value = progressValue;
            heroItem.progress_chips.barLabel.y = -3;

            heroItem.img_dian.visible = _playerTipHandler.isHeroCanDevelop(heroData);

            heroItem.txt_level.text = heroData.level.toString();

            heroItem.txt_heroName.stroke = heroData.strokeColor;
            heroItem.txt_heroName.text = _playerHelper.getHeroWholeName(heroData);
            heroItem.box_name.centerX = 0;

            heroItem.list_star.dataSource = new Array(heroData.star);
        }
        else
        {
            heroItem.img_hero.url = CPlayerPath.getPeakUIHeroFacePath2(heroData.prototypeID);
            heroItem.txt_lvLabel.visible = false;
            heroItem.txt_lvLabel.y = 8;
            heroItem.txt_level.visible = false;
            heroItem.txt_level.y = 0;
            heroItem.list_star.visible = false;
            heroItem.list_star_null.visible = false;
            heroItem.box_progress.y = 166+8;

            heroItem.clip_bg.index = 5;
            heroItem.txt_heroName.text = playerName;
            heroItem.box_name.centerX = 0;

            heroItem.progress_chips.value = heroData.pieceRate;
            heroItem.progress_chips.label = CLang.Get("common_v1_v2", {v1:heroData.currentPieceCount, v2:heroData.hireNeedPieceCount});
            heroItem.progress_chips.barLabel.y = -3;

            // 当前碎片数量
            if (heroData.enoughToHire)
            {
                heroItem.btn_zhaomu.visible = true;
                heroItem.img_dian.visible = true;
                heroItem.box_progress.visible = false;
            }
            else
            {
                heroItem.btn_zhaomu.visible = false;
                heroItem.img_dian.visible = false;
                heroItem.box_progress.visible = true;

                heroItem.addEventListener(MouseEvent.ROLL_OVER,_onRollOverHandler);
                heroItem.addEventListener(MouseEvent.ROLL_OUT,_onRollOutHandler);
            }

            heroItem.img_dian.visible = _playerTipHandler.isHeroCanHire(heroData);

//            ObjectUtils.gray(heroItem.img_hero, true);
//            ObjectUtils.gray(heroItem.clip_bg, true);
        }

        heroItem.clip_bg.index = heroData.qualityBaseType; // _getIndexByIntelligence(heroData.qualityBase);
        heroItem.clip_bg2.index = heroData.qualityBaseType;

        var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem ) as CPlayerSystem;
        heroItem.clip_bg.toolTip = new Handler( playerSystem.showHeroTips, [heroData]);
    }

    //更新显示万能碎片进度，并取得用于补足的万能碎片数量
    private function _updateCommonPiece(heroItem:HeroListRenderUI, heroData:CPlayerHeroData, currValue:int, totalValue:int):int {
        //把万能碎片进度图片addChild到进度条里，防止盖住进度条文本:
        if (heroItem.img_common_piece.parent != heroItem.progress_chips) {
            heroItem.progress_chips.addChildAt(heroItem.img_common_piece, 2);
            heroItem.img_common_piece.x = 0;
            heroItem.img_common_piece.y = 0;
        }
        //万能碎片进度:
        var commonPieceCostNum:int = 0;
        var commonPieceBagData:CBagData = null;
        //如果碎片不足，算出使用万能碎片代替的数量：
        if (currValue < totalValue) {
            commonPieceBagData = _playerHelper.getCommomPieceBagData(heroData);
            var commonPieceOwnNum:int = commonPieceBagData == null ? 0 : commonPieceBagData.num;//当前拥有对应的万能碎片的数量
            commonPieceCostNum = Math.min(commonPieceOwnNum, Math.max(0, totalValue - currValue));//用于补足的万能碎片数量
        }
        //显示万能碎片进度条：
        if (commonPieceCostNum > 0) {
            heroItem.img_common_piece.visible = true;
            var progresWidth:int = heroItem.progress_chips.comXml.@width;
            heroItem.img_common_piece.width = progresWidth * (commonPieceCostNum/totalValue);
//            heroItem.img_common_piece.x = progresWidth * (currValue / totalValue);

            delayCall(0.1,function onDelay():void
            {
                if(heroItem.progress_chips.bar && heroItem.progress_chips.bar.scrollRect)
                {
                    heroItem.img_common_piece.x = heroItem.progress_chips.bar.scrollRect.width;
                }
                else
                {
                    heroItem.img_common_piece.x = progresWidth * (currValue / totalValue);
                }
            });

        }
        return commonPieceCostNum;
    }

    private function _onClickListHandler(evt:Event, idx:int) : void {
        if(evt.type == MouseEvent.CLICK) {
            var heroItem:HeroListRenderUI = evt.currentTarget as HeroListRenderUI;
            if (heroItem == null) return ;
            var heroData:CPlayerHeroData = heroItem.dataSource as CPlayerHeroData;
            var heroID:int = (heroItem.dataSource as CPlayerHeroData).prototypeID;

            switch (evt.target.name)
            {
                case "btn_zhaomu":
                    (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).heroNetHandler.sendHireHero(heroID);
                    break;
                case "clip_bg":
//                    if(heroData.hasData)
//                    {
                        var playerMainView:CPlayerMainViewHandler = system.getHandler(CPlayerMainViewHandler) as CPlayerMainViewHandler;
                        if(playerMainView.isViewShow)
                        {
                            system.dispatchEvent(new CPlayerEvent(CPlayerEvent.SWITCH_HERO, heroData));
                        }
                        else
                        {
                            playerMainView.showByPanelName("HeroDevelop", heroData);
                        }
//                    }
                    break;
                case "btn_getWay":
                    (system.stage.getSystem(CItemGetSystem) as CItemGetSystem).showItemGetPath(heroData.pieceID, null, heroData.hireNeedPieceCount);
                    break;
            }
        }
    }
    private function _onShowSkillVideo( ...args ):void{
        var heroData:CPlayerHeroData = args[0] as CPlayerHeroData;
        (_playerSystem.getBean( CSkillVideoViewHandler ) as CSkillVideoViewHandler ).addDisplay( heroData );

    }
    private function _onRollOverHandler(e:MouseEvent):void
    {
        var heroItem:HeroListRenderUI = e.target as HeroListRenderUI;
        if(heroItem)
        {
            if(heroItem.btn_zhaomu.visible)
            {
                return;
            }

            heroItem.btn_getWay.visible = true;
        }
    }

    private function _onRollOutHandler(e:MouseEvent):void
    {
        var heroItem:HeroListRenderUI = e.target as HeroListRenderUI;
        if(heroItem)
        {
            if(heroItem.btn_zhaomu.visible)
            {
                return;
            }

            heroItem.btn_getWay.visible = false;
        }
    }

    private function _onResize(e:Event) : void {

        m_pViewUI.box_notGet.y = m_pViewUI.box_hasGet.y + m_pViewUI.box_hasGet.displayHeight + 20-14;
//        m_pViewUI.box_notGet.visible = m_pViewUI.list_notGet.cells.length != 0;
    }

    // 数据更新之后, set dataSource, 然后refreshPanel, dataSource执行是delayCall, 而refreshPanel是马上执行, 导致scrollChange使用了错误的数据
    private var _lastScrollValue:int;
    private function _onScrollChange(value:int) : void {
        if (_lastScrollValue == value) {
            return ;
        }
        _lastScrollValue = value;
        var lockCells:Vector.<Box> = m_pViewUI.list_notGet.cells;
        var unLockCells:Vector.<Box> = m_pViewUI.list_hasGet.cells;
        var allList:Vector.<Box> = lockCells.concat(unLockCells);
        var cell:HeroListRenderUI;
        var isInRect:Boolean;
        var isItemHasRender:Boolean;
        for each (cell in allList) {
            if (cell && cell.dataSource) {
                isInRect = _isItemInScrollRect(cell);
                if (isInRect) {
                    var heroData:CPlayerHeroData = cell.dataSource as CPlayerHeroData;
                    if (heroData) {
                        isItemHasRender = heroData.prototypeID in _renderList;
                        if (!isItemHasRender) {
                            _renderItemB(cell);
                        }
                    }
                }
            }
        }
    }

    private var _tempItemPos:Point = new Point();
    private var _tempItemRect:Rectangle = new Rectangle();
    private function _isItemInScrollRect(cell:HeroListRenderUI) : Boolean {
        var heroBox:Box = m_pViewUI.hero_box;
        if (heroBox == null) {
            return false;
        }
        _tempItemPos.x = cell.x;
        _tempItemPos.y = cell.y;
        var pos:Point = _tempItemPos;
        pos = cell.parent.localToGlobal(pos);
        pos = heroBox.globalToLocal(pos);
        var rect:Rectangle = _tempItemRect;
        rect.x = pos.x;
        rect.y = pos.y;
        rect.width = cell.width;
        rect.height = cell.height;

        if (m_pViewUI.panel.content.scrollRect && m_pViewUI.panel.content.scrollRect.intersects(rect)) {
            return true;
        }
        return false;
    }

    private var _rectPanel:Rectangle;
    private var _renderList:Object;

    private function _onGotoHireHandler():void
    {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.CARDPLAYER));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    private function _onOpenShopHandler():void
    {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.MALL));
        bundleCtx.setUserData(systemBundle, "shop_type", [EShopType.SHOP_TYPE_3]);
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    private function _onOpenImpressionSystem():void
    {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.IMPRESSION));
        var currState:Boolean = bundleCtx.getUserData(systemBundle, CBundleSystem.ACTIVATED);
        if(!currState)
        {
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
        }
    }

    private function _onOpenTeaching():void{
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.TEACHING));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    /**
     * 小红点提示
     * @param e
     */
    private function _onUpdateTipInfoHandler(e:Event):void
    {
        _updateTipState();
    }

    private function _updateTipState():void
    {
        var len:int = m_pViewUI.list_hasGet.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var render:HeroListRenderUI = m_pViewUI.list_hasGet.cells[i] as HeroListRenderUI;
            var data:CPlayerHeroData = render == null ? null : (render.dataSource as CPlayerHeroData);
            if(render && data)
            {
                if(data.hasData)
                {
                    render.img_dian.visible = _playerTipHandler.isHeroCanDevelop(data);
                }
                else
                {
                    render.img_dian.visible = _playerTipHandler.isHeroCanHire(data);
                }
            }
        }

        var manager:CTeachingInstanceManager = system.stage.getSystem( CTeachingInstanceSystem ).getHandler(CTeachingInstanceManager) as CTeachingInstanceManager;
        var bool:Boolean = manager.showRedPoint(1) || manager.showRedPoint(2);
        showTeachingRedPoint(bool);
    }

    private function _onHeroInfoUpdateHandler(e:CPlayerEvent):void
    {
        var len:int = m_pViewUI.list_hasGet.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var render:HeroListRenderUI = m_pViewUI.list_hasGet.cells[i] as HeroListRenderUI;
            var heroData:CPlayerHeroData = render == null ? null : (render.dataSource as CPlayerHeroData);
            if(render && heroData)
            {
                render.txt_level.text = heroData.level.toString();
                render.txt_heroName.stroke = heroData.strokeColor;
                render.txt_heroName.text = _playerHelper.getHeroWholeName(heroData);
                render.box_name.centerX = 0;
                render.list_star.dataSource = new Array(heroData.star);
            }
        }
    }

    private function _onBagItemUpdateHandler(e:CBagEvent):void
    {
        _updateTipState();
        _updateChipsInfo();
    }

    private function _updateChipsInfo():void
    {
        var len:int = m_pViewUI.list_hasGet.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var render : HeroListRenderUI = m_pViewUI.list_hasGet.cells[ i ] as HeroListRenderUI;
            render.img_common_piece.visible = false;
            var heroData : CPlayerHeroData = render == null ? null : (render.dataSource as CPlayerHeroData);
            if ( render && heroData )
            {
                var progressValue : Number = 0;
                var piceData : CBagData = _bagManager.getBagItemByUid( heroData.pieceID );
                var currValue : int = piceData == null ? 0 : piceData.num;
                var totalValue : int = heroData.nextStarPieceCost;

                if(heroData.star >= CPlayerHeroData.MAX_STAR_LEVEL)//满星
                {
                    progressValue = 1;
                    render.progress_chips.label = CLang.Get("highStarLv");
                }
                else
                {
                    if (totalValue > 0)
                    {
                        //更新显示万能碎片进度，并取得用于补足的万能碎片数量:
                        var commonPieceCostNum:int = _updateCommonPiece(render, heroData, currValue, totalValue);

                        progressValue = currValue / totalValue;
                        render.progress_chips.label = (currValue + commonPieceCostNum) + "/" + totalValue;
                    }
                    else
                    {
                        progressValue = 1;
                        render.progress_chips.label = currValue + "";
                    }
                }

                render.progress_chips.value = progressValue;
            }
        }
    }

    private function _onHeroAddHandler(e:CPlayerEvent):void
    {
        invalidateDisplay();
    }

    private function _onCloseHandler(type:String = null):void
    {
        if(closeHandler)
        {
            closeHandler.execute();
        }
    }

    public function set scrollEnable(value:Boolean):void
    {
        m_bScrollEnable = value;

        if(m_bViewInitialized)
        {
            _updateScrollState();
        }
    }

    private function _updateScrollState():void
    {
        if(m_bScrollEnable)
        {
            m_pViewUI.panel.vScrollBar.mouseEnabled = true;
            m_pViewUI.panel.vScrollBar.mouseChildren = true;
            m_pViewUI.panel.vScrollBar.target = m_pViewUI.panel;
        }
        else
        {
            m_pViewUI.panel.vScrollBar.mouseEnabled = false;
            m_pViewUI.panel.vScrollBar.mouseChildren = false;
            m_pViewUI.panel.vScrollBar.target = null;
        }
    }

    /**
     * 获取出战格斗家列表，按战力降序排列
     * @return
     */
    private function _getEmbattleHeroList() : Array
    {
        var resultArr : Array = [];

        var playerManager : CPlayerManager = system.getHandler(CPlayerManager) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;

        var instanceType : int = EInstanceType.TYPE_MAIN;
        var embattleListData : CEmbattleListData = playerData.embattleManager.getByType( instanceType );
        if ( embattleListData && embattleListData.list && embattleListData.list.length > 0 ) {
            var len:int = embattleListData.list.length;
            for ( var i : int = 0; i < len; i++ ) {
                var embattleData : CEmbattleData = embattleListData.list[i] as CEmbattleData;
                if ( embattleData ) {
                    var heroID : int = embattleData.prosession;
                    resultArr.push(heroID)
                }
            }
        }

        return resultArr;
    }

    public function showTeachingRedPoint(bool:Boolean):void
    {
        var isSystemOpen:Boolean = ((system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).getHandler(CSwitchingHandler)
            as CSwitchingHandler).isSystemOpen(KOFSysTags.TEACHING);

        if(m_pViewUI)
        {
            m_pViewUI.teachingRed.visible = isSystemOpen && bool;
        }
    }

    private function _isInEmbattle(heroId:int):Boolean
    {
        if(m_listEmbattleId == null)
        {
            m_listEmbattleId = _getEmbattleHeroList();
        }

        return m_listEmbattleId.indexOf(heroId) != -1;
    }

    /**
     * 格斗家收集属性
     */
    private function _updateCollectionAttr():void
    {
        var manager:CImpressionManager = (system.stage.getSystem(CImpressionSystem) as CImpressionSystem).getBean(CImpressionManager);
        var attrData:CBasePropertyData = manager.getTotalCollectAttr();
        if(attrData)
        {
            for(var i:int = 0; i < CImpressionUtil.Attrs.length; i++)
            {
                var attrName:String = CImpressionUtil.Attrs[i];
                if(attrData.hasOwnProperty(attrName))
                {
                    var attrValue:Number = attrData[attrName] * 0.01;
                    var numberStr:String = attrValue % 1 == 0 ? attrValue.toString() : attrValue.toFixed(2);
                    m_attrLabelArr[i ].text = numberStr + "%";
                }
            }
        }
    }

    private function _onClickLinkHandler():void
    {
        var collectView:CCollectAttrDescViewHandler = system.getHandler(CCollectAttrDescViewHandler) as CCollectAttrDescViewHandler;
        if(collectView)
        {
            collectView.addDisplay();
        }
    }

// property=============================================================================================================
    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    public function set tweenShowEndHandler(value:Handler):void
    {
        m_pTweenShowEndHandler = value;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _playerData() : CPlayerData
    {
        return (system.stage.getSystem(CPlayerSystem ) as CPlayerSystem).playerData;
    }

    private function get _playerHelper():CPlayerHelpHandler
    {
        return  system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }

    private function get _playerTipHandler():CPlayerTipHandler
    {
        return system.getHandler(CPlayerTipHandler) as CPlayerTipHandler;
    }

    private function get _bagManager():CBagManager
    {
        return system.stage.getSystem(CBagSystem ).getHandler(CBagManager) as CBagManager;
    }
    private function get _playerSystem() : CPlayerSystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

    override public function dispose():void
    {
        super.dispose();
    }

}
}
