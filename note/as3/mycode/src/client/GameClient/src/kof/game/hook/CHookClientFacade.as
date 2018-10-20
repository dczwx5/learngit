//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/19.
 * Time: 15:10
 */
package kof.game.hook {
    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;

    import kof.framework.CAppSystem;
    import kof.game.bag.CBagManager;
    import kof.game.bag.CBagSystem;
    import kof.game.bag.data.CBagData;
import kof.game.instance.enum.EInstanceType;
import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
    import kof.game.player.CPlayerManager;
    import kof.game.player.CPlayerSystem;
    import kof.game.player.data.CEmbattleData;
    import kof.game.player.data.CEmbattleListData;
    import kof.game.player.data.CPlayerData;
    import kof.game.player.data.CPlayerHeroData;
    import kof.table.HangUpBattleAddition;
    import kof.table.HangUpLevelAddition;
    import kof.table.Item;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/19
     */
    public class CHookClientFacade {
        private static var _instance : CHookClientFacade = null;
        private var _hookSystem : CAppSystem = null;

        public function CHookClientFacade() {
        }

        public static function get instance() : CHookClientFacade {
            if ( !_instance ) {
                _instance = new CHookClientFacade();
            }
            return _instance;
        }

        public function set hookSystem( value : CAppSystem ) : void {
            this._hookSystem = value;
        }

        public function get hookSystem() : CAppSystem {
            return this._hookSystem;
        }

        /**获取格斗家列表，按战力降序排列*/
        public function getHeroList() : Array {
            var ret : Array = new Array();

            var playerManager : CPlayerManager = this._hookSystem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
//            var heroListData : CPlayerHeroListData = playerManager.playerData.heroList;
//            var heroList : Array = heroListData.list;
//            heroList.sort( _compareBattleValue );
//            return heroList;

            var playerData : CPlayerData = playerManager.playerData;

            var instanceType : int = EInstanceType.TYPE_HOOK;
            var embattleListData : CEmbattleListData = playerData.embattleManager.getByType( instanceType );
            if ( embattleListData && embattleListData.list && embattleListData.list.length > 0 ) {
                for ( var i : int = 0; i < embattleListData.list.length; i++ ) {
                    var embattleData : CEmbattleData = embattleListData.getByPos( i + 1 ); //embattleListData.list[0] as CEmbattleData);
                    if ( embattleData ) {
                        var heroID : int = embattleData.prosession;
                        var heroData : CPlayerHeroData = playerData.heroList.getHero( heroID );
                        ret.push( heroData );
                    }
                }
            }
            return ret;
        }

        private function get _playerLevel() : int {
            var playerManager : CPlayerManager = this._hookSystem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            return playerData.teamData.level;
        }

        private function _compareBattleValue( a : CPlayerHeroData, b : CPlayerHeroData ) : int {
            if ( a.battleValue > b.battleValue ) {
                return -1;
            }
            if ( a.battleValue < b.battleValue ) {
                return 1;
            }
            return 0;
        }

        /**获取战力加成*/
        public function getBattleExpAdd( battleValue : int ) : Number {
            var hookTable : CDataTable = this._hangUpBattleAddtion;
            var len : int = hookTable.toVector().length;
            var hookTableVec : Vector.<Object> = hookTable.toVector();
            for ( var i : int = 0; i < len; i++ ) {
                var hangUpBattleAddtion : HangUpBattleAddition = hookTableVec[ i ] as HangUpBattleAddition;
                if ( hangUpBattleAddtion.battleFloor <= battleValue && battleValue < hangUpBattleAddtion.battleUpper ) {
                    return hangUpBattleAddtion.expPercent * 100 / 10000;
                }
            }
            return 0;
        }

        /**获取掉落物品ID*/
        public function getDropPropID() : Number {
            var level : int = this._playerLevel;
            var hookTable : CDataTable = this._hangUpLevelAddtion;
            var len : int = hookTable.toVector().length;
            var hookTableVec : Vector.<Object> = hookTable.toVector();
            for ( var i : int = 0; i < len; i++ ) {
                var hangUpLevelAddtion : HangUpLevelAddition = hookTableVec[ i ] as HangUpLevelAddition;
                if ( hangUpLevelAddtion.levelFloor <= level && level < hangUpLevelAddtion.levelUpper ) {
                    return hangUpLevelAddtion.normalDropId;
                }
            }
            return 0;
        }

        /**
         * 根据物品ID获取物品表数据
         * @ItemID 物品id
         * @return 返回的物品表数据
         *
         * */
        public function getItemForItemID( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._hookSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        /**获取背包中的物品数量*/
        public final function getItemNuForBag( itemID : int ) : int {
            var bagData : CBagData = (this._hookSystem.stage.getSystem( CBagSystem ).getBean( CBagManager ) as CBagManager).getBagItemByUid( itemID );
            if ( bagData ) {
                return bagData.num;
            } else {
                return 0;
            }
        }

        /**根据itemID获取itemdata*/
        public final function getItemDataForItemID( itemID : int ) : CItemData {
            var itemData : CItemData = (this._hookSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        private function get _hangUpBattleAddtion() : CDataTable {
            var hookTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._hookSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            hookTable = pDatabaseSystem.getTable( KOFTableConstants.HANGUP_BATTLE_ADDITION ) as CDataTable;
            return hookTable;
        }

        private function get _hangUpLevelAddtion() : CDataTable {
            var hookTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._hookSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            hookTable = pDatabaseSystem.getTable( KOFTableConstants.HANGUP_LEVEL_ADDITION ) as CDataTable;
            return hookTable;
        }

        public function getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._hookSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID ) as Item;
        }

        public function get hangUpSkillVideo() : CDataTable {
            var hookTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._hookSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            hookTable = pDatabaseSystem.getTable( KOFTableConstants.HANGUP_SKILL_VIDEO ) as CDataTable;
            return hookTable;
        }

    }
}
