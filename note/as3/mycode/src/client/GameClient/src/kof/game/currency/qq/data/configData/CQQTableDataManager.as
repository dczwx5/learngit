//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/28.
 * Time: 17:56
 */
package kof.game.currency.qq.data.configData {

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CAppSystem;
    import kof.table.Item;
    import kof.table.TencentDailyPrivilege;
    import kof.table.TencentFreshPrivilege;
    import kof.table.TencentLevelPrivilege;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/28
     */
    public class CQQTableDataManager {
        private static var _instance : CQQTableDataManager = null;
        private var _system : CAppSystem = null;

        public function CQQTableDataManager( priClass : Priclass ) {
        }

        public static function get instance() : CQQTableDataManager {
            if ( !_instance ) {
                _instance = new CQQTableDataManager( new Priclass() );
            }
            return _instance;
        }

        public function set system( value : CAppSystem ) : void {
            this._system = value;
        }

        public function get system() : CAppSystem {
            return this._system;
        }

        public function get dataBaseSystem() : CDatabaseSystem {
            return this._system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        }

        /**
         * 新手礼包配置表
         * @param 1黄钻 2蓝钻 3大厅
         **/
        public function getTencentFreshPrivilege( type : int ) : TencentFreshPrivilege {
            var table : CDataTable = dataBaseSystem.getTable( KOFTableConstants.TENCENT_FRESH_PRIVILEGE ) as CDataTable;
            var len : int = table.toVector().length;
            for ( var i : int = 1; i <= len; i++ ) {
                var tencentFresh : TencentFreshPrivilege = table.findByPrimaryKey( i );
                if ( type == tencentFresh.type ) {
                    return tencentFresh;
                }
            }
            return null;
        }

        /**
         * 每日礼包配置表
         * @param 1黄钻 2蓝钻 3大厅
         **/
        public function getTencentDailyPrivilege( type : int ) : TencentDailyPrivilege {
            var table : CDataTable = dataBaseSystem.getTable( KOFTableConstants.TENCENT_DAILY_PRIVILEGE ) as CDataTable;
            var len : int = table.toVector().length;
            for ( var i : int = 1; i <= len; i++ ) {
                var tencentDaily : TencentDailyPrivilege = table.findByPrimaryKey( i );
                if ( type == tencentDaily.type ) {
                    return tencentDaily;
                }
            }
            return null;
        }

        /**
         * 等级礼包配置表
         * @param 1黄钻 2蓝钻 3大厅
         **/
        public function getTencentLevelPrivilege( type : int ) : Array {
            var arr : Array = [];
            var table : CDataTable = dataBaseSystem.getTable( KOFTableConstants.TENCENT_LEVEL_PRIVILEGE ) as CDataTable;
            var len : int = table.toVector().length;
            for ( var i : int = 1; i <= len; i++ ) {
                var tencentLevel : TencentLevelPrivilege = table.findByPrimaryKey( i );
                if ( type == tencentLevel.type ) {
                    arr.push( tencentLevel );
                }
            }
            return arr;
        }

        /**
         * 物品表
         * @param itemId 物品id
         * */
        public function getItemTable( itemId : int ) : Item {
            var table : CDataTable = dataBaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            var item : Item = table.findByPrimaryKey( itemId );
            return item;
        }
    }
}

class Priclass {
    public function Priclass() {
    }
}
