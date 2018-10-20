//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/25.
 */
package kof.game.impression.view {

import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Point;
import flash.utils.Timer;

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.common.hero.CHeroListView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.common.view.event.CViewEvent;
import kof.game.impression.CImpressionManager;
import kof.game.impression.data.CPlayerInfoData;
import kof.game.impression.util.CImpressionState;
import kof.game.impression.util.CImpressionUtil;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.table.Impression;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.imp_common.HeroListHUI;
import kof.ui.master.impression.ImpressionDisplayUI;
import kof.ui.master.impression.ImpressionUpgradeUI;

import morn.core.components.Dialog;

import morn.core.components.Label;

import morn.core.handlers.Handler;

/**
 * 亲密度培养部分
 */
public class CImpressionDisplayViewHandler extends CViewHandler {

    private var m_pViewUI : ImpressionDisplayUI;
    private var m_bViewInitialized : Boolean;
    private var m_pUpgradeView:CImpressionUpgradeView;// 子view
    private var m_iCurrPage:int;
    private var m_iLastSelIndex:int = -1;
    private var m_bIsDefaultSel:Boolean;
    protected var m_pMask:Shape;

    private var m_heroListExternal:CViewExternalUtil;

    public function CImpressionDisplayViewHandler()
    {
        super(false);
    }

    override public function get viewClass() : Array
    {
        return [ImpressionDisplayUI, ImpressionUpgradeUI, HeroListHUI];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_role.swf", "frameclip_impression2.swf"];
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
                m_pViewUI = new ImpressionDisplayUI();
                m_pViewUI.list_hero.hero_left_btn.visible = false;
                m_pViewUI.list_hero.hero_right_btn.visible = false;
                m_pViewUI.img_hero.mask = m_pViewUI.img_mask;

                if (3 != m_pViewUI.list_hero.hero_list.repeatX)
                {
                    m_pViewUI.list_hero.hero_list.repeatX = 3;
                }

                m_heroListExternal = new CViewExternalUtil(CHeroListView, this, m_pViewUI);
                (m_heroListExternal.view as CHeroListView).ui = m_pViewUI.list_hero;
                (m_heroListExternal.view as CHeroListView).isShowQuality = false;
                m_heroListExternal.show();
//                m_heroListExternal.view.addEventListener(CViewEvent.UI_EVENT, _listSelectHandler);
                m_pViewUI.closeHandler = new Handler( _onClose );

                m_pUpgradeView = new CImpressionUpgradeView();
                m_pUpgradeView.system = system;
                m_pUpgradeView.viewUI = m_pViewUI.view_upgrade;
                m_pUpgradeView.initialize();

                m_pMask = m_pMask || new Shape();
                m_pMask.alpha = 0.5;

//                m_pTimer = new Timer(2000);

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
            invalidate();
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

            m_pUpgradeView.show();
        }

        var pUISystem : CUISystem = system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISystem )
        {
            m_pViewUI.addChildAt( m_pMask, 0 );
        }
//        uiCanvas.addPopupDialog( m_pViewUI );
        uiCanvas.addDialog(m_pViewUI);

        _onStageResize();
    }

    public function removeDisplay() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            if(m_pViewUI)
            {
                m_pViewUI.list_hero.hero_list.selectedIndex = -1;
                m_pViewUI.list_hero.hero_list.dataSource = [];
            }

            if ( m_pViewUI && m_pViewUI.parent)
            {
//            m_pViewUI.close();
//                App.dialog.close(m_pViewUI);
                m_pViewUI.close( Dialog.CLOSE );
            }

            if(m_pMask && m_pMask.parent)
            {
                m_pMask.parent.removeChild(m_pMask);
            }

//            if(m_pTimer)
//            {
//                m_pTimer.stop();
//                m_pTimer.reset();
//            }

            m_iLastSelIndex = -1;

            m_bIsDefaultSel = false;

            m_pUpgradeView.hide();

            CImpressionState.rest();
        }
    }

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                removeDisplay();
                break;
        }
    }

    private function _addListeners():void
    {
        m_pViewUI.btn_left.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_right.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
//        m_pViewUI.box_talk.addEventListener(MouseEvent.CLICK, _onBoxClickHandler);

//        m_pTimer.addEventListener(TimerEvent.TIMER,_onTimerHandler);

        system.stage.getSystem(CPlayerSystem ).addEventListener(CPlayerEvent.HERO_DATA,_onPlayerInfoUpdateHandler);
        system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
    }

    private function _removeListeners():void
    {
        m_pViewUI.btn_left.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_right.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
//        m_pViewUI.box_talk.removeEventListener(MouseEvent.CLICK, _onBoxClickHandler);

//        m_pTimer.removeEventListener(TimerEvent.TIMER,_onTimerHandler);
        m_heroListExternal.view.removeEventListener(CViewEvent.UI_EVENT, _listSelectHandler);

        system.stage.getSystem(CPlayerSystem ).removeEventListener(CPlayerEvent.HERO_DATA,_onPlayerInfoUpdateHandler);
        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
    }

    private function _onStageResize( event:Event = null ) : void
    {
        this.redrawMask();

        var stageWidth:int = system.stage.flashStage.stageWidth;
        var stageHeight:int = system.stage.flashStage.stageHeight;

        m_pViewUI.x = stageWidth - m_pViewUI.width >> 1;
        m_pViewUI.y = stageHeight - m_pViewUI.height >> 1;

        var localPoint:Point = m_pViewUI.globalToLocal(new Point(0, 0));
        m_pMask.x = localPoint.x;
        m_pMask.y = localPoint.y;
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

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _clear();

            _updateBg();
            _initRoleList();
            _updatePageBtnState();
        }
    }

    private function _updateBg():void
    {
//        m_pViewUI.img_bg.width = system.stage.flashStage.stageWidth;
//        m_pViewUI.img_bg.height = system.stage.flashStage.stageHeight;
//
//        m_pViewUI.img_bg.x = 1000 - m_pViewUI.img_bg.width >> 1;
//        m_pViewUI.img_bg.y = 600 - m_pViewUI.img_bg.height >> 1;
    }

    private function _initRoleList():void
    {
        var selHeroData:CPlayerInfoData = system.getBean(CImpressionViewHandler ).selData as CPlayerInfoData;
        if(selHeroData)
        {
            var tImpression:Impression = CImpressionUtil.getImpressionConfig(selHeroData.roleId);
            if(tImpression)
            {
                // 初始化格斗家列表
                var manager:CImpressionManager = system.getBean(CImpressionManager);
//                var heroArr:Array = manager.getCanTrainHeroData();
                var heroArr:Array = manager.getGroupHeroList(tImpression.groupId);

                var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                var heroListData:Array = new Array(heroArr.length);
                for (var index:int = 0; index < heroArr.length; index++)
                {
                    heroListData[index] = playerSystem.playerData.heroList.getHero((heroArr[index] as CPlayerInfoData).roleId);
                }
                m_bIsDefaultSel = true;
                m_heroListExternal.setData(heroListData);
                m_heroListExternal.updateWindow();

                m_pViewUI.list_hero.hero_list.totalPage = Math.ceil(heroArr.length/3);
                m_pViewUI.list_hero.hero_list.selectedIndex = -1;

                m_heroListExternal.view.addEventListener(CViewEvent.UI_EVENT, _listSelectHandler);
                // 默认选中格斗家
                for(var i:int = 0; i < heroArr.length; i++)
                {
                    if(selHeroData.roleId == heroArr[i ].roleId)
                    {
                        var page:int = i/m_pViewUI.list_hero.hero_list.repeatX;
                        m_pViewUI.list_hero.hero_list.page = page;
                        m_pViewUI.list_hero.hero_list.selectedIndex = i;
                        break;
                    }
                }
            }
        }
    }

    private function _listSelectHandler(e:CViewEvent):void
    {
        var heroData:CPlayerHeroData = e.data as CPlayerHeroData;
        if(heroData == null)
        {
            return;
        }

        if(!CImpressionUtil.isHeroOpened(heroData.prototypeID))
        {
            if(m_bIsDefaultSel)
            {
                m_bIsDefaultSel = false;
                return;
            }

            uiCanvas.showMsgAlert( CLang.Get("impression_hero_notOpen"), CMsgAlertHandler.WARNING );
            m_pViewUI.list_hero.hero_list.selectedIndex = m_iLastSelIndex;
            return;
        }

        // 第一次培养需要显示剧情对话
        if(heroData.hasData && heroData.impressionTalk)
        {
            CImpressionUtil.showPlotTalk(heroData);

            var data:Object = {};
            data["impressionTalk"] = false;
            heroData.updateDataByData(data);
        }

        _updateHeroInfo();

        (m_pViewUI.box_talk.getChildByName("txt_heroTalk" ) as Label).text = "";
//        _updateHeroTalkInfo();

//        m_pTimer.stop();
//        m_pTimer.reset();
//        m_pTimer.start();

        m_pUpgradeView.data = _selData;

        m_iLastSelIndex = m_pViewUI.list_hero.hero_list.selectedIndex;
        m_bIsDefaultSel = false;
    }

    /**
     * 更新战队名、格斗家名、格斗家形象等信息
     */
    private function _updateHeroInfo():void
    {
        if(_heroData)
        {
            if(_heroData.hasData)
            {
                m_pViewUI.img_hero.url = _selData ? _selData.heroImgUrl : "";
//                m_pViewUI.img_hero.transform.colorTransform = new ColorTransform();
            }
            else
            {
                m_pViewUI.img_hero.url = _selData ? _selData.heroImgGrayUrl : "";
//                m_pViewUI.img_hero.transform.colorTransform = new ColorTransform(0.2,0.2,0.2);
            }

            m_pViewUI.txt_teamName.text = CImpressionUtil.getTeamName(_heroData.prototypeID);
            var sex:int = _heroData.playerBasic != null ? _heroData.playerBasic.gender : 0;
            m_pViewUI.img_bigBg.url = "icon/impression/bg_" + sex + ".jpg";
            m_pViewUI.img_heroName.url = CPlayerPath.getUIHeroNamePath(_heroData.prototypeID);
        }
        else
        {
            m_pViewUI.txt_teamName.text = "";
            m_pViewUI.img_hero.url = "";
            m_pViewUI.img_hero.transform.colorTransform = new ColorTransform();
            m_pViewUI.img_heroName.url = "";
            m_pViewUI.img_bigBg.url = "";
        }
    }

    /**
     * 更新格斗家对话信息
     */
    private function _updateHeroTalkInfo():void
    {
        if(m_pViewUI.box_talk.visible)
        {
            return;
        }

        if(_selData)
        {
            var currTalkStr:String = m_pViewUI.txt_heroTalk.text;
            var newTalkStr:String = CImpressionUtil.getHeroLoopTalk(_selData.roleId,currTalkStr);
            (m_pViewUI.box_talk.getChildByName("txt_heroTalk" ) as Label).text = newTalkStr;

            m_pViewUI.box_talk.visible = true;
            m_pViewUI.txt_heroTalk.visible = true;

            m_pViewUI.clip_bubble.playFromTo(null, null, new Handler(_onAnimationComplHandler));
            function _onAnimationComplHandler():void
            {
                m_pViewUI.clip_bubble.gotoAndStop(1);
            }

            delayCall(1.3, onDelay1);
            function onDelay1():void
            {
                m_pViewUI.txt_heroTalk.visible = false;
            }

            delayCall(2, onDelay2);
            function onDelay2():void
            {
                m_pViewUI.box_talk.visible = false;
            }
        }
    }

    /**
     * 翻页按钮状态
     */
    private function _updatePageBtnState():void
    {
        m_pViewUI.btn_left.disabled = m_pViewUI.list_hero.hero_list.selectedIndex == 0;
        m_pViewUI.btn_right.disabled = m_pViewUI.list_hero.hero_list.selectedIndex == 2;
    }

    private function _onBtnClickHandler(e:MouseEvent):void
    {
        var page:int;

        if ( e.target == m_pViewUI.btn_left )
        {
            if(m_pViewUI.list_hero.hero_list.selectedIndex > 0)
            {
                page = (m_pViewUI.list_hero.hero_list.selectedIndex-1)/3;
                if(m_iCurrPage != page)
                {
                    m_pViewUI.list_hero.hero_list.page -= 1;
                    m_iCurrPage = page;
                }

                m_pViewUI.list_hero.hero_list.selectedIndex -= 1;
            }

            _updatePageBtnState();
        }

        if ( e.target == m_pViewUI.btn_right )
        {
            if(m_pViewUI.list_hero.hero_list.selectedIndex < m_pViewUI.list_hero.hero_list.length-1)
            {
                page = (m_pViewUI.list_hero.hero_list.selectedIndex+1)/3;
                if(m_iCurrPage != page)
                {
                    m_pViewUI.list_hero.hero_list.page += 1;
                    m_iCurrPage = page;
                }

                m_pViewUI.list_hero.hero_list.selectedIndex += 1;
            }

            _updatePageBtnState();
        }
    }

    private function _onBoxClickHandler(e:MouseEvent):void
    {
        _updateHeroTalkInfo();

//        m_pTimer.stop();
//        m_pTimer.reset();
//        m_pTimer.start();
    }

    private function _onTimerHandler(e:TimerEvent):void
    {
        _updateHeroTalkInfo();
    }

    /**
     * 格斗家亲密度信息更新
     * @param e
     */
    private function _onPlayerInfoUpdateHandler(e:CPlayerEvent):void
    {
        m_pViewUI.list_hero.hero_list.refresh();

        _updateHeroTalkInfo();
    }

    private function _clear():void
    {
        (m_pViewUI.box_talk.getChildByName("txt_heroTalk" ) as Label).text = "";
        m_pViewUI.list_hero.hero_list.selectedIndex = -1;
        m_pViewUI.box_talk.visible = false;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    /**
     * 得选中hero的数据
     */
    private function get _selData():CPlayerInfoData
    {
        var heroData:CPlayerHeroData =  m_pViewUI.list_hero.hero_list.selectedItem as CPlayerHeroData;
        var playerInfoData:CPlayerInfoData = new CPlayerInfoData();
        playerInfoData.roleId = heroData.prototypeID;
        playerInfoData.isOpen = true;
        playerInfoData.isGet = heroData.hasData;

        return playerInfoData;
    }

    private function get _heroData():CPlayerHeroData
    {
        if(_selData)
        {
            var manager:CPlayerManager = system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
            var playerData:CPlayerData = manager.playerData;
//            var heroData:CPlayerHeroData = playerData.heroList.getByKey("ID",_selData.roleId) as CPlayerHeroData;
            var heroData:CPlayerHeroData = playerData.heroList.getHero(_selData.roleId);

            return heroData;
        }

        return null;
    }

    override public function dispose() : void
    {
        super.dispose();

        m_pMask = null;
        m_pUpgradeView = null;
    }
}
}
