//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/10.
 */
package kof.game.switching.view {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import kof.data.KOFTableConstants;

import kof.framework.CAppSystem;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.hero.CHeroSpriteUtil;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.game.switching.enums.EFuncType;
import kof.table.FuncOpenCondition;
import kof.table.FunctionNotice;
import kof.ui.CUISystem;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.master.main.FunctionNoticeUI;

import morn.core.handlers.Handler;

/**
 * 新功能预告
 */
public class CFuncNoticeViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : FunctionNoticeUI;
    /** @private */
    private var m_fScrollSpeed : Number;
    private var m_bShow : Boolean;
    private var m_bSlideOut : Boolean;
    private var m_pContentBox : DisplayObject;

    private var m_pData:FunctionNotice;

    public function CFuncNoticeViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [FunctionNoticeUI];
    }

    override protected function get additionalAssets():Array
    {
        return [];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitialize() : Boolean {
        if ( !super.onInitialize() )
            return false;

        m_fScrollSpeed = 100.0;
        return true;
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
                m_pViewUI = new FunctionNoticeUI();

                m_pViewUI.btn_slideIn.clickHandler = new Handler(_onSlideInHandler);
                m_pViewUI.btn_slideOut.clickHandler = new Handler(_onSlideOutHandler);

                m_pViewUI.left = 0;
                m_pViewUI.top = 165;

                m_pContentBox = m_pViewUI.getChildByName( "contentBox" );

                this.slideOut = true;

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
        if ( this.onInitializeView() )
        {
//            this.invalidate();

            var vParentUI : DisplayObjectContainer = _parentDisplayDetecting();
            if ( !vParentUI )
                return;

            if ( m_pViewUI )
            {
                vParentUI.addChild( m_pViewUI );
                _addListeners();
                _initView();
            }
        }
    }

    private function _addListeners():void
    {
    }

    private function _removeListeners():void
    {
    }

    private function _initView():void
    {
        updateDisplay();
    }

    override protected function updateDisplay():void
    {
        if(m_pData)
        {
            var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            var dataTable:IDataTable = dataBase.getTable(KOFTableConstants.FuncOpenCondition);
            var condition:FuncOpenCondition = dataTable.findByPrimaryKey(m_pData.openCondition);

            m_pViewUI.txt_name.text = m_pData.funcName;
            m_pViewUI.txt_condition.text = condition == null ? "" : condition.desc;

            if(m_pData.type == EFuncType.Type_Hero)// 格斗家
            {
                m_pViewUI.img_content.visible = false;
                m_pViewUI.clipCharacter_1.visible = true;

                var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem ) as CPlayerSystem;
                var heroData:CPlayerHeroData = playerSystem.playerData.heroList.getHero(int(m_pData.content));
                var clip:CCharacterFrameClip = m_pViewUI.clipCharacter_1 as CCharacterFrameClip;
                CHeroSpriteUtil.setSkin( system.stage.getSystem( CUISystem ) as CAppSystem, clip, heroData, false);
                clip.autoPlay = true;
                m_pViewUI.img_heroName.url = CPlayerPath.getUIHeroNamePath(heroData.prototypeID);
            }
            else// 功能图片
            {
                clip = m_pViewUI.clipCharacter_1 as CCharacterFrameClip;
                CHeroSpriteUtil.setSkin( system.stage.getSystem( CUISystem ) as CAppSystem, clip, null, false);
                clip.autoPlay = false;
                clip.visible = false;
                m_pViewUI.img_content.visible = true;
                m_pViewUI.img_content.url = "icon/" + m_pData.content;
                m_pViewUI.img_heroName.url = "";
            }
        }
    }

    private function _parentDisplayDetecting() : DisplayObjectContainer
    {
        var pLobbySys : CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        if ( !pLobbySys )
            return null;

        var pLobbyViewHandler : CLobbyViewHandler = pLobbySys.getHandler( CLobbyViewHandler ) as CLobbyViewHandler;
        if ( !pLobbyViewHandler )
            return null;

        if ( !pLobbyViewHandler.pMainUI && m_bShow )
        {
            callLater( _addToDisplay );
            return null;
        }

        if ( pLobbyViewHandler.pMainUI ) {
            var pLeftContainer : DisplayObjectContainer = pLobbyViewHandler.pMainUI.getChildByName( 'left' ) as DisplayObjectContainer;
            if ( pLeftContainer ) {
                return pLeftContainer;
            }
        }

        return pLobbyViewHandler.pMainUI;
    }

    private function _onSlideInHandler():void
    {
        slideOut = false;
    }

    private function _onSlideOutHandler():void
    {
        slideOut = true;
    }

    public function removeDisplay():void
    {
        m_bShow = false;
        _removeListeners();

        if ( m_pViewUI && m_pViewUI.parent )
        {
            m_pViewUI.parent.removeChild( m_pViewUI );

            var clip:CCharacterFrameClip = m_pViewUI.clipCharacter_1 as CCharacterFrameClip;
            CHeroSpriteUtil.setSkin( system.stage.getSystem( CUISystem ) as CAppSystem, clip, null, false);
            clip.autoPlay = false;
            m_pViewUI.img_content.url = "";
            m_pViewUI.img_heroName.url = "";
        }
    }

    override public function dispose() : void
    {
        super.dispose();

        m_pViewUI = null;
        m_pContentBox = null;
    }

    public function get slideOut() : Boolean {
        return m_bSlideOut;
    }

    public function set slideOut( value : Boolean ) : void {
        if ( m_bSlideOut == value )
            return;
        m_bSlideOut = value;

        if ( value ) {
            m_pViewUI.btn_slideIn.visible = !(m_pViewUI.btn_slideOut.visible = false);
        } else {
            m_pViewUI.btn_slideIn.visible = !(m_pViewUI.btn_slideOut.visible = true);
        }

        var clip:CCharacterFrameClip = m_pViewUI.clipCharacter_1 as CCharacterFrameClip;
        if(clip.visible)
        {
            clip.autoPlay = value;
        }

        if ( m_pContentBox ) {
            m_pContentBox.visible = m_pViewUI.btn_slideIn.visible;
        }
    }

    public function set configData(value:FunctionNotice):void
    {
        m_pData = value;
    }

    public function get configData():FunctionNotice
    {
        return m_pData;
    }
}
}
