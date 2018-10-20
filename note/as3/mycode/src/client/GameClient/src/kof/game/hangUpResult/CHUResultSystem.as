//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/11/21.
 * Time: 15:52
 */
package kof.game.hangUpResult {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.hook.CHookSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/11/21
 */
public class CHUResultSystem extends CBundleSystem{
    private var _pHUReusltViewHandler:CHUResultViewHandler=null;
    private var _bIsInitialize:Boolean = false;

    public function CHUResultSystem() {
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.HANGUP_RESULT );
    }

    public override function dispose() : void {
        super.dispose();
        _pHUReusltViewHandler = null;
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;
        if ( !_bIsInitialize ) {
            _bIsInitialize = true;
            this.addBean( _pHUReusltViewHandler = new CHUResultViewHandler() );
            this._initialize();
        }
        return _bIsInitialize;
    }

    private function _initialize() : void {
        this._pHUReusltViewHandler = getBean( CHUResultViewHandler );
        (this.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
    }

    private function _enterInstance( e : CInstanceEvent ) : void {
        var isMainCity:Boolean = (this.stage.getSystem( CInstanceSystem ) as CInstanceSystem).isMainCity;
        if(isMainCity){
            return;
        }
        var pSystemBundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var systemBundle:ISystemBundle = null;
        var curState:Boolean;
        if ( pSystemBundleCtx ) {
            systemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.HOOK));
            curState = pSystemBundleCtx.getUserData( systemBundle , "activated", true );
            if (curState) {
                (this.stage.getSystem(CHookSystem) as CHookSystem).addEventListener("deActivated",_closeResult);
            } else {
                systemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.HANGUP_RESULT));
                pSystemBundleCtx.setUserData( systemBundle , "activated", false );
            }
        }
    }

    private function _closeResult(e:Event):void{
        (this.stage.getSystem(CHookSystem) as CHookSystem).removeEventListener("deActivated",_closeResult);
        var pSystemBundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var systemBundle:ISystemBundle = null;
        systemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.HANGUP_RESULT));
        pSystemBundleCtx.setUserData( systemBundle , "activated", false );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );
        if ( value ) {
            _pHUReusltViewHandler.show();
        } else {
            _pHUReusltViewHandler.close();
        }
    }
}
}
