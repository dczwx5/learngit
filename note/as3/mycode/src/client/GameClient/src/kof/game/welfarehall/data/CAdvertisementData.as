//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/26.
 */
package kof.game.welfarehall.data {

import kof.data.CObjectData;

public class CAdvertisementData extends CObjectData {

    public static const Id:String = "id";// 广告id
    public static const Contents : String = "contents";//文本信息
    public static const Imgs:String = "imgs";// 图片列表
    public static const Validity:String = "validity";// 广告过期时间
    public static const Version:String = "version";// 版本号

    public function CAdvertisementData()
    {
        super();
    }

    public static function createObjectData(id:String,contents:Array, imgs:Array, validity:String, version:String) : Object
    {
        return {id:id, contents:contents, imgs:imgs, validity:validity, version:version};
    }

    public function get id() : String { return _data[Id]; }
    public function get contents() : Array { return _data[Contents]; }
    public function get imgs() : Array { return _data[Imgs]; }
    public function get validity() : String { return _data[Validity]; }
    public function get version() : String { return _data[Version]; }
}
}
