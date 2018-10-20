//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/4.
 */
package kof.game.im.data {

public class CIMConst {
    public function CIMConst() {
    }

    static public const FRIENDS:int = 0;//好友

    static public const APPLY:int = 1;//申请

    static public const RECOMMEND:int = 2;//推荐

    static public const CAN_GET_STRENG :int = 0; //可以领取该好友赠送的体力

    static public const NOT_SEND_STRENG :int = 0; //尚未向该好友赠送体力

    static public const AGREE : int = 0;//同意

    static public const REFUSE : int = 1;//拒绝

    static public const SINGLE : int = 0;//单个

    static public const ALL : int = 1;//一键

    static public const NOT_SEND_APPLY : int = 0;//未发送申请

    static public const HASED_SEND_APPLY : int = 1;//已经发送申请

    static public const OFFLINE : int = 0;//离线

    static public const ONLINE : int = 1;//在线

    static public const NEW_STRENG_NOTICE : int = 0;//体力领取信息

    static public const NEW_APPLY_NOTICE : int = 1;//好友申请信息

    static public const ADD_FRIEND_NOTICE : int = 2;//好友增加

    static public const DELETE_FRIEND_NOTICE : int = 3;//好友删除

    static public const DEFAUL_INPUT_SEARCH:String = '请输入玩家名称';

    static public const NO_FRIENDS_TIPS:String = '快去加些小伙伴，一起畅玩拳皇世界!';

    static public const NO_APPLY_TIPS:String = '您的知名度去哪了？居然没人加你!';

    static public const CHAT_MEUN_LABEL  :String = '发起聊天';

    static public const DELETE_MEUN_LABEL  :String = '删除好友';

    static public const PLAYER_INFO : String = '查看资料';

    static public const FRIEND_PK : String = '发起切磋';

    static public const DEFULT_INPUT_CHAT  :String = '点击输入内容，最多100字';

    static public const CHAT_STR_MAX_CHARS : int = 200;//200个字符，100个汉字


//    static public const SPROPERTY_CHAT_VIEW : String = 'SPROPERTY_CHAT_VIEW';//打开聊天页面

}
}
