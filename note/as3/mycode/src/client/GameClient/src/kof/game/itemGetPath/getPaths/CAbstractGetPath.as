//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/25.
 * Time: 14:47
 */
package kof.game.itemGetPath.getPaths {

    import kof.SYSTEM_ID;
    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.game.KOFSysTags;
    import kof.game.bundle.CBundleSystem;
    import kof.game.bundle.ISystemBundle;
    import kof.game.bundle.ISystemBundleContext;
    import kof.game.common.view.CViewManagerHandler;
    import kof.game.instance.CInstanceSystem;
    import kof.game.itemGetPath.CItemGetSystem;
    import kof.game.itemGetPath.CItemGetView;
    import kof.table.ItemGetPath;
    import kof.table.Shop;
    import kof.ui.CUISystem;
    import kof.ui.imp_common.GetItemPathItemUI;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/25
     */
    public class CAbstractGetPath {
        protected var _pItemGetView : CItemGetView = null;

        public function CAbstractGetPath( itemGetView : CItemGetView ) {
            this._pItemGetView = itemGetView;
        }

        public function getPath( path : String, itemUI : GetItemPathItemUI ) : void {

        }

        protected function challenge( instanceID : Number ) : void {
            (_pItemGetView.appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).enterInstance( instanceID );
            _pItemGetView.close();
        }

        protected function sweep( count : int ) : void {
            _pItemGetView.showSweep();
            _pItemGetView.close();
        }

        protected function _gotoShop( type : int ) : void {
            CViewManagerHandler.OpenViewByBundle( _pItemGetView.appSystem, KOFSysTags.MALL, "shop_type", [ type ] );
            _pItemGetView.close();
            if ( (_pItemGetView.appSystem as CItemGetSystem).closePopupUI ) {
                (_pItemGetView.appSystem as CItemGetSystem).closePopupUI.apply();
            }
        }

        protected function _gotoSystemUI( systags : String ) : void {
            var pSystemBundleCtx : ISystemBundleContext = _pItemGetView.appSystem.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( systags ) );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
                _pItemGetView.close();
            }
        }

        protected function _itemGetPath( id : int ) : ItemGetPath {
            var dataBaseSys : CDatabaseSystem = _pItemGetView.appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var itemGetDataTable : CDataTable = dataBaseSys.getTable( KOFTableConstants.ITEM_GET_PATH ) as CDataTable;
            return itemGetDataTable.findByPrimaryKey( id ) as ItemGetPath;
        }

        protected function _shopTable( id : int ) : Shop {
            var dataBaseSys : CDatabaseSystem = _pItemGetView.appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var itemGetDataTable : CDataTable = dataBaseSys.getTable( KOFTableConstants.SHOP ) as CDataTable;
            return itemGetDataTable.findByPrimaryKey( id ) as Shop;
        }
    }
}
