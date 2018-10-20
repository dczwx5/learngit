//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/10.
 */
package kof.game.loading {

import com.greensock.TweenMax;
import com.greensock.plugins.FramePlugin;
import com.greensock.plugins.TweenPlugin;

import flash.display.Shape;
import flash.events.Event;
import flash.utils.getTimer;

import kof.framework.CAppSystem;

import kof.framework.CViewHandler;
import kof.game.common.loading.CLoadingEvent;
import kof.game.common.preLoad.CPreload;
import kof.data.CPreloadData;
import kof.game.common.preLoad.CPreloadEvent;
import kof.game.common.preLoad.EPreloadType;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.Loading.MultiplePVPLoadingViewUI;
import kof.ui.Loading.PVPLoadingHeroUI;

public class CMultiplePVPLoadingViewHandler extends CViewHandler {
    private var m_pUI : MultiplePVPLoadingViewUI;
    private var m_bShowing : Boolean;
    private var m_pMask : Shape;
    private var m_pData:CPVPLoadingData;
    private var m_bIsNeedPreload:Boolean;

    public function CMultiplePVPLoadingViewHandler()
    {
        super( false ); // load view by default to call onInitializeView
    }

    override public function dispose() : void
    {
        _removeDisplay();
        super.dispose();

        m_pUI = null;
        m_pMask = null;
        m_pData = null;
    }

    override public function get viewClass() : Array
    {
        return [ MultiplePVPLoadingViewUI ];
    }

    override protected function get additionalAssets():Array
    {
        return ["pvpLoading.swf"];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if (!super.onInitializeView())
        {
            return false;
        }

        m_pUI = m_pUI || new MultiplePVPLoadingViewUI();
        m_pMask = m_pMask || new Shape();
        return Boolean( m_pUI );
    }

    override protected function onShutdown() : Boolean
    {
        var ret : Boolean = super.onShutdown();

        if ( ret )
        {
            this._removeDisplay();
        }

        return ret;
    }

    override protected function updateData() : void
    {
        super.updateData();
    }

    override protected function updateDisplay() : void
    {
        super.updateDisplay();

        if ( !m_pUI ) {
            invalidateDisplay();
            return;
        }

        if ( m_pUI.parent && !m_bShowing ) {
            this._removeDisplay();
        } else if ( !m_pUI.parent && m_bShowing ) {
            this._addDisplay();
        }

        _updateSchedule();
    }

    public function show(isNeedPreload:Boolean = false) : void
    {
        m_bIsNeedPreload = isNeedPreload;
        m_bShowing = true;
//        invalidateDisplay();

        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            invalidate();
//            callLater( _addDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addDisplay() : void {
        var pUISystem : CUISystem = system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISystem ) {
            pUISystem.loadingLayer.addChildAt( m_pMask, 0 );
            pUISystem.loadingLayer.addChild( m_pUI );
            system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
            _onStageResize();

            var sceneLoadingView:CSceneLoadingViewHandler = system.stage.getSystem(IUICanvas ).getHandler(CSceneLoadingViewHandler)
                    as CSceneLoadingViewHandler;
            if(sceneLoadingView.isViewShow)
            {
                sceneLoadingView.isShow = false;
            }

            sceneLoadingView.forceHide = true;

            // preload
            if (_preload) {
                _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);
                _preload.dispose();
                _preload = null;
            }

            _isPreloadFinish = false;

            _startTime = getTimer();
            schedule( 1 / 60, _onTick);
            _targetRate = 90;
            _virtualLoadingRate = 0;
            redrawMask();
            _updateView();
            if(m_bIsNeedPreload)
            {
                _processPreload();
            }
            else
            {
                _onFinishProgress(null);
            }
        }
    }

    private function _processPreload() : void {
        if(m_pData) {
            _preload = new CPreload((uiCanvas as CAppSystem).stage);
            _preload.addEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);
            var preloadDataList:Vector.<CPreloadData> = new Vector.<CPreloadData>();
            _addPreloadData(preloadDataList, m_pData.selfHeroIdList);
            _addPreloadData(preloadDataList, m_pData.enemyHeroIdList);
            _preload.load(preloadDataList);
        } else {
            _onFinishProgress(null);
        }
    }
    private function _onFinishProgress(e:CPreloadEvent) : void {
        _isPreloadFinish = true;

        system.dispatchEvent(new CLoadingEvent(CLoadingEvent.VIRTUAL_LOAD_FINISHED));
    }
    private function _addPreloadData (saveList:Vector.<CPreloadData>, heroIDList:Array) : void {
        var isExist:Function = function (list:Vector.<CPreloadData>, preloadData:CPreloadData) : Boolean {
            for each (var listItem:CPreloadData in list) {
                if (listItem.resType == preloadData.resType && preloadData.id == listItem.id) {
                    return true;
                }
            }
            return false;
        };

        var preloadData:CPreloadData;
        for each (var heroID:int in heroIDList) {
            preloadData = new CPreloadData();
            preloadData.resType = EPreloadType.RES_TYPE_HERO;
            preloadData.id = heroID.toString();
            if (false == isExist(saveList, preloadData)) {
                saveList[saveList.length] = preloadData;
            }
        }
    }

    private function _updateView():void
    {
        clear();

        if(m_pData) {
            var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;

            // 己方==================================================================================
            var heroData1:CPlayerHeroData = playerData.heroList.getHero(m_pData.selfHeadInfo.heroId);
            // 头像部分
            m_pUI.view_self.item_head.clip_career.index = heroData1.job;
            (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showCareerTips(m_pUI.view_self.item_head.clip_career);
            m_pUI.view_self.item_head.clip_intell.index = heroData1.qualityBaseType;
            m_pUI.view_self.item_head.quality_clip.index = heroData1.qualityLevelValue;
            m_pUI.view_self.item_head.icon_image.mask = m_pUI.view_self.item_head.hero_icon_mask;
            m_pUI.view_self.item_head.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(m_pData.selfHeadInfo.heroId);
            m_pUI.view_self.visible = m_pData.selfHeadInfo.isShowHeadInfo;

            // 星级
            m_pUI.view_self.item_head.star_list.dataSource = new Array(m_pData.selfHeadInfo.star);

            // 头像右边的信息
            m_pUI.view_self.txt_roleName.text = m_pData.selfHeadInfo.roleName;
            m_pUI.view_self.txt_infoLabel1.text = m_pData.selfHeadInfo.infoLabel1;
            m_pUI.view_self.txt_infoValue1.text = m_pData.selfHeadInfo.infoValue1 as String;
            m_pUI.view_self.txt_infoLabel2.text = m_pData.selfHeadInfo.infoLabel2;
            m_pUI.view_self.txt_infoValue2.text = m_pData.selfHeadInfo.infoValue2 as String;

            // 格斗家列表
            for (var i:int = 0; i < m_pData.selfHeroIdList.length; i++) {
                var heroInfo1:PVPLoadingHeroUI = m_pUI["view_self_hero" + i];
                var heroData:CPlayerHeroData = playerData.heroList.getHero(m_pData.selfHeroIdList[i]);
                heroInfo1.img_mask.cacheAsBitmap = true;
                heroInfo1.img_mask.visible = true;
                heroInfo1.img_hero.mask = heroInfo1.img_mask;
                heroInfo1.img_hero.url = CPlayerPath.getPeakUIHeroFacePath(m_pData.selfHeroIdList[i]);
                heroInfo1.clip_intelligence.visible = true;

                heroInfo1.clip_intelligence.index = heroData.qualityBaseType;
                heroInfo1.txt_heroName_self.isHtml = true;
                heroInfo1.txt_heroName_self.text = heroData.heroNameWithColor;
                heroInfo1.box_enemy.visible = false;
            }


            // 敌方===================================================================================
            var heroData2:CPlayerHeroData = playerData.heroList.createHero(m_pData.enemyHeadInfo.heroId);
            heroData2.star = m_pData.enemyHeadInfo.star;
            heroData2.quality = m_pData.enemyHeadInfo.quality;

            // 头像部分
            m_pUI.view_enemy.item_head.clip_career.index = heroData2.job;
            (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showCareerTips(m_pUI.view_enemy.item_head.clip_career);
            m_pUI.view_enemy.item_head.clip_intell.index = heroData2.qualityBaseType;
            m_pUI.view_enemy.item_head.quality_clip.index = heroData2.qualityLevelValue;
            m_pUI.view_enemy.item_head.icon_image.mask = m_pUI.view_enemy.item_head.hero_icon_mask;
            m_pUI.view_enemy.item_head.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(m_pData.enemyHeadInfo.heroId);
            m_pUI.view_enemy.visible = m_pData.enemyHeadInfo.isShowHeadInfo;

            // 星级
            m_pUI.view_enemy.item_head.star_list.dataSource = new Array(heroData2.star);

            // 头像右边的信息
            m_pUI.view_enemy.txt_roleName.text = m_pData.enemyHeadInfo.roleName;
            m_pUI.view_enemy.txt_infoLabel1.text = m_pData.enemyHeadInfo.infoLabel1;
            m_pUI.view_enemy.txt_infoValue1.text = m_pData.enemyHeadInfo.infoValue1 as String;
            m_pUI.view_enemy.txt_infoLabel2.text = m_pData.enemyHeadInfo.infoLabel2;
            m_pUI.view_enemy.txt_infoValue2.text = m_pData.enemyHeadInfo.infoValue2 as String;

            // 格斗家列表
            for (i = 0; i < m_pData.enemyHeroIdList.length; i++) {
                var heroInfo2:PVPLoadingHeroUI = m_pUI["view_enemy_hero" + i];
                heroData = playerData.heroList.createHero(m_pData.enemyHeroIdList[i]);
                heroData.quality = m_pData.enemyQualityList == null ? m_pData.enemyHeadInfo.quality : m_pData.enemyQualityList[i];
                heroInfo2 = m_pUI["view_enemy_hero" + i];
                heroInfo2.img_mask.cacheAsBitmap = true;
                heroInfo2.img_mask.visible = true;
                heroInfo2.img_hero.mask = heroInfo2.img_mask;
                heroInfo2.img_hero.url = CPlayerPath.getPeakUIHeroFacePath(m_pData.enemyHeroIdList[i]);
                heroInfo2.clip_intelligence.visible = true;
                heroInfo2.clip_intelligence.index = heroData.qualityBaseType;
                heroInfo2.txt_heroName_enemy.isHtml = true;
                heroInfo2.txt_heroName_enemy.text = heroData.heroNameWithColor;
                heroInfo2.box_self.visible = false;
            }
        }
    }

    private function _animation():void
    {
        TweenPlugin.activate([FramePlugin]);
        TweenMax.fromTo(m_pUI.view_self_hero0,0.3,{x:0},{x:217,delay:0.1});
        TweenMax.fromTo(m_pUI.view_self_hero1,0.3,{x:0},{x:379,delay:0.05});
        TweenMax.fromTo(m_pUI.view_self_hero2,0.3,{x:0},{x:541});

        TweenMax.fromTo(m_pUI.view_enemy_hero0,0.3,{x:1600},{x:757});
        TweenMax.fromTo(m_pUI.view_enemy_hero1,0.3,{x:1600},{x:918,delay:0.05});
        TweenMax.fromTo(m_pUI.view_enemy_hero2,0.3,{x:1600},{x:1079,delay:0.1});
    }

    public function set data(value:CPVPLoadingData):void
    {
        m_pData = value;
    }

    public function clear():void
    {
        if(onInitializeView())
        {
            m_pUI.view_self.item_head.clip_career.index = 0;
            m_pUI.view_self.item_head.clip_intell.index = 0;
            m_pUI.view_self.item_head.quality_clip.index = 0;
            m_pUI.view_self.item_head.icon_image.url = "";
            m_pUI.view_self.item_head.star_list.dataSource = [];
            m_pUI.view_self.txt_roleName.text = "";
            m_pUI.view_self.txt_infoLabel1.text = "";
            m_pUI.view_self.txt_infoValue1.text = "";
            m_pUI.view_self.txt_infoLabel2.text = "";
            m_pUI.view_self.txt_infoValue2.text = "";
            for (var i:int = 0; i < 3; i++)
            {
                var heroInfo1:PVPLoadingHeroUI = m_pUI["view_self_hero"+i];
                heroInfo1.img_mask.visible = false;
                heroInfo1.img_hero.url = "";
                heroInfo1.clip_intelligence.visible = false;
                heroInfo1.txt_heroName_self.text = "";
                heroInfo1.box_enemy.visible = false;
            }

            m_pUI.view_enemy.item_head.clip_career.index = 0;
            m_pUI.view_enemy.item_head.clip_intell.index = 0;
            m_pUI.view_enemy.item_head.quality_clip.index = 0;
            m_pUI.view_enemy.item_head.icon_image.url = "";
            m_pUI.view_enemy.item_head.star_list.dataSource = [];
            m_pUI.view_enemy.txt_roleName.text = "";
            m_pUI.view_enemy.txt_infoLabel1.text = "";
            m_pUI.view_enemy.txt_infoValue1.text = "";
            m_pUI.view_enemy.txt_infoLabel2.text = "";
            m_pUI.view_enemy.txt_infoValue2.text = "";
            for (i = 0; i < 3; i++)
            {
                var heroInfo2:PVPLoadingHeroUI = m_pUI["view_enemy_hero"+i];
                heroInfo2.img_mask.visible = false;
                heroInfo2.img_hero.url = "";
                heroInfo2.clip_intelligence.visible = false;
                heroInfo2.txt_heroName_enemy.text = "";
                heroInfo2.box_self.visible = false;
            }
        }
    }

    private function _onTick(delta:Number) : void {
        var curTime:int = getTimer();
        var duringTime:int = curTime - _startTime;

        if ( m_bShowing || !_isPreloadFinish) {
            var p : Number = duringTime / ( 50000 );
            p = Math.min( p, 1 );
            p = Math.sqrt( 1 - ( p = p - 1 ) * p );

            var fRatioTotal : Number = p * 0.9999;
            if ( fRatioTotal > 0.9999 )
                fRatioTotal = 0.9999;

            _virtualLoadingRate = fRatioTotal;
        } else {
            _virtualLoadingRate += delta * 0.35;
            if (_virtualLoadingRate < 0.90) {
                _virtualLoadingRate = 0.90;
            }
        }

        // 大于20秒, 显示90%-99%
//        if (duringTime > 20000 && _targetRate < 100) {
//            _targetRate = 99;
//        }
//
//        var addValue:Number = 0.0;
//        var onePercentCostTime:Number = 0;
//        if (_targetRate < 99) {
//            // 第一阶段 1%~90% 20s
//            if (_virtualLoadingRate < 0.90) {
//                onePercentCostTime = 20/89;
//                addValue = delta / onePercentCostTime * 0.01;
//                _virtualLoadingRate += addValue;
//                if (_virtualLoadingRate > 0.90) {
//                    _virtualLoadingRate = 0.9;
//                }
//            }
//        } else if (_targetRate < 100) {
//            // 第二阶段 90%~99% 60s
//            if (_virtualLoadingRate < 1) {
//                onePercentCostTime = 60/9;
//                addValue = delta / onePercentCostTime * 0.01;
//                _virtualLoadingRate += addValue;
//                if (_virtualLoadingRate > 0.99) {
//                    _virtualLoadingRate = 0.99;
//                }
//            }
//
//        } else {
//            // 第三阶段 100%
//            _virtualLoadingRate += 0.05;
//            if (_virtualLoadingRate < 0.90) {
//                _virtualLoadingRate = 0.90;
//            }
//        }
        if (_targetRate >= 100) {

        }

        _updateSchedule();

        if (m_bShowing == false && _virtualLoadingRate >= 1.1) {
            unschedule(_onTick);
            _removeB();
        }
    }
//
//    // ran : 0 ~ 0.005 即1%
//    // +0.005 , 即结果为0.5%~1.5%
//    private function _randomAddRate() : Number {
//        return (Math.random() * 100 / 10000 + 0.0005);
//    }
    private function _updateSchedule() : void {
        var value:int = (int)(100*_virtualLoadingRate); // 1%是第1帧, index = 0
        value--;
        if (value < 0)
        {
            value = 0;
        }

        if (value > 99)
        {
            value = 99;
        }

        m_pUI.progress_bar.value = value * 0.01;
        m_pUI.progress_bar.label = value + "%";
    }

    private function _onStageResize( event : Event = null ) : void {
        this.redrawMask();

        var stageWidth:int = system.stage.flashStage.stageWidth;
        var stageHeight:int = system.stage.flashStage.stageHeight;

        m_pUI.x = stageWidth - m_pUI.width >> 1;
        m_pUI.y = stageHeight - m_pUI.height >> 1;

//        if(m_pUI.x < 0)
//        {
//            m_pUI.x = 0;
//        }
//
//        if(m_pUI.y < 0)
//        {
//            m_pUI.y = 0;
//        }
    }

    private function redrawMask() : void {
        if ( !m_pMask )
            return;
        m_pMask.graphics.clear();
        m_pMask.graphics.beginFill( 0x0 );
        m_pMask.graphics.drawRect( 0, 0, system.stage.flashStage.stageWidth, system.stage.flashStage.stageHeight );
        m_pMask.graphics.endFill();
    }

    public function remove() : void {
        if ( m_bShowing == false ) return;

        m_bShowing = false;
        _targetRate = 100;
    }

    private function _removeB() : void {
        invalidateDisplay();
    }

    private function _removeDisplay() : void {
        if ( m_pUI && m_pUI.parent )
            m_pUI.parent.removeChild( m_pUI );
        if ( m_pMask && m_pMask.parent )
            m_pMask.parent.removeChild( m_pMask );
        unschedule(_onTick);

        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
    }

//    public function get targetRate():Number {
//        return _targetRate;
//    }
//    public function set targetRate(value:Number):void {
//        if (value > _targetRate) {
//            _targetRate = value;
//        }
//    }
    private var _virtualLoadingRate:Number;
    private var _targetRate:Number;

    private var _startTime:int;

    public function get isViewShow():Boolean
    {
        return m_pUI && m_pUI.parent;
    }

    public function set isShow(value:Boolean):void
    {
        if(m_pUI)
        {
            m_pUI.visible = value;
        }
    }

    private var _preload:CPreload;
    private var _isPreloadFinish:Boolean;
}
}
