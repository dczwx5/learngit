//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title.control {

import QFLib.Foundation.CTime;

import kof.game.common.CLang;

import kof.game.common.view.event.CViewEvent;
import kof.game.switching.CSwitchingJump;
import kof.game.title.data.CTitleItemData;
import kof.game.title.enum.ETitleViewEventType;

public class CTitleMainControler extends CTitleControler {
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
     }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var titleItemData:CTitleItemData = e.data as CTitleItemData;
        switch (subType) {
            case ETitleViewEventType.MAIN_GET_CLICK :
                var sysTag:String = titleItemData.itemRecord.jumpToSysTag;
                CSwitchingJump.jump(system, sysTag);
                break;
            case ETitleViewEventType.MAIN_WEAR_CLICK :
                if (titleItemData.configId != titleData.curTitleID) {
                    netHandler.sendToWear(titleItemData.configId);
                }
                break;
            case ETitleViewEventType.MAIN_UN_WEAR_CLICK :
                if (titleItemData.configId == titleData.curTitleID) {
                    netHandler.sendToWear(0);
                }
                break;
        }
    }
    /**
     * 将时间长度转换为字符串
     * @param time	毫秒数
     * @return 转换完毕的字符串 天/时/分 or 时/分/秒
     */
    public static function ToTimeString(time:Number) : String {
        time/= 1000; // 秒
        var s:int;
        var m:int;
        var h:int;
        var d:int; // 天

        if (time > 24 * 3600) {
            time /= 60; // 分
            m = time % 60;
            time /= 60; // 时
            h = time % 24;
            time /= 24;
            d = time;
            return CTime.fillZeros(d.toString(),2) + CLang.Get("common_day") + CTime.fillZeros(h.toString(),2) + CLang.Get("common_hour") +
                    CTime.fillZeros(m.toString(),2) + CLang.Get("common_minute");

        } else {
            s = time % 60;
            time /= 60;
            m = time % 60;
            time /= 60;
            h = time;
            return CTime.fillZeros(h.toString(),2) + CLang.Get("common_hour") + CTime.fillZeros(m.toString(),2) + CLang.Get("common_minute") +
                    CTime.fillZeros(s.toString(),2) + CLang.Get("common_second");
        }
    }

}
}
