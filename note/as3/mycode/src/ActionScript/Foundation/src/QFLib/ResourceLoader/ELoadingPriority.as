//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/3/12
//----------------------------------------------------------------------------------------------------------------------

/*
*/

package QFLib.ResourceLoader
{

    public class ELoadingPriority
    {
        public static const LOW : int = 0;
        public static const NORMAL : int = 1;
        public static const HIGH : int = 2;
        public static const CRITICAL : int = 3;
        public static const HOT_CRITICAL : int = 4; // should only used internally

        public static const NUM_AVAILABLE_PRIORITIES : int = CRITICAL + 1;
        public static const NUM_PRIORITIES : int = HOT_CRITICAL + 1;

        public static const PRIORITY_TITLES : Array = [ "LOW", "NORMAL", "HIGH", "CRITICAL", "HOT_CRITICAL" ];
    }

}

