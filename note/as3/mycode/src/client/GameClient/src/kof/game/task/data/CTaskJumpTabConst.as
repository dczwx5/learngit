//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/18.
 */
package kof.game.task.data {


public class CTaskJumpTabConst {
    public function CTaskJumpTabConst() {
    }

    static public const TAB_INDEX_0 : int = 0;
    static public const TAB_INDEX_1 : int = 1;
    static public const TAB_INDEX_2 : int = 2;
    static public const TAB_INDEX_3 : int = 3;
    static public const TAB_INDEX_4 : int = 4;
    static public const TAB_INDEX_5 : int = 5;
    static public const TAB_INDEX_6 : int = 6;

    static public function getJumpTab( condition : int ):int{
        var tab : int ;

        switch ( condition ){

            //打开格斗家面板
            case CTaskConditionType.Type_113:  tab = TAB_INDEX_2 ;break;
            case CTaskConditionType.Type_114:  tab = TAB_INDEX_0 ;break;
            case CTaskConditionType.Type_115:  tab = TAB_INDEX_2 ;break;
            case CTaskConditionType.Type_1001: tab = TAB_INDEX_2 ;break;
            case CTaskConditionType.Type_1002: tab = TAB_INDEX_2 ;break;
            case CTaskConditionType.Type_1003: tab = TAB_INDEX_3 ;break;
            case CTaskConditionType.Type_1004: tab = TAB_INDEX_3 ;break;
            case CTaskConditionType.Type_1005: tab = TAB_INDEX_3 ;break;
        }

        return tab;

    }
}
}
