class WxOpenDataContextMsg{

    public static readonly INIT_DATA = "WxOpenDataContextMsg_INIT_DATA";

    public static readonly CLOSE_CONTEXT = "WxOpenDataContextMsg_CLOSE";

    public static readonly FRIEND_RANK_LIST = "WxOpenDataContextMsg_FriendRankList";

    public static readonly FRIEND_NEAREST_RANK_LIST = "WxOpenDataContextMsg_FRIEND_NEAREST_RANK_LIST";

    public static readonly GROUP_RANK_LIST = "WxOpenDataContextMsg_GROUP_RANK_LIST";

    public static readonly UPDATE_PLAYER_DATA = "WxOpenDataContextMsg_UPDATE_PLAYER_DATA";

    public head:string;
    public body:Object;

    constructor(head:string, body?:Object){
        this.head = head;
        this.body = body;
    }
}
/**
 * body以这种形式声明
 */
type xxxBody = {
    str:string,
    num:number
}

type WxPlayerData = {
    openId:string,
    nickName:string;
}
type InitData = {
    resBaseUrl:string,
    lvCfg:{m_keys:any[], m_values: any[]}
}

type ShareTicket = string;