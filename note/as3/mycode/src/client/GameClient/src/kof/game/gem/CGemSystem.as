//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.gem.event.CGemEvent;
import kof.game.gem.view.CGemEmbedBagViewHandler;
import kof.game.gem.view.CGemMainViewHandler;
import kof.game.gem.view.CGemMergeViewHandler;
import kof.game.gem.view.CGemSuitAttrInfoViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;

import morn.core.handlers.Handler;

/**
 * 宝石系统
 */
public class CGemSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;
    private var m_pMainViewHandler:CGemMainViewHandler;
    private var m_pManager:CGemManagerHandler;
    private var m_pNetHandler:CGemNetHandler;
    private var m_pHelpHandler:CGemHelpHandler;
    private var m_pGuildWarUIHandler:CGemUIHandler;

    public function CGemSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
        {
            return false;
        }

        if ( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pMainViewHandler = new CGemMainViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            m_pManager = new CGemManagerHandler();
            this.addBean( m_pManager );

            m_pNetHandler = new CGemNetHandler();
            this.addBean( m_pNetHandler );

            m_pHelpHandler = new CGemHelpHandler();
            this.addBean( m_pHelpHandler );

            m_pGuildWarUIHandler = new CGemUIHandler();
            this.addBean(m_pGuildWarUIHandler);

            this.addBean( new CGemEmbedBagViewHandler() );
            this.addBean( new CGemSuitAttrInfoViewHandler() );
            this.addBean( new CGemMergeViewHandler() );
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.GEM);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,m_pHelpHandler.isCanOperate());
        }

        _reqInfo();
        addEventListeners();
    }

    private function _reqInfo():void
    {
        (getHandler( CGemNetHandler ) as CGemNetHandler).gemInfoRequest();
    }

    protected function addEventListeners() : void
    {
        stage.getSystem(CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);
        this.addEventListener(CGemEvent.UpdateGemBagInfo, _onUpdateGemBagInfoHandler);
        this.addEventListener(CGemEvent.GemInfoInit, _onUpdateTipInfoHandler);
    }

    protected function removeEventListeners() : void
    {
        stage.getSystem(CPlayerSystem).removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);
        this.removeEventListener(CGemEvent.UpdateGemBagInfo, _onUpdateGemBagInfoHandler);
        this.removeEventListener(CGemEvent.GemInfoInit, _onUpdateTipInfoHandler);
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CGemMainViewHandler = this.getHandler( CGemMainViewHandler ) as CGemMainViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CGemMainViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            _removeAllWin();
        }
    }

    private function _removeAllWin():void
    {
        (getHandler(CGemMainViewHandler) as CGemMainViewHandler).removeDisplay();
        (getHandler(CGemEmbedBagViewHandler) as CGemEmbedBagViewHandler).removeDisplay();
        (getHandler(CGemSuitAttrInfoViewHandler) as CGemSuitAttrInfoViewHandler).removeDisplay();
        (getHandler(CGemMergeViewHandler) as CGemMergeViewHandler).removeDisplay();
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
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( null != pSystemBundleCtx )
        {
            var curState:Boolean = pSystemBundleCtx.getUserData(this,CBundleSystem.NOTIFICATION,false);
            var isCanDevelop:Boolean = m_pHelpHandler.isCanOperate();
            if(curState != isCanDevelop)
            {
                pSystemBundleCtx.setUserData(this,CBundleSystem.NOTIFICATION,isCanDevelop);
            }
        }
    }

    private function _onUpdateGemBagInfoHandler(e:CGemEvent):void
    {
        _updateTipState();

        m_pManager.gemCategoryListData.updateHeadAndListData();
        this.dispatchEvent(new CGemEvent(CGemEvent.UpdateGemCategoryList, null));
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    public function setActived(value:Boolean):void
    {
        this.setActivated( value );
    }

}
}
