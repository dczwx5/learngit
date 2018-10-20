//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/23.
 */
package kof.game.player {

    import kof.framework.INetworking;
    import kof.game.common.system.CNetHandlerImp;
    import kof.game.levelCommon.CLevelConfig;
    import kof.game.player.data.CPlayerData;
    import kof.game.player.event.CPlayerEvent;
    import kof.message.CAbstractPackMessage;
import kof.message.Player.CollectionGameRequest;
import kof.message.Player.LinkLogRequest;
import kof.message.Player.PlayerInfoModifyResponse;
    import kof.message.Player.PlayerInfoRequest;
    import kof.message.Player.PlayerInfoResponse;
    import kof.message.Player.RandomNameResponse;

// 关卡通信, 接收服务器发来的信息
    public class CPlayerHandler extends CNetHandlerImp {

        private var _childrenEventDispatcher:CPlayerChildrenEventDispatcher;

        public function CPlayerHandler() {
            super();
        }

        public override function dispose() : void {
            super.dispose();
            if (_childrenEventDispatcher) {
                _childrenEventDispatcher.dispose();
                _childrenEventDispatcher = null;
            }
        }

        override protected function onSetup() : Boolean {
            super.onSetup();

            _childrenEventDispatcher = new CPlayerChildrenEventDispatcher(this);

            bind( PlayerInfoResponse, _onPlayerInfoHandler );
            bind( PlayerInfoModifyResponse, _onModifyPlayerInfoHandler );
            bind( RandomNameResponse, _onRandomNameHandler );

            this.sendPlayerInfoLogin();
            (system as CPlayerSystem).heroNetHandler.sendHeroListLogin(); // 如果在playerHandle发请求, 会导致CPlayerTeamUIHandler还没有监听事件
            return true;
        }

        // ======================================S2C=============================================
        // 玩家登陆初始信息
        private final function _onPlayerInfoHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            if (isError) return ;

            var response : PlayerInfoResponse = message as PlayerInfoResponse;
            if (response.encode(null).length > 0) {
                var pManager:CPlayerManager =  (system.getBean( CPlayerManager ) as CPlayerManager);
                var pPlayerData:CPlayerData = pManager.playerData;
                pManager.initialPlayerData( response );
                system.dispatchEvent(new CPlayerEvent( CPlayerEvent.PLAYER_DATA_INITIAL, pPlayerData) );
                system.dispatchEvent(new CPlayerEvent( CPlayerEvent.PLAYER_DATA, pPlayerData) );

                if (pPlayerData.teamData.createTeam == false && CLevelConfig.IS_LEVELE_PREVIEW == false ) {
                    system.dispatchEvent( new CPlayerEvent( CPlayerEvent.CREATE_TEAM, null ) );
                }
            }

            (system as CPlayerSystem).isDataInitialize = true;

        }

        // 玩家基本信息改变
        private final function _onModifyPlayerInfoHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            if (isError) {
                system.dispatchEvent(new CPlayerEvent(CPlayerEvent.ERROR, null));
                return ;
            }

            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.BEFORE_UPDATE_DATA, (system.getBean( CPlayerManager ) as CPlayerManager).playerData ) );


            var pPlayerManager:CPlayerManager = (system.getBean( CPlayerManager ) as CPlayerManager);
            var pPlayerData : CPlayerData = pPlayerManager.playerData;
            var response : PlayerInfoModifyResponse = message as PlayerInfoModifyResponse;

            _childrenEventDispatcher.processChildrenEvent(response.playerMessage, pPlayerData);

            var oldTeamCombat:int = pPlayerData.teamData.battleValue;
            (system as CPlayerSystem).oldTeamCombat = oldTeamCombat;
            pPlayerManager.updatePlayerData(response);
            system.dispatchEvent(new CPlayerEvent( CPlayerEvent.PLAYER_DATA, pPlayerData));

            if(pPlayerData.teamData.battleValue > oldTeamCombat)
            {
                (system as CPlayerSystem).playCombatUpEffect();
            }

            _childrenEventDispatcher.dispatchChildrenEvent(pPlayerData);
        }

        // 随机名字
        private final function _onRandomNameHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            if (isError) return ;

            var response : RandomNameResponse = message as RandomNameResponse;
            (system.getBean( CPlayerManager ) as CPlayerManager).updateRandomName( response.name );
            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.RANDOM_NAME, (system.getBean( CPlayerManager ) as CPlayerManager).playerData ) );
            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.PLAYER_DATA, (system.getBean( CPlayerManager ) as CPlayerManager).playerData ) );
        }

        // ======================================C2S=============================================

        public function sendPlayerInfoLogin() : void {
            var request : PlayerInfoRequest = new PlayerInfoRequest();
            request.playerInfo = 1;

            networking.post( request );
        }

        // 页面打点请求
        public function linkLogRequest(logId:int):void
        {
            var request : LinkLogRequest = new LinkLogRequest();
            request.linkLogId = logId;

            networking.post( request );
        }
    }
}