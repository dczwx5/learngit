/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Entities.SpineExtension
{
    import QFLib.Utils.StringUtil;

    public class SkinUtil
    {
        /** 需要替换的：皮肤后缀字符 */
        private static var suffixSkinNames : Array = [ "B", "C", "D", "E", "F" ];

        /**
         * 将指定的skinName皮肤名，
         * </br>
         * 查找如果是需要替换的字符（后缀suffixSkinNames数组中，只要获取为其中一个字符的，都需要替换后缀）
         * </br>
         * <font color='#ff0000'><b>如：BSkill_B，执行replaceSuffixName("BSkill_B", "A")该方法后："BSkill_B"将变成："BSkill_A"</b></font>
         * */
        public static function replaceSuffixName( skinName : String, templateChar : String = "A" ) : String
        {
            if( StringUtil.isNullOrEmpty( skinName ) )
            {
                return skinName;
            }
            var skinNameLen : int = skinName.length;
            // 取最后一个字符
            var suffixChar : String = skinName.charAt( skinNameLen - 1 );
            for( var i : int = 0, len : int = suffixSkinNames.length; i < len; i++ )
            {
                var char : String = suffixSkinNames[ i ];
                if( suffixChar == char )
                {
                    return skinName.slice( 0, skinNameLen - 1 ) + templateChar;
                }
            }

            // 如果不需要替换，则原样返回
            return skinName;
        }

        /** 为指定的str生成对应的hashCode */
        public static function BKDRHash( str : String ) : uint
        {
            var seed : uint = 131;
            var hash : uint = 0;

            var strLen : int = str.length;
            for( var i : int = 0; i < strLen; ++i )
            {
                hash = hash * seed + uint( str.charCodeAt( i ) );
            }

            return hash;
        }
    }
}