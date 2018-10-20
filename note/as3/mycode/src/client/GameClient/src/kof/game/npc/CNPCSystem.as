//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/20.
 */
package kof.game.npc {

import QFLib.Math.CVector3;

import flash.events.IEventDispatcher;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.NPC.INPCViewFacade;
import kof.game.common.CLogUtil;
import kof.table.NPC;
import kof.util.CSystemIDBinder;

import morn.core.handlers.Handler;

public class CNPCSystem extends CBundleSystem implements ISystemBundle, INPCViewFacade, INpcFacade {

    private var _npcSelectViewHandler:CNPCSelectViewHandler;

    private var _npcDialogueViewHandler:CNPCDialogueViewHandler;

    private var m_bInitialized : Boolean;

    private var m_currNpcView:CNPCViewHandlerBase;

    public function CNPCSystem() {
        super();
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.NPC );
    }

    override public function initialize() : Boolean {
        CSystemIDBinder.bind( KOFSysTags.NPC, -2 );

        if ( !super.initialize() )
            return false;

        var pView : CNPCSelectViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            pView = new CNPCSelectViewHandler();
            _npcSelectViewHandler = pView;
            this.addBean( pView );
        }

        pView = pView || this.getHandler( CNPCSelectViewHandler ) as CNPCSelectViewHandler;
        pView.closeHandler = new Handler( _onViewClosed );

        addBean( _npcDialogueViewHandler = new CNPCDialogueViewHandler() );

        return m_bInitialized;
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CNPCSelectViewHandler = this.getHandler( CNPCSelectViewHandler ) as CNPCSelectViewHandler;
        if ( !pView ) {
           LOG.logErrorMsg( "SystemBundle activated, but the CNPCSelectViewHandler isn't instance." );
           return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    public function showNPCView( data : Object, position:CVector3, callbackFun:Function ) : void {
        var pTable:IDataTable = (this.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.NPC);
        var iNpcID : int = CCharacterDataDescriptor.getPrototypeID( data );
        var m_pDate:NPC = pTable.findByPrimaryKey( iNpcID ) as NPC;

        if(m_pDate.isOpenPanel){
            var bundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(m_pDate.function0.Param));
            bundleCtx.setUserData( bundle, "activated", true );
            callbackFun();

            if(m_pDate.function0.Param == KOFSysTags.MALL)
            {
                CLogUtil.recordLinkLog(this, 10031);
            }
        }
        else
        {
            if(m_pDate.function0.Param == ""){
                m_currNpcView = _npcDialogueViewHandler;
            }else {
                m_currNpcView = _npcSelectViewHandler;
            }


            m_currNpcView.addDisplay();
            m_currNpcView.updateFun(data, position);
            m_currNpcView.closeHandler = new Handler(callbackFun);

        }

    }

    private function _onViewClosed() : void {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.setUserData( this, "activated", false );
        }
    }

    public function closeNPCView() : void {
        m_currNpcView.removeDisplay();
    }

    override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        var pView : CNPCSelectViewHandler = this.getBean( CNPCSelectViewHandler );
        pView.loadAssetsByView( pView.viewClass );
    }


    public function isOpen() : Boolean {
        if(m_currNpcView == null){
            return false;
        }
        return m_currNpcView.isOpenView;
    }

    public function get eventDelegate() : IEventDispatcher {
        return this;
    }

}
}
