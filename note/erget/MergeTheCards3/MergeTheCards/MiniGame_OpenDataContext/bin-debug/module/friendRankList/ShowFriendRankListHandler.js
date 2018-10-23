var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var __extends = this && this.__extends || function __extends(t, e) { 
 function r() { 
 this.constructor = t;
}
for (var i in e) e.hasOwnProperty(i) && (t[i] = e[i]);
r.prototype = e.prototype, t.prototype = new r();
};
var ShowFriendRankListHandler = (function (_super) {
    __extends(ShowFriendRankListHandler, _super);
    function ShowFriendRankListHandler() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    ShowFriendRankListHandler.prototype.init = function () {
        this.addContextEvent(ContextEvent.CLOSE_CONTEXT, this.onCloseContext, this);
        return this;
    };
    ShowFriendRankListHandler.prototype.execute = function () {
        var view = this.onOpenView(FriendRankListPanel);
        view.dataList = [
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1000" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "100" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1700" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1800" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1900" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1070" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1030" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1010" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1020" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1030" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1040" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1050" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1060" }] },
            { openId: '', avatarUrl: '', nickName: 'peony', KVList: [{ key: "score", value: "1080" }] }
        ];
        //获取小游戏开放数据接口 --- 开始
        // wx.getFriendCloudStorage({
        //     keyList: [],
        //     success: (userDataList:UserGameData[]) => {
        //         console.log(`success: ${userDataList}`);
        //         if(this.isOpened){
        //             let view = this.onOpenView(FriendRankListPanel);
        //             view.dataList = userDataList;
        //         }else {
        //             console.warn(` ShowFriendRankListHandler is Closed`);
        //         }
        //     },
        //     fail: err => {
        //         console.log(`fail: ${err}`);
        //         if(!this.isOpened){
        //             console.warn(` ShowFriendRankListHandler is Closed`);
        //         }
        //     },
        //     complete: () => {
        //         if(!this.isOpened){
        //             console.warn(` ShowFriendRankListHandler is Closed`);
        //         }
        //     }
        // });
    };
    ShowFriendRankListHandler.prototype.onCloseContext = function () {
        this.closeView(FriendRankListPanel);
        this.closeAsync();
    };
    ShowFriendRankListHandler.prototype.clear = function () {
        this.removeContextEvent(ContextEvent.CLOSE_CONTEXT, this.onCloseContext, this);
    };
    return ShowFriendRankListHandler;
}(MsgHandler));
__reflect(ShowFriendRankListHandler.prototype, "ShowFriendRankListHandler");
//# sourceMappingURL=ShowFriendRankListHandler.js.map