//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/7.
 */
package kof.game.player {

import kof.framework.INetworking;
import kof.game.bag.data.CBagData;
import kof.game.common.system.CNetHandlerImp;
import kof.game.player.data.CHeroEquipData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.message.CAbstractPackMessage;
import kof.message.Equipment.EquipMessageModifyResponse;
import kof.message.Equipment.EquipUpQualityRequest;
import kof.message.Equipment.EquipUpStarRequest;
import kof.message.Equipment.EquipUpgradeRequest;

public class CEquipmentNetHandler extends CNetHandlerImp {

        public function CEquipmentNetHandler() {
            super();
        }

        public override function dispose() : void {
            super.dispose();
        }

        override protected function onSetup() : Boolean {
            super.onSetup();

            // equipment
            bind( EquipMessageModifyResponse, _onEquipMessageModifyHandler );

            return true;
        }

        // ======================================S2C=============================================
        // EQUIP
        private final function _onEquipMessageModifyHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void {
            if (isError) return ;

            var response : EquipMessageModifyResponse = message as EquipMessageModifyResponse;

            var heroUID : Number = response.heroID;
            var playerData : CPlayerData = (system.getBean( CPlayerManager ) as CPlayerManager).playerData;
            var heroData : CPlayerHeroData = playerData.heroList.getByKey( CPlayerHeroData._ID, heroUID ) as CPlayerHeroData;
            if ( heroData ) {
                var equipData : CHeroEquipData = heroData.updateEquip( response );
                system.dispatchEvent( new CPlayerEvent( CPlayerEvent.EQUIP_DATA, [ playerData, heroData, equipData ] ) );
            }
            else {
                system.dispatchEvent( new CPlayerEvent( CPlayerEvent.EQUIP_DATA, null ) );
            }
        }

        // ============================装备============================
        // 装备升级请求
        // heroUniID 英雄唯一ID
        // equipUniID 装备唯一ID
        // type 升级类型，0 普通升级， 1 一键升级
        // itemList : 升级徽章秘籍等需要选择消耗的道具列表
        public function sendEquipLevelUp( heroUniID : Number, equipUniID : Number, type : int, itemList : Array ) : void {
            var request : EquipUpgradeRequest = new EquipUpgradeRequest();
            request.heroID = heroUniID;
            request.equipID = equipUniID;
            request.type = type;

            var list : Array = new Array();
            var itemData : Object;
            for ( var i : int = 0; i < itemList.length; i++ ) {
                itemData = itemList[ i ];
                var objData : Object = {itemID : itemData.itemID, num : itemData.num};
                list.push( objData );
            }
            request.itemList = list;
            networking.post( request );
        }

        // 装备升品请求
        // heroUniID 英雄唯一ID
        // equipUniID 装备唯一ID
        public function sendEquipQualityUp( heroUniID : Number, equipUniID : Number ) : void {
            var request : EquipUpQualityRequest = new EquipUpQualityRequest();
            request.heroID = heroUniID;
            request.equipID = equipUniID;
            networking.post( request );
        }

        // 装备升星请求
        // heroUniID 英雄唯一ID
        // equipUniID 装备唯一ID
        // type 升级类型，0 普通升级， 1 一键升级
        // itemList : 升星额外使用祝福石的道具列表
        public function sendEquipStarUp( heroUniID : Number, equipUniID : Number, itemList : Array ) : void {
            var request : EquipUpStarRequest = new EquipUpStarRequest();
            request.heroID = heroUniID;
            request.equipID = equipUniID;

            var list : Array = new Array();
            var itemData : CBagData;
            for ( var i : int = 0; i < itemList.length; i++ ) {
                itemData = itemList[ i ];
                var objData : Object = {itemID : itemData.itemID, num : 1};
                list.push( objData );
            }
            request.itemList = list;
            networking.post( request );
        }

    }
}