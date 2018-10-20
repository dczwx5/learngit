//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/19.
 * Time: 17:45
 */
package kof.game.clubBoss {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubSystem;
import kof.game.club.view.CClubViewHandler;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.enums.EClubBossEventType;
import kof.game.common.status.CGameStatus;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;

import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/19
 */
public class CClubBossSystem extends CBundleSystem {
    private var _bIsInitialize:Boolean=false;
    private var _pClubBossHandler : CClubBossHandler = null;
    private var _pClubBossViewHandler : CClubBossViewHandler = null;
    private var _cbDataManager:CCBDataManager = null;

    private var _instanceOverHandler:CInstanceOverHandler;

    public function CClubBossSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.CLUB_BOSS );
    }

    public override function dispose() : void {
        super.dispose();
        _pClubBossHandler = null;
        _pClubBossViewHandler = null;
//        _pFightControl = null;
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;
        if ( !_bIsInitialize ) {
            _bIsInitialize = true;
            this.addBean( _cbDataManager = new CCBDataManager(this) );
//            _addEvent();
            this.addBean( _pClubBossHandler = new CClubBossHandler() );
            this.addBean( _pClubBossViewHandler = new CClubBossViewHandler() );
            this.addBean(_instanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_CLUB_BOSS,
                    new Handler(_excuteEndLeveInstance),new Handler(_excuteNotEndLeveInstance)));
            _instanceOverHandler.listenEvent();

            this._initialize();
        }
        return _bIsInitialize;
    }

    private function _initialize() : void {
        _pClubBossViewHandler.closeHandler = new Handler( _closeView );
        (this.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
        var pDatabaseSystem : CDatabaseSystem = this.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
//        var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_CONSTANT ) as CDataTable;
//        var wbConstant : WorldBossConstant = wbInstanceTable.findByPrimaryKey( 1 );
//        if ( wbConstant ) {
//            _instanceID = wbConstant.instanceID;
//        }
        _cbDataManager.addEventListener(EClubBossEventType.UPDATE_TIME,_openTime);

        _cbDataManager.addEventListener( EClubBossEventType.RESULT_REWARD, _resultView );
    }
    private function _enterInstance( e : CInstanceEvent ) : void {
        if ( e.type == CInstanceEvent.ENTER_INSTANCE ) {
            var instanceSystem : CInstanceSystem = stage.getSystem( CInstanceSystem ) as CInstanceSystem;
            if ( EInstanceType.isClubBoss( instanceSystem.instanceType ) ) {
//                var func:Function = function () : void {
//                    var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
//                    var systemBundle:ISystemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.GUILD));
//                    pSystemBundleCtx.setUserData( systemBundle, CBundleSystem.ACTIVATED, true );
//
//                };
                instanceSystem.addExitProcess( CClubBossViewHandler, CInstanceExitProcess.FLAG_CLUBBOSS, setActivated, [true], 9999 );
            }
        }
    }
    //活动开启时间提醒
    private function _openTime(e:Event):void{

    }

    public function removeInstanceOverEvent():void{
        _instanceOverHandler.unlistenEvent();
    }

    public function addInstanceOverEvent():void{
        _instanceOverHandler.listenEvent();
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );
        if ( value ) {
            if (!CGameStatus.checkStatus(this)){
                return;
            }
            _pClubBossViewHandler.show();
        } else {
            _pClubBossViewHandler.close();
        }
    }

    private function _closeView():void{
        var pSystemBundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
                var bool:Boolean = pSystemBundleCtx.getUserData( this, CBundleSystem.ACTIVATED, true );
            if(bool){
                pSystemBundleCtx.setUserData( this, CBundleSystem.ACTIVATED, false );
            }
        }
    }

    public function closeSystem():void{
        this.setActivated(false);
    }

    private function _resultView(e:Event):void{
        _instanceOverHandler.instanceOverEventProcess(null);
    }

    private var _excuteEndLeveInstance:Function = null;
    private var _excuteNotEndLeveInstance:Function = null;

    public function set excuteEndLeveInstance(func:Function):void{
        _excuteEndLeveInstance = func;
    }

    public function set excuteNotEndLeveInstance(func:Function):void{
        _excuteNotEndLeveInstance = func;
    }

}
}
