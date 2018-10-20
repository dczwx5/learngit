//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/20.
 * Time: 10:19
 */
package kof.game.currency.enum {

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/20
     */
    public class ECurrencyIconURL {
        private static const ICO_URL : String = "icon/currency";

        public static function getIcoUrl( iconName : String ) : String {
            return ICO_URL+"/" + iconName + ".png";
        }
    }
}
