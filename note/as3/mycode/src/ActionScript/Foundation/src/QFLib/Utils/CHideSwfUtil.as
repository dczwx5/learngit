//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Utils
{
    import flash.utils.ByteArray;

    public class CHideSwfUtil
    {
        /**
         *    内存工具从内存中抓取SWF一般是依靠寻找SWF的前7个字节（3个SWF文件必有的标示字节“FWS”或“CWS”或“ZWS”+4个记录该SWF文件长度的字节）
         *    所以避免被提取我们只要在加载SWF到内存后，修改这头7个字节即可（SWF加载后修改这几个字节不影响SWF的运行）
         * */
        public static function hideSWF( bytes : ByteArray ) : void
        {
            for ( var i : int = 0; i < 7; i++ )
            {
                bytes[i] = int( 0xFF * Math.random() );
            }
        }

    } // class CHideSwfUtil
}
