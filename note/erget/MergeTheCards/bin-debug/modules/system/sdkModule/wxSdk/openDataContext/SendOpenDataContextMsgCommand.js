var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var SendOpenDataContextMsgCommand = (function (_super) {
    __extends(SendOpenDataContextMsgCommand, _super);
    function SendOpenDataContextMsgCommand() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    SendOpenDataContextMsgCommand.create = function (msgHead, msgBody) {
        if (msgBody === void 0) { msgBody = null; }
        return this._cachePool.pop(SendOpenDataContextMsgCommand, msgHead, msgBody);
    };
    SendOpenDataContextMsgCommand.prototype.init = function (msgHead, msgBody) {
        if (msgBody === void 0) { msgBody = null; }
        this.msgVO = new WxOpenDataContextMsg(msgHead, msgBody);
    };
    SendOpenDataContextMsgCommand.prototype.execute = function () {
        //TODO:注释了开放域数据
        // this.closeAsync();
        // return;
        var mvcSpy = GameCtrlBase.instance;
        switch (this.msgVO.head) {
            case WxOpenDataContextMsg.FRIEND_RANK_LIST:
                mvcSpy.openView(SC_FriendsRankView, this.msgVO);
                break;
            case WxOpenDataContextMsg.FRIEND_NEAREST_RANK_LIST:
                mvcSpy.openView(SC_FriendsNearestRankView, this.msgVO);
                break;
            case WxOpenDataContextMsg.GROUP_RANK_LIST:
                mvcSpy.openView(SC_GroupRankView, this.msgVO);
                break;
        }
        this.postMsg(this.msgVO);
        this.closeAsync();
    };
    SendOpenDataContextMsgCommand.prototype.postMsg = function (msg) {
        wx.getOpenDataContext().postMessage(msg);
    };
    SendOpenDataContextMsgCommand.prototype.clear = function () {
        // this.postMsg(new WxOpenDataContextMsg(WxOpenDataContextMsg.CLOSE_CONTEXT));
        this.msgVO = null;
    };
    return SendOpenDataContextMsgCommand;
}(Command));
window["SendOpenDataContextMsgCommand"] = SendOpenDataContextMsgCommand;
