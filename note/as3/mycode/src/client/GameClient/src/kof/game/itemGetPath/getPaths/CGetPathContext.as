//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/25.
 * Time: 14:48
 */
package kof.game.itemGetPath.getPaths {

    import kof.ui.imp_common.GetItemPathItemUI;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/25
     */
    public class CGetPathContext {
        private var _getPath : CAbstractGetPath = null;

        public function CGetPathContext() {
        }

        public function set path( value : CAbstractGetPath ) : void {
            this._getPath = value;
        }

        public function getPath( path : String, itemUI : GetItemPathItemUI ) : void {
            this._getPath.getPath( path, itemUI );
        }
    }
}
