//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/7.
 */
package kof.game.player {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.util.CHeroDevelopState;
import kof.message.CAbstractPackMessage;
import kof.message.Hero.AddHeroRequest;
import kof.message.Hero.AddHeroResponse;
import kof.message.Hero.HeroLevelUpgrateRequest;
import kof.message.Hero.HeroLevelUpgrateResponse;
import kof.message.Hero.HeroMessageListRequest;
import kof.message.Hero.HeroMessageListResponse;
import kof.message.Hero.HeroMessageModifyResponse;
import kof.message.Hero.HeroQualityUpgrateRequest;
import kof.message.Hero.HeroQualityUpgrateResponse;
import kof.message.Hero.HeroRebornInfoRequest;
import kof.message.Hero.HeroRebornInfoResponse;
import kof.message.Hero.HeroRebornRequest;
import kof.message.Hero.HeroRebornResponse;
import kof.message.Hero.HeroStarUpgrateRequest;
import kof.message.Hero.HeroStarUpgrateResponse;

// 关卡通信, 接收服务器发来的信息
    public class CHeroNetHandler extends CNetHandlerImp {

        public function CHeroNetHandler() {
            super();
        }

        public override function dispose() : void {
            super.dispose();
        }

        override protected function onSetup() : Boolean {
            super.onSetup();

            // hero
            bind( HeroMessageListResponse, _onHeroListLoginHandler );
            bind( HeroMessageModifyResponse, _onHeroModifyHandler );
            bind( AddHeroResponse, _onHeroAddHandler );

            //hero培养
            bind( HeroLevelUpgrateResponse, _onHeroLevelUPHandler );
            bind( HeroQualityUpgrateResponse, _onHeroQualityHandler );
            bind( HeroStarUpgrateResponse, _onHeroStarHandler );

            // 重生
            bind( HeroRebornResponse, _onHeroResetResponse );
            bind( HeroRebornInfoResponse, _onHeroResetInfoResponse );

            return true;
        }

        // ======================================S2C=============================================
        private final function _onHeroListLoginHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            if (isError) return ;

            var response : HeroMessageListResponse = message as HeroMessageListResponse;
            var playerData : CPlayerData = (system.getBean( CPlayerManager ) as CPlayerManager).playerData;
            playerData.initialHeroList( response );
            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.HERO_DATA, playerData ) );
        }

        // hero
        private final function _onHeroModifyHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            if (isError) return ;

            var response : HeroMessageModifyResponse = message as HeroMessageModifyResponse;
            var heroData : CPlayerHeroData = (system.getBean( CPlayerManager ) as CPlayerManager).updateHeroData( response );
            var playerData : CPlayerData = (system.getBean( CPlayerManager ) as CPlayerManager).playerData;
            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.HERO_DATA, playerData ) );
        }

        private final function _onHeroAddHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            if (isError) return ;

            var response : AddHeroResponse = message as AddHeroResponse;
            var heroData : CPlayerHeroData = (system.getBean( CPlayerManager ) as CPlayerManager).addHero( response );
//            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.HERO_ADD, heroData ) );

            var data:Object = {};
            data["getWay"] = response.source;
            data["heroData"] = heroData;
            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.HERO_ADD, data ) );

        }

        /**
         * 格斗家升级响应
         * @param net
         * @param message
         * @param isError
         */
        private final function _onHeroLevelUPHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            CHeroDevelopState.isInLevelUpgrade = false;

            if (isError) return ;

            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.HERO_LEVEL_UP, null ) );
        }

        /**
         * 格斗家升品响应
         * @param net
         * @param message
         * @param isError
         */
        private final function _onHeroQualityHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            CHeroDevelopState.isInQualAdvance = false;

            if (isError) return ;

            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.HERO_QUALITY_UP, null ) );
        }

        /**
         * 格斗家升星响应
         * @param net
         * @param message
         * @param isError
         */
        private final function _onHeroStarHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            CHeroDevelopState.isInStarAdvance = false;

            if (isError) return ;

            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.HERO_STAR_UP, null ) );
        }

        // 重生
        private final function _onHeroResetResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            if (isError) return ;

            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.HERO_RESET, null ) );
        }
        // 重生
        private final function _onHeroResetInfoResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            if (isError) return ;
            var response : HeroRebornInfoResponse = message as HeroRebornInfoResponse;

            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.HERO_RESET_INFO, [response.heroID, response.rebornRewardDatas, response.consumeCurrencyValue] ) );
        }

        // ======================================C2S=============================================
        public function sendHeroListLogin() : void {
            var request : HeroMessageListRequest = new HeroMessageListRequest();
            request.flag = 1;
            networking.post( request );
        }

        public function sendHireHero( heroID : int ) : void {
            var request : AddHeroRequest = new AddHeroRequest();
            request.ID = heroID;
            networking.post( request );
        }

        //格斗家培养，升级、升品、升星
        public function sendHeroLevelUp( heroID : int, itemList : Object ) : void {
            CHeroDevelopState.isInLevelUpgrade = true;

            var request : HeroLevelUpgrateRequest = new HeroLevelUpgrateRequest();
            request.decode( [ heroID, itemList ] );
            networking.post( request );
        }

        public function sendHeroQuality( heroID : int ) : void {
            CHeroDevelopState.isInQualAdvance = true;

            var request : HeroQualityUpgrateRequest = new HeroQualityUpgrateRequest();
            request.decode( [ heroID ] );
            networking.post( request );
        }

        public function sendHeroStar( heroID : int ) : void {
            CHeroDevelopState.isInStarAdvance = true;

            var request : HeroStarUpgrateRequest = new HeroStarUpgrateRequest();
            request.decode( [ heroID ] );
            networking.post( request );
        }

        public function sendResetHero( heroID : int ) : void {
            var request : HeroRebornRequest = new HeroRebornRequest();
            request.heroID = heroID;
            networking.post( request );
        }
        public function sendGetResetHeroInfo( heroID : int ) : void {
            var request : HeroRebornInfoRequest = new HeroRebornInfoRequest();
            request.heroID = heroID;
            networking.post( request );
        }
    }
}