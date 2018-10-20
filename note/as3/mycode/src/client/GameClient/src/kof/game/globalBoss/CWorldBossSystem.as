//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/27.
 * Time: 10:57
 */
package kof.game.globalBoss {

    import flash.events.Event;

    import kof.SYSTEM_ID;
    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.game.KOFSysTags;
    import kof.game.bundle.CBundleSystem;
    import kof.game.bundle.ISystemBundleContext;
import kof.game.common.status.CGameStatus;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.globalBoss.Event.CWBEventType;
    import kof.game.globalBoss.datas.CWBDataManager;
    import kof.game.instance.CInstanceExitProcess;
    import kof.game.instance.CInstanceSystem;
    import kof.game.instance.enum.EInstanceType;
    import kof.game.instance.event.CInstanceEvent;
    import kof.table.WorldBossConstant;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/27
     */
    public class CWorldBossSystem extends CBundleSystem {
        private var _bIsInitialize : Boolean = false;
        private var _pGlobalBossHandler : CWorldBossHandler = null;
        private var _pGlobalBossViewHandler : CWorldBossViewHandler = null;
        private var _pFightControl : CFightControl = null;
        private var _wbDataManager : CWBDataManager = null;

        private var _instanceOverHandler:CInstanceOverHandler;

        public function CWorldBossSystem() {
            super();
        }

        override public function get bundleID() : * {
            return SYSTEM_ID( KOFSysTags.WORLD_BOSS );
        }

        public override function dispose() : void {
            super.dispose();
            _pGlobalBossHandler = null;
            _pGlobalBossViewHandler = null;
            _pFightControl = null;
        }

        override public function initialize() : Boolean {
            if ( !super.initialize() )
                return false;
            if ( !_bIsInitialize ) {
                _bIsInitialize = true;
                this.addBean( _wbDataManager = new CWBDataManager( this ) );
                _addEvent();
                this.addBean( _pGlobalBossHandler = new CWorldBossHandler() );
                this.addBean( _pGlobalBossViewHandler = new CWorldBossViewHandler() );
                this.addBean( _pFightControl = new CFightControl( this ) );
                this.addBean(_instanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_WORLD_BOSS,
                                new Handler(_excuteEndLeveInstance),new Handler(_excuteNotEndLeveInstance)));
                _instanceOverHandler.listenEvent();

                this._initialize();
            }
            return _bIsInitialize;
        }

        public function removeInstanceOverEvent():void{
            _instanceOverHandler.unlistenEvent();
        }

        public function addInstanceOverEvent():void{
            _instanceOverHandler.listenEvent();
        }

        private function _addEvent() : void {
            this._wbDataManager.addEventListener( "openView", _updateSystemRedPoint );
            this._wbDataManager.addEventListener( CWBEventType.START_FIGHT, _updateSystemRedPoint );
            this._wbDataManager.addEventListener( CWBEventType.UPDATE_TREASURE, _updateTreasureRedPoint );
            this._wbDataManager.addEventListener( CWBEventType.RESULT, _excuteResult );

        }

        private var _instanceID : int = 0;
        private var _currentInstanceID : Number = 0;

        private function _initialize() : void {
            _pGlobalBossViewHandler.closeHandler = new Handler( _closeView );
            (this.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
            var pDatabaseSystem : CDatabaseSystem = this.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_CONSTANT ) as CDataTable;
            var wbConstant : WorldBossConstant = wbInstanceTable.findByPrimaryKey( 1 );
            if ( wbConstant ) {
                _instanceID = wbConstant.instanceID;
            }
        }

        private function _updateSystemRedPoint( e : Event ) : void {
            var pSystemBundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                if ( _wbDataManager.wbData.state != 2 ) {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, true );
                } else if ( _wbDataManager.judgeTreasureRedPoint() ) {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, true );
                } else {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, false );
                }
            }
        }

        private function _enterInstance( e : CInstanceEvent ) : void {
            _currentInstanceID = (this.stage.getSystem( CInstanceSystem ) as CInstanceSystem).instanceManager.instanceContentID;
            if ( e.type == CInstanceEvent.ENTER_INSTANCE ) {
                var instanceSystem : CInstanceSystem = stage.getSystem( CInstanceSystem ) as CInstanceSystem;
                if ( EInstanceType.isWorldBoss( instanceSystem.instanceType ) ) {
                    instanceSystem.addExitProcess( CWorldBossViewHandler, CInstanceExitProcess.FLAG_WORLDBOSS, this.setActivated, [ true ], 9999 );
                }
            }
        }

        override protected function onActivated( value : Boolean ) : void {
            super.onActivated( value );
            if ( value ) {
                if (!CGameStatus.checkStatus(this)){
                    return;
                }
                _pGlobalBossViewHandler.show();
            } else {
                _pGlobalBossViewHandler.close();
            }
        }

        private function _closeView() : void {
            this.setActivated( false );
        }

        override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
            this._pGlobalBossViewHandler = getBean( CWorldBossViewHandler );
        }

        private function _updateTreasureRedPoint( e : Event ) : void {
            var pSystemBundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                if ( _wbDataManager.wbData.state != 2 ) {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, true );
                } else if ( _wbDataManager.judgeTreasureRedPoint() ) {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, true );
                } else {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, false );
                }
            }
        }

        private function _excuteResult(e : Event):void{
            _instanceOverHandler.instanceOverEventProcess(null);
            _updateTreasureRedPoint(null);
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
