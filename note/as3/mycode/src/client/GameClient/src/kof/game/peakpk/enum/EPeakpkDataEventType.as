//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk.enum {

public class EPeakpkDataEventType {
    public static const DATA:String = "data"; // all data change
    public static const RESULT_DATA:String = "resultData";
    public static const PK_SUCCESS_DATA_P1:String = "pkSuccessData";
    public static const PK_FAIL_DATA_P1:String = "pkFailData";
    public static const PK_REFUSE_DATA_P1:String = "pkRefuseData";
    public static const PK_CONFIRM_DATA_P1:String = "pkConfirmData";
    public static const PK_RECEIVE_INVITE_DATA_P2:String = "pkReceiveInviteData";
    public static const PK_RECEIVE_INVITE_CANCEL_DATA_P2:String = "pkReceiveInviteCancelData";
    public static const PK_MATCH_DATA:String = "pkMatchData";
    public static const PK_LOADING_DATA:String = "pkLoadingData";

}
}
