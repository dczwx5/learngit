//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/15.
 */
package kof.game.chat.data {

public class CChatMenuConst {
    public function CChatMenuConst() {
    }

//    static public const LABELS : Array = [MAKE_FRIENDS,TEAM_INVITATION,TEAM_APPLY,CLUB_INVITATION,CLUB_APPLY,PRIVATE_CHAT];
    static public const LABELS : Array = [PLAYER_INFO,MAKE_FRIENDS,PRIVATE_CHAT,GM_REPORT];
    static public const MAKE_FRIENDS : String = '加为好友';
    static public const TEAM_INVITATION : String = '组队邀请';
    static public const TEAM_APPLY : String = '入队申请';
    static public const CLUB_INVITATION : String = '俱乐部邀请';
    static public const CLUB_APPLY : String = '俱乐部邀请';
    static public const PRIVATE_CHAT : String = '私聊';
    static public const GM_REPORT : String = 'GM举报';
    static public const PLAYER_INFO : String = '查看资料';
}
}
