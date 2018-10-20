//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/26.
 * Time: 10:25
 */
package kof.game.itemGetPath.getPaths.paths {

    import kof.game.itemGetPath.CItemGetView;
    import kof.game.itemGetPath.getPaths.CAbstractGetPath;
    import kof.table.ItemGetPath;
    import kof.ui.imp_common.GetItemPathItemUI;

    import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/26
     */
    public class CSystemUIPath extends CAbstractGetPath {
        public function CSystemUIPath( itemGetView : CItemGetView ) {
            super( itemGetView );
        }

        override public function getPath( path : String, itemUI : GetItemPathItemUI ) : void {
            var arr : Array = path.split( ":" );
            var pathId : int = arr[ 0 ];
            var itemGetPath : ItemGetPath = _itemGetPath( pathId );
            itemUI.iconBtn.skin = itemGetPath.iconURL;
            itemUI.btn1.label = "点击前往";
            itemUI.pathName.text = itemGetPath.name;
            itemUI.btn1.visible = true;
            itemUI.btn2.visible = false;
            itemUI.btn3.visible = false;
            itemUI.isunLock.visible = false;
            itemUI.btn1.clickHandler = new Handler( _gotoSystemUI, [ itemGetPath.sysTag ] );
            ObjectUtils.gray(itemUI.btn1,false);
            itemUI.btn1.mouseEnabled=true;
            itemUI.iconBtn.skin = itemGetPath.iconURL;
        }
    }
}
