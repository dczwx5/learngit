//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk.event {

import flash.events.Event;
public class CPeakpkEvent extends Event {
    // net event
    public static const NET_EVENT_DATA:String = "netPeakpkData"; // 初始数据
    public static const NET_EVENT_UPDATE_DATA:String = "netPeakpkUpdateData"; // 更新数据
    public static const NET_RESULT_DATA:String = "netPeakpkResultData";

    public static const NET_PK_SUCCESS_DATA_1P:String = "netPeakpkSuccessData"; // 请求切磋成功反馈
    public static const NET_PK_FAIL_DATA_1P:String = "netPeakpkFailData"; // 请求切磋失败反馈
    public static const NET_RECEIVE_REFUSE_DATA_P1:String = "netPeakpkReceiveRefuseData"; // 收到拒绝切磋
    public static const NET_RECEIVE_CONFIRM_DATA_P1:String = "netPeakpkReceiveConfirmData"; // 收到确定切磋
    public static const NET_RECEIVE_INVITE_DATA_2P:String = "netPeakpkReceiveInviteData"; // 收到切磋邀请
    public static const NET_MATCH_DATA:String = "netPeakpkMatchData"; // 匹配完成数据
    public static const NET_LOADING_DATA:String = "netPeakpkLoadingData"; // 对手加载进度数据
    public static const NET_RECEIVE_INVITE_CANCEL_DATA_P2:String = "netPeakpkReceiveInviteCancelData"; // p2收到邀请取消

    // data event
    public static const DATA_EVENT:String = "peakpkDataEvent"; // 数据改变, 具体什么数据改变, 由subEvent确定

    public function CPeakpkEvent( type:String, subEevent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
        this.subEvent = subEevent;
    }

    public var data:Object;
    public var subEvent:String;
}
}
