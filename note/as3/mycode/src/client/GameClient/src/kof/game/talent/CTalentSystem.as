//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 11:47
 */
package kof.game.talent {

import flash.events.Event;

import kof.SYSTEM_ID;
    import kof.game.KOFSysTags;
    import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CChildSystemBundleEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.event.CPeakGameEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.talent.talentFacade.CTalentFacade;
import kof.game.talent.talentFacade.CTalentHelpHandler;
import kof.game.talent.talentFacade.talentSystem.events.CTalentEvent;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;

    import morn.core.handlers.Handler;

    public class CTalentSystem extends CBundleSystem {
        private var _talentViewHandler : CTalentViewHandler = null;
        private var _talentHandler : CTalentHandler = null;
        private var _talentDataManager : CTalentDataManager = null;
        private var _talentHelpHandler : CTalentHelpHandler = null;

        private var _bIsInitialize : Boolean = false;

        public function CTalentSystem() {
            super();
        }

        override public function get bundleID() : * {
            return SYSTEM_ID( KOFSysTags.TALENT );
        }

        public override function dispose() : void {
            super.dispose();
            _talentHandler = null;
            _talentViewHandler = null;

        }

        override public function initialize() : Boolean {
            if ( !super.initialize() )
                return false;
            if ( !_bIsInitialize ) {
                _bIsInitialize = true;
                this.addBean( _talentViewHandler = new CTalentViewHandler() );
                this.addBean( _talentHandler = new CTalentHandler() );
                this.addBean( _talentHelpHandler = new CTalentHelpHandler() );
                this._initialize();
            }
            return _bIsInitialize;
        }

        private function _initialize() : void {
            this._talentViewHandler = getBean( CTalentViewHandler );
            _talentViewHandler.closeHandler = new Handler( _closeView );
            _talentDataManager = CTalentDataManager.getInstance();
        }

        override protected function onActivated( value : Boolean ) : void {
            super.onActivated( value );
            if ( value ) {
                _talentViewHandler.show();
            }
            else {
                _talentViewHandler.close();
            }
        }

        override protected function onBundleStart(ctx:ISystemBundleContext):void
        {
            super.onBundleStart(ctx);

            // 登陆时主界面图标提示
            CTalentFacade.getInstance().dispatchEvent( CTalentEvent.UPDATE_DATA, null );

            _addListeners();
        }

        private function _addListeners():void
        {
            addEventListener(CChildSystemBundleEvent.CHILD_BUNDLE_START, _onChildSystemOpenHandler);
            _playerSystem.addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onTeamLevelUpHandler);
            _playerSystem.addEventListener(CPlayerEvent.HERO_ADD,_onHeroAddHandler);
            stage.getSystem(CPeakGameSystem).addEventListener(CPeakGameEvent.NET_EVENT_UPDATE_DATA, _onPeakGameDataUpdate);
        }

        private function _removeListeners():void
        {
            removeEventListener(CChildSystemBundleEvent.CHILD_BUNDLE_START, _onChildSystemOpenHandler);
            _playerSystem.removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onTeamLevelUpHandler);
            _playerSystem.removeEventListener(CPlayerEvent.HERO_ADD,_onHeroAddHandler);
            stage.getSystem(CPeakGameSystem).removeEventListener(CPeakGameEvent.NET_EVENT_UPDATE_DATA, _onPeakGameDataUpdate);
        }

        private function _onChildSystemOpenHandler(e:CChildSystemBundleEvent):void
        {
            if( e.data == KOFSysTags.TALENT_PEAK)
            {
                CTalentFacade.getInstance().dispatchEvent( CTalentEvent.UPDATE_DATA, null );
            }
        }

        private function _onTeamLevelUpHandler(e:Event):void
        {
            CTalentFacade.getInstance().dispatchEvent( CTalentEvent.UPDATE_DATA, null );
        }

        private function _onHeroAddHandler(e:Event):void
        {
            CTalentFacade.getInstance().dispatchEvent( CTalentEvent.UPDATE_DATA, null );
        }

        private function _onPeakGameDataUpdate(e:Event):void
        {
            CTalentFacade.getInstance().dispatchEvent( CTalentEvent.UPDATE_DATA, null );
        }

        private function _closeView() : void {
            this.setActivated( false );
        }

        public function updateSystemRedPoint(bool:Boolean) : void {
            var pSystemBundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                if ( bool ) {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, true );
                } else {
                    pSystemBundleCtx.setUserData( this, CBundleSystem.NOTIFICATION, false );
                }
            }
        }

        /**
         * @param index 索引值（1-30）
         * @return 返回状态 0没有开启，1开启没有镶嵌，2已镶嵌
         * */
        public function getTalentPointState( index : int ) : int {
            return _talentDataManager.getTalentPointState( index );
        }
        /**
         * @param talentID 斗魂id
         * @return 返回在斗魂库中的数量
         * */
        public function getNuForSoulID( talentID : Number ) : int {
            return _talentDataManager.getTalentPointNuForSoulID( talentID );
        }
        /**
         * @param page 要获取的斗魂页面
         * ETalentPageType.BEN_YUAN 本源 ETalentPageType.PEAK 拳皇大赛
         * @return 对应页面斗魂总等级
         *
         **/
        public function getTalentTotalLv(page:int):int{
            return _talentDataManager.getTalentTotalLvForTalentPage( page );
        }

        private function get _playerSystem():CPlayerSystem
        {
            return this.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        }
    }
}
