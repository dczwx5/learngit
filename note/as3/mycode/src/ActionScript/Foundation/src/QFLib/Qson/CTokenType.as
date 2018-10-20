//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Qson
{
    internal class CTokenType
    {
        // mapping to the JTokenType in Newtonsoft.Json
        public static const None : int = 0;
        public static const Object : int = 1;
        public static const Array : int = 2;

        public static const Integer : int = 6;
        public static const Float : int = 7;
        public static const String : int = 8;
        public static const Boolean : int = 9;
        public static const Null : int = 10;
    }

}

