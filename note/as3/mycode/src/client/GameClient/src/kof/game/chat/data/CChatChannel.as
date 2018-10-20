//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/7/19.
 */
package kof.game.chat.data {

public class CChatChannel {
    public function CChatChannel() {
    }


    /** 综合 */
    static public const ALL:int = 0;
    /** 世界 */
    static public const WORLD:int = 1;
    /** 俱乐部 */
    static public const GUILD:int = 2;
    /** 私聊 */
    static public const PERSONAL:int = 3;
    /** 系统 */
    static public const SYSTEM:int = 4;
    /** gm */
    static public const GM : int = 5;
    /** 喇叭 */
    static public const HORN : int = 6;
    /** 获得 */
    static public const GETITEM : int = 7;

    static public function getChannelByLabel( labels : String, selectedIndex : int ): int {
        var label : String = labels.split(',')[selectedIndex];
        var channel : int;
        if( label == '综合'){
            channel = ALL;
        }else if( label == '世界'){
            channel = WORLD;
        }else if( label == '俱乐部'){
            channel = GUILD;
        }else if( label == '私聊'){
            channel = PERSONAL;
        }else if( label == '系统'){
            channel = SYSTEM;
        }else if( label == '喇叭'){
            channel = HORN;
        }else if( label == '获得'){
            channel = GETITEM;
        }
        return channel;

    }

    static public function getIndexByLabel( labels : String, label : String ): int {
        var labelsAry : Array = labels.split(',')
        return labelsAry.indexOf( label );
    }
    static public function getLabelByIndex( labels : String, index : int ): String {
        var labelsAry : Array = labels.split(',')
        return labelsAry[index];
    }

}
}
