//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/26.
 */
package kof.game.club {

import flash.events.Event;

public class CClubEvent extends Event {

    public static const OPEN_CLUB_RESPONSE : String = "_open_club_response";

    public static const CREATE_CLUB_SUCC : String = "_create_club_succ";

    public static const CLUB_INFO_RESPONSE: String = "_club_info_response";

    public static const CLUB_LIST_RESPONSE: String = "_club_list_response";

    public static const CLUB_APPLY_SUCC_AND_WAITING: String = "_club_apply_succ_and_waiting";

    public static const CLUB_APPLY_SUCC_AND_IN: String = "_club_apply_succ_and_in";

    public static const CLUB_ICON_CHANGE_REQUEST: String = "_club_icon_change_request";

    public static const CLUB_INFO_CHANGE: String = "_club_info_change";

    public static const CLUB_MEMBER_LIST_CHANGE: String = "_club_member_list_change";

    public static const CLUB_EXIT_SUCC: String = "_club_exit_succ";

    public static const DEAL_APPLICATION_RESPONSE: String = "_deal_application_response";

    public static const GET_OFFICER_WELFARE_RESPONSE: String = "_get_officer_welfare_response";

    public static const MEMBER_INFO_MODIFY_RESPONSE: String = "_member_info_modify_response";

    public static const OPEN_CLUB_FUND_RESPONSE: String = "_open_club_fund_response";

    public static const LUCKY_BAGINFO_LIST_RESPONSE: String = "_lucky_baginfo_list_response";

    public static const GET_LUCKY_BAG_RESPONSE: String = "_get_lucky_bag_response";

    public static const SYETEM_LUCKY_BAG_RECORD_RESPONSE: String = "_syetem_lucky_bag_record_response";

    public static const SINGLE_LUCKY_BAG_RECORD_RESPONSE: String = "_single_lucky_bag_record_response";

    public static const SEND_LUCKY_BAG_RESPONSE: String = "_send_lucky_bag_response";

    public static const SEND_LUCKY_BAG_RANK_RESPONSE: String = "_send_lucky_bag_rank_response";

    public static const PLAYER_LUCKY_BAG_RECORD_RESPONSE: String = "_player_lucky_bag_record_response";

    public static const CLUB_MSG_RESPONSE: String = "_club_msg_response";

    public static const CLUB_INVITATION_RESPONSE: String = "_club_invitation_response";

    public static const CLUB_LOG_RESPONSE: String = "_club_log_response";

    public static const CLUB_WORLD_VIEW_SHOW: String = "_club_world_view_show";

    public static const CLUB_GAME_INFO_REQUEST: String = "_club_game_info_request";

    public static const PLAY_CLUB_GAME_RESPONSE: String = "_play_club_game_response";

    public static const GET_CLUBGAME_REWARD_RESPONSE: String = "_get_clubgame_reward_response";

    public static const CLUB_BAG_RECHARGE_RESPONSE: String = "_club_bag_recharge_response";

    public static const CLUB_RED_POINT : String = "club_red_point";

    public function CClubEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
