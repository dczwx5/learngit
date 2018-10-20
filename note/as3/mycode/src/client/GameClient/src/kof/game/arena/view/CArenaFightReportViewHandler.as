//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena.view {

import kof.framework.CViewHandler;
import kof.game.arena.CArenaHelpHandler;
import kof.game.arena.CArenaManager;
import kof.game.arena.CArenaNetHandler;
import kof.game.arena.data.CArenaFightReportData;
import kof.game.arena.enum.EArenaResultType;
import kof.game.arena.event.CArenaEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.arena.ArenaFightReportRenderUI;
import kof.ui.master.arena.ArenaFightReportWinUI;
import kof.ui.master.arena.ArenaReportRenderUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

/**
 * 竞技场战报界面
 */
public class CArenaFightReportViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:ArenaFightReportWinUI;

    public function CArenaFightReportViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ ArenaFightReportWinUI ];
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
                m_pViewUI = new ArenaFightReportWinUI();
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.list_report.renderHandler = new Handler(_renderItem);
//                m_pViewUI.btn_allleft.clickHandler = new Handler(_onClickAllLeft);
//                m_pViewUI.btn_allright.clickHandler = new Handler(_onClickAllRight);
//                m_pViewUI.btn_left.clickHandler = new Handler(_onClickLeft);
//                m_pViewUI.btn_right.clickHandler = new Handler(_onClickRight);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    public function removeDisplay():void
    {
        if(m_bViewInitialized)
        {
            if(m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            _removeListeners();
        }
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

        uiCanvas.addDialog( m_pViewUI );
    }

    private function _addListeners():void
    {
        system.addEventListener(CArenaEvent.FightReport_Update, _onFightReportUpdateHandler);
    }

    private function _removeListeners():void
    {
        system.removeEventListener(CArenaEvent.FightReport_Update, _onFightReportUpdateHandler);
    }

    private function _initView():void
    {
        _updateDefaultInfo();
        _reqInfo();
    }

    private function _reqInfo():void
    {
        _arenaNetHandler.arenaFightReportRequest();
    }

    override protected function updateDisplay():void
    {
        _updateDefaultInfo();
        _updateReportList();
        _updatePageInfo();
    }

    private function _updateDefaultInfo():void
    {
        var fightReportData:Array = _arenaManager.reportListData;
        if(fightReportData && fightReportData.length)
        {
            m_pViewUI.list_report.visible = true;
//            m_pViewUI.box_page.visible = true;
            m_pViewUI.txt_default.visible = false;
        }
        else
        {
            m_pViewUI.list_report.visible = false;
//            m_pViewUI.box_page.visible = false;
            m_pViewUI.txt_default.visible = true;
        }
    }

    private function _updateReportList():void
    {
        var fightReportData:Array = _arenaManager.reportListData;
        if(fightReportData && fightReportData.length)
        {
            m_pViewUI.list_report.dataSource = fightReportData;
        }
    }

    private function _updatePageInfo():void
    {
//        m_pViewUI.txt_page.text = (m_pViewUI.list_report.page+1) + "/" + m_pViewUI.list_report.totalPage;
    }

    private function _onFightReportUpdateHandler(e:CArenaEvent):void
    {
        updateDisplay();
    }

    //渲染List==========================================================================================================
    private function _renderItem( item:Component, index:int):void
    {
        if ( !(item is ArenaReportRenderUI) )
        {
            return;
        }

        var render:ArenaReportRenderUI = item as ArenaReportRenderUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var data:CArenaFightReportData = render.dataSource as CArenaFightReportData;
        if(null != data)
        {
            render.clip_type.visible = true;
            render.clip_type.index = data.type;

            render.clip_resultType.visible = true;
            render.clip_resultType.index = 2 - data.result;
            render.txt_timeInfo.text = _arenaHelp.getFightReportTimeInfo(data.time);

//            render.view_head.level_frame_img.visible = false;
//            render.view_head.lv_txt.visible = false;
//            render.view_head.star_list.visible = false;
//            render.view_head.icon_image.mask = render.view_head.hero_icon_mask;
//            render.view_head.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(data.heroId);

//            render.txt_roleName.text = data.roleName;
//            render.clip_combat.visible = true;
//            render.clip_combat.num = data.battleValue;

            render.txt_selfName.text = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.name;
            render.txt_enemyName.text = data.roleName;

            render.list_self.renderHandler = new Handler(_renderHero);
            render.list_enemy.renderHandler = new Handler(_renderHero);
            render.list_self.dataSource = data.selfHeroList;
            render.list_enemy.dataSource = data.enemyheroList;

            if(data.rank > 0)
            {
                render.txt_rankLabel.text = "排名升至";
                render.txt_rankValue.text = data.rank.toString();
                render.txt_rankValue.color = 0x70e324;
                render.clip_arrow.visible = true;
                render.clip_arrow.index = 0;
            }

            if(data.rank == 0)
            {
                render.txt_rankLabel.text = "排名不变";
                render.txt_rankValue.text = "";
                render.clip_arrow.visible = false;
            }

            if(data.rank < 0)
            {
                render.txt_rankLabel.text = "排名降至";
                render.txt_rankValue.text = Math.abs(data.rank).toString();
                render.txt_rankValue.color = 0xff0000;
                render.clip_arrow.visible = true;
                render.clip_arrow.index = 1;
            }
        }
        else
        {
            render.clip_type.visible = false;
            render.clip_resultType.visible = false;
            render.list_self.dataSource = [];
            render.list_enemy.dataSource = [];
            render.txt_selfName.text = "";
            render.txt_enemyName.text = "";
            render.txt_rankLabel.text = "";
            render.txt_rankValue.text = "";
            render.txt_timeInfo.text = "";
        }
    }

    private function _renderHero(item:Component, index:int):void
    {
        if(!(item is RewardItemUI))
        {
            return;
        }

        var render:RewardItemUI = item as RewardItemUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var data:Object = render.dataSource;
        if(null != data)
        {
            render.icon_image.url = CPlayerPath.getHeroSmallIconPath(data.heroId);
            render.num_lable.visible = false;
//            render.bg_clip.index = data.quality + 1;
            render.bg_clip.index = 0;

//            var playerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
//            render.toolTip = new Handler(playerSystem.showHeroTips,[heroData]);
        }
        else
        {
            render.icon_image.url = "";
            render.num_lable.visible = false;
            render.bg_clip.index = 0;
        }
    }

    private function _onClose(type:String):void
    {
        _removeListeners();
    }

    private function _onClickAllLeft():void
    {
        if(m_pViewUI.list_report.page != 0)
        {
            m_pViewUI.list_report.page = 0;
            _updatePageInfo();
        }
    }

    private function _onClickAllRight():void
    {
        if(m_pViewUI.list_report.page != m_pViewUI.list_report.totalPage-1)
        {
            m_pViewUI.list_report.page = m_pViewUI.list_report.totalPage-1;
            _updatePageInfo();
        }
    }

    private function _onClickLeft():void
    {
        if(m_pViewUI.list_report.page > 0)
        {
            m_pViewUI.list_report.page -= 1;
            _updatePageInfo();
        }
    }

    private function _onClickRight():void
    {
        if(m_pViewUI.list_report.page < m_pViewUI.list_report.totalPage-1)
        {
            m_pViewUI.list_report.page += 1;
            _updatePageInfo();
        }
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _arenaManager():CArenaManager
    {
        return system.getHandler(CArenaManager) as CArenaManager;
    }

    private function get _arenaNetHandler():CArenaNetHandler
    {
        return system.getHandler(CArenaNetHandler) as CArenaNetHandler;
    }

    private function get _arenaHelp():CArenaHelpHandler
    {
        return system.getHandler(CArenaHelpHandler) as CArenaHelpHandler;
    }

    override public function dispose():void
    {
        super.dispose();
    }
}
}
