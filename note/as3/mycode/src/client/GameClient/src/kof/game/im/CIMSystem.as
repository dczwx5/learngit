//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/2.
 */
package kof.game.im {

import QFLib.Foundation.CMap;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.im.data.CIMConst;
import kof.game.im.view.CIMMenuHandler;
import kof.game.im.view.CIMSearchViewHandler;
import kof.game.im.view.CIMViewHandler;
import kof.game.systemnotice.CSystemNoticeConst;
import kof.game.systemnotice.CSystemNoticeSystem;

import morn.core.handlers.Handler;

public class CIMSystem extends CBundleSystem {

    private var _funcList:CMap;

    private var m_bInitialized : Boolean;

    private var _imManager : CIMManager;
    private var _imHandler : CIMHandler;
    private var _imViewHandler : CIMViewHandler;
    private var _imSearchViewHandler : CIMSearchViewHandler;
    private var _imMenuHandler : CIMMenuHandler;

    public function CIMSystem() {
        super();
    }
    override public function dispose() : void {
        super.dispose();

        _imManager.dispose();
        _imHandler.dispose();
        _imViewHandler.dispose();
        _imSearchViewHandler.dispose();
        _imMenuHandler.dispose();


        var funcs:Array = _funcList.toArray();
        for each (var func:Function in funcs) {
            this.unListenEvent(func);
        }
        _funcList = null;
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _imManager = new CIMManager() );
            this.addBean( _imHandler = new CIMHandler() );
            this.addBean( _imViewHandler = new CIMViewHandler() );
            this.addBean( _imSearchViewHandler = new CIMSearchViewHandler() );
            this.addBean( _imMenuHandler = new CIMMenuHandler() );
        }

        _imViewHandler.closeHandler = new Handler( _onViewClosed );

        addEventListener( CIMEvent.NEW_NOTICE_RESPONSE ,_onRedPoint );
        addEventListener( CIMEvent.APPLY_LIST_RESPONSE ,_onRedPoint );
        addEventListener( CIMEvent.FRIENDINFO_LIST_RESPONSE ,_onRedPoint );

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.FRIEND );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CIMViewHandler = this.getHandler( CIMViewHandler ) as CIMViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        var typeArr : * = ctx.getUserData( this, CBundleSystem.TAB , false );
        var type:int = 0;
        if( typeArr ){
            type = typeArr[0];
        }

        ctx.setUserData( this, CBundleSystem.TAB, [0]  );//恢复

        if ( value ) {
            pView.addDisplay( type );
            _pSystemNoticeSystem.hideIcon( CSystemNoticeConst.SYSTEM_IM );
        } else {
            pView.removeDisplay();
            _onRedPoint();
        }
    }

    private function _onViewClosed( ...args) : void {
        this.setActivated( false );
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

//        _showRedPoint( _imManager.canGetStrengNum > 0 || _imManager.applyNum > 0  );
        _onRedPoint();

    }
    //小红点
    private function _onRedPoint( evt : CIMEvent = null ):void{

         //小红点取消了
//        if( evt.type == CIMEvent.NEW_NOTICE_RESPONSE ){
//            var type : int  = int( evt.data );
//            _showRedPoint( type == CIMConst.NEW_STRENG_NOTICE || type == CIMConst.NEW_APPLY_NOTICE );
//        }else{
//            _showRedPoint( _imManager.canGetStrengNum > 0 || _imManager.applyNum > 0  );
//        }


        //通知小图标
        if( _imManager.new_apply_notice_b || _imManager.applyNum > 0 ) {
            var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleContext ) {
                var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ) );
                pSystemBundleContext.setUserData( pSystemBundle, CBundleSystem.NOTICE_ARGS, [ CSystemNoticeConst.SYSTEM_IM ] );
//                pSystemBundleContext.setUserData( pSystemBundle, CBundleSystem.TAB, [ 1 ] );//todo
                pSystemBundleContext.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
            }
        }
    }
    private function _showRedPoint( showB : Boolean ):void{
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, showB );
        }

    }


    public function listenEvent(func:Function) : void {
        if (null == func) return ;
        unListenEvent(func);

        _funcList[func] = func;
//        this.addEventListener(CBagEvent.BAG_UPDATE, func);
    }
    public function unListenEvent(func:Function) : void {
        if (null == func) return ;

        if (_funcList)
            _funcList.remove(func);
//        this.removeEventListener(CBagEvent.BAG_UPDATE, func);
    }
    private function get _pSystemNoticeSystem():CSystemNoticeSystem{
        return stage.getSystem( CSystemNoticeSystem ) as CSystemNoticeSystem
    }

}
}
