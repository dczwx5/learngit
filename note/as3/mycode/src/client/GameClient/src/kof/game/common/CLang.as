//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/18.
 */
package kof.game.common {

import flash.utils.ByteArray;

    public class CLang {
        public static const TEST_FIND_ERROR:Boolean = false;

        public static function Get( key : String, params : Object = null ) : String {
            if (TEST_FIND_ERROR) return key;
            if (!_lang) return key;
            var value : String = _lang[ key ];
            if ( value && value.length > 0 ) {
                if ( params ) {
                    for ( var paramKey : String in params ) {
                        var findKey : String = "{" + paramKey + "}";
                        if ( value.indexOf( findKey ) != -1 ) {
                            value = value.replace( findKey, params[ paramKey ] );
                        }
                    }
                }
            } else {
                value = key;
            }

            return value;
        }

        private static var _lang:Object;

        //金币副本难度名字
        public static const GOLD_INSTANCE_LEVEL_NAME : Array = [ "", "简单", "普通", "困难", "极难" ];
        //Shop 1-100
        public static const LANG_00001 : String = "免费次数：";
        public static const LANG_00002 : String = "钻石次数：";
        public static const LANG_00003 : String = "剩余时间：";
        public static const LANG_00004 : String = "下次刷新时间：";
        public static const LANG_00005 : String = "不限购次数";
        public static const LANG_00006 : String = "可购买";
        public static const LANG_00007 : String = "次";
        public static const LANG_00008 : String = "购买次数不足";
        public static const LANG_00009 : String = "刷新次数已达上限";
        public static const LANG_00010 : String = "您是否确定花费 ";
        public static const LANG_00011 : String = " 刷新？";
        public static const LANG_00012 : String = "当前最大购买数量";
        public static const LANG_00013 : String = "件";
        public static const LANG_00014 : String = "绑钻不足<font color = '#ff6633'>{0}</font>，会扣除相应的钻石<font color = '#ff6633'>{1}</font>，是否继续购买？";
        public static const LANG_00015 : String = "购买成功";
        public static const LANG_00016 : String = "绑钻不足<font color = '#ff6633'>{0}</font>，会扣除相应的钻石<font color = '#ff6633'>{1}</font>，是否继续刷新？";
        public static const LANG_00017 : String = "VIP{0}可购买";
        public static const LANG_00018 : String = "达到VIP{0}才可以购买";

        public static const LANG_00200 : String = "拥有 : ";

        public static const LANG_00300 : String = "未上榜";
        public static const LANG_00301 : String = "活动已结束";

        public static const LANG_00350 : String = "使用：";
        public static const LANG_00351 : String = "倒计时：";

        public static const LANG_00401 : String = "(拥有：<font color='#00ff18'>{0}</font>)";
        public static const LANG_00402 : String = "您好，请稍后{0}S再次邀请";
        public static function hasKey( key : String ) : Boolean {
            return _lang.hasOwnProperty( key );
        }

        //提示1000~
        public static const LANG_01000 : String = "该功能暂未开放";

        public static function getStringCharLength( str : String ) : int {
            var bytes : ByteArray = new ByteArray();
            bytes.writeMultiByte( str, "gb2312" );
            bytes.position = 0;
            return bytes.length;
        }

        public static function getCommonNumber(value:int) : String {
            if (value <= 10) {
                return Get("common_number_china_" + value);
            } else {
                return value.toString();
            }
        }


        public static function initialize(xml:XML ):void {
            if (!xml) return ;
            if (!_lang) {
                _lang = new Object();
                for each(var text1:XML in xml.text){
                    _lang[text1.@id] = text1.text();
                }
            }
        }
    }
}
