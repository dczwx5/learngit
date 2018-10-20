//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/2.
 */
package kof.game.guildWar.data.fightReport {

import kof.data.CObjectData;

/**
 * 连胜数据
 */
public class CGuildWarAlwaysWinData extends CObjectData {

    public static const HistoryHighWinName:String = "historyHighWinName";
    public static const HistoryHighWin:String = "historyHighWin";
    public static const AlwaysWinName:String = "alwaysWinName";
    public static const AlwaysWin:String = "alwaysWin";

    public function CGuildWarAlwaysWinData() {
        super();
    }

    public function get historyHighWinName() : String { return _data[HistoryHighWinName]; }
    public function get historyHighWin() : int { return _data[HistoryHighWin]; }
    public function get alwaysWinName() : String { return _data[AlwaysWinName]; }
    public function get alwaysWin() : int { return _data[AlwaysWin]; }

    public function set historyHighWinName(value:String):void
    {
        _data[HistoryHighWinName] = value;
    }

    public function set historyHighWin(value:int):void
    {
        _data[HistoryHighWin] = value;
    }

    public function set alwaysWinName(value:String):void
    {
        _data[AlwaysWinName] = value;
    }

    public function set alwaysWin(value:int):void
    {
        _data[AlwaysWin] = value;
    }
}
}
