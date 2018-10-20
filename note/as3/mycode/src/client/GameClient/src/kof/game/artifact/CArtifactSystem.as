//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/4/19.
 */
package kof.game.artifact {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.artifact.view.CArtifactViewHandler;
import kof.game.artifact.view.soul.CArtifactSoulStrengthenView;
import kof.game.artifact.view.suit.CArtifactSuitViewHandler;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;

import morn.core.handlers.Handler;

public class CArtifactSystem extends CBundleSystem implements ISystemBundle {

    private var _manager : CArtifactManager;
    private var _handler : CArtifactHandler;
    private var m_bInitialized : Boolean;

    //神器
    public function CArtifactSystem() {
        super();
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.ARTIFACT );
    }

    public override function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pView : CArtifactViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            pView = new CArtifactViewHandler();
            this.addBean( pView );
        }

        pView = pView || this.getHandler( CArtifactViewHandler ) as CArtifactViewHandler;
        pView.closeHandler = new Handler( _onViewClosed );

        addBean( _manager = new CArtifactManager() );
        addBean( _handler = new CArtifactHandler() );
        addBean( new CArtifactSoulStrengthenView() );
        addBean( new CArtifactSuitViewHandler() );

        ( stage.getSystem(CPlayerSystem) as CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_ARTIFACT,_onPlayerDataHandler);
        ( stage.getSystem(CBagSystem) as CBagSystem).addEventListener(CBagEvent.BAG_UPDATE,_onBagDataHandler);

        return m_bInitialized;
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CArtifactViewHandler = this.getHandler( CArtifactViewHandler ) as CArtifactViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CArtifactViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            _handler.artifactListRequest();
            if ( _manager.m_data ) {
                pView.addDisplay();
            }
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.setUserData( this, "activated", false );
        }
    }

    public function isOpenFirst():Boolean{
        var bool:Boolean = false;
        for (var i:int = 0;i<_manager.m_data.length;i++){
            if(!_manager.m_data[i].isLock){
                return true;
            }
        }
        return bool;
    }

    private function _onPlayerDataHandler(e:CPlayerEvent):void{
        if ( e.type == CPlayerEvent.PLAYER_ARTIFACT ) {
            onRedPoint();
        }
    }

    private function _onBagDataHandler(e:CBagEvent):void{
        onRedPoint();
    }

    //小红点
    public function onRedPoint():void{
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, _manager.hasRedPoint());
        }
    }
}
}
