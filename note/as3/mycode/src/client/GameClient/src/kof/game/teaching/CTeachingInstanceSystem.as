//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/1/29.
 */
package kof.game.teaching {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.enum.EInstanceWndType;

import morn.core.handlers.Handler;

public class CTeachingInstanceSystem extends CBundleSystem implements ISystemBundle {

    private var _manager : CTeachingInstanceManager;
    private var _netHandler : CTeachingInstanceNetHandler;
    private var m_bInitialized : Boolean;
    private var m_pView : CTeachingInstanceViewHandler;
    private var _teachingInstanceOverHandler:CInstanceOverHandler;
    public function CTeachingInstanceSystem( ) {
        super(  );
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.TEACHING );
    }

    public override function dispose() : void {
        _manager = null;
        _netHandler = null;
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            m_pView = new CTeachingInstanceViewHandler();
            this.addBean( m_pView );
            var uiHandler:CInstanceUIHandler = (this.stage.getSystem(CInstanceSystem) as CInstanceSystem).uiHandler;
            uiHandler.addViewClassHandler(EInstanceWndType.WND_TEACHING_EXTRA_DETAIL,　CTeachingAccountView, CTeachingAccountControl);//
            this.addBean(_teachingInstanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_TEACHING, new Handler(showTeachingInstanceResultWinView)));
        }

        m_pView = m_pView || this.getHandler( CTeachingInstanceViewHandler ) as CTeachingInstanceViewHandler;
        m_pView.closeHandler = new Handler( _onViewClosed );

        addBean( _manager = new CTeachingInstanceManager() );
        addBean( _netHandler = new CTeachingInstanceNetHandler() );


        return m_bInitialized;
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CTeachingInstanceViewHandler = this.getHandler( CTeachingInstanceViewHandler ) as CTeachingInstanceViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CTeachingInstanceViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.setUserData( this, "activated", false );
            var mainSystem:CTeachingMainInletSystem = stage.getSystem(CTeachingMainInletSystem) as CTeachingMainInletSystem;
            if(mainSystem.enabled){
                pSystemBundleCtx.setUserData( mainSystem, "activated", false );
            }
        }
    }

    private function _onInstanceEvent(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }

        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            (this.stage.getSystem(CInstanceSystem) as CInstanceSystem).addExitProcess(null, null, openView, [ e.data ], 8111);
            _teachingInstanceOverHandler.listenEvent();
        } else if( e.type == CInstanceEvent.INSTANCE_PASS_REWARD && pInstanceSystem.instanceType == EInstanceType.TYPE_TEACHING){
            _teachingInstanceOverHandler.instanceOverEventProcess(null);
        } else if( e.type == CInstanceEvent.EXIT_INSTANCE　&& pInstanceSystem.instanceType == EInstanceType.TYPE_TEACHING ) {
            (this.stage.getSystem( CInstanceSystem ) as CInstanceSystem).unListenEvent( _onInstanceEvent );
        }
    }

    private function showTeachingInstanceResultWinView(callback:Function = null) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        var instanceContentID:int = pInstanceSystem.instanceContentID;

        var uiHandler:CInstanceUIHandler = this.stage.getSystem(CInstanceSystem).getBean(CInstanceUIHandler) as CInstanceUIHandler;
        uiHandler.show(EInstanceWndType.WND_TEACHING_EXTRA_DETAIL, null, callback, instanceContentID);
    }

    public function addEvent():void{
        (this.stage.getSystem(CInstanceSystem) as CInstanceSystem).listenEvent(_onInstanceEvent);
    }

    private function openView(data:int):void{
        var instanceType:int = (stage.getSystem(CInstanceSystem) as CInstanceSystem).getInstanceByID(data ).instanceType;
        if(instanceType == EInstanceType.TYPE_TEACHING){
            var bundleCtx:ISystemBundleContext = stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            bundleCtx.setUserData(this, CBundleSystem.ACTIVATED, true);
        }
    }
}
}
