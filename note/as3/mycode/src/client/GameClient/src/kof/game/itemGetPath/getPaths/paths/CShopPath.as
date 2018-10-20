//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/25.
 * Time: 19:50
 */
package kof.game.itemGetPath.getPaths.paths {

    import kof.game.itemGetPath.CItemGetView;
    import kof.game.itemGetPath.getPaths.CAbstractGetPath;
import kof.game.shop.CShopManager;
import kof.game.shop.CShopSystem;
import kof.game.shop.enum.EShopType;
    import kof.table.ItemGetPath;
    import kof.table.Shop;
    import kof.ui.imp_common.GetItemPathItemUI;

    import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/25
     */
    public class CShopPath extends CAbstractGetPath {
        public function CShopPath( itemGetView : CItemGetView ) {
            super( itemGetView );
        }

        override public function getPath( path : String, itemUI : GetItemPathItemUI ) : void {
            var arr : Array = path.split( ":" );
            var pathId : int = arr[ 0 ];
            var shopID : int = arr[ 1 ];
            var itemGetPath : ItemGetPath = _itemGetPath( pathId );
            if ( shopID == 0 ) {
                shopID = 4; //普通商店
            }
            var shopTable : Shop = _shopTable( shopID );
            itemUI.btn1.label = "打开商店";
            itemUI.pathName.text = shopTable.name;
            itemUI.btn1.visible = true;
            itemUI.btn2.visible = false;
            itemUI.btn3.visible = false;
            itemUI.isunLock.visible = false;
            itemUI.btn1.clickHandler = new Handler( _gotoShop, [ shopTable.type ] );
            itemUI.iconBtn.skin = itemGetPath.iconURL;
            ObjectUtils.gray(itemUI.btn1,false);
            itemUI.btn1.mouseEnabled = true;
//            var bool:Boolean = (_pItemGetView.appSystem.stage.getSystem(CShopSystem).getHandler(CShopManager) as CShopManager).isHaveShopByType(shopTable.type);
//            if(!bool){
//                itemUI.isunLock.visible = true;
//                ObjectUtils.gray( itemUI.btn1, true );
//                itemUI.btn1.mouseEnabled = false;
//                itemUI.isunLock.text = "(神秘商店未开启)";
//            }
            itemUI.btn1.mouseEnabled=true;
        }
    }
}
