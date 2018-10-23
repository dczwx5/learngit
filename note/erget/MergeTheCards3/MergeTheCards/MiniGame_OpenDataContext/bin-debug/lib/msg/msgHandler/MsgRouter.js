var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var MsgRouter = (function () {
    function MsgRouter() {
        this.handlerClassRefMap = {};
    }
    MsgRouter.prototype.regMsgHandler = function (msgHead, handler) {
        if (!this.handlerClassRefMap[msgHead]) {
            this.handlerClassRefMap[msgHead] = handler;
        }
        else {
            egret.warn("\u6CE8\u610F\uFF1A\u5F00\u653E\u57DF\u7A0B\u5E8F\u91CD\u590D\u6CE8\u518C\u4E86\u4E00\u4E2A\u6D88\u606F\uFF1A" + msgHead);
        }
    };
    MsgRouter.prototype.unregMsgHandler = function (msgHead) {
        if (this.handlerClassRefMap[msgHead]) {
            delete this.handlerClassRefMap[msgHead];
        }
    };
    MsgRouter.prototype.handleMsg = function (msg) {
        if (!msg.head) {
            egret.warn("\u6CE8\u610F\uFF1A\u5F00\u653E\u57DF\u7A0B\u5E8F\u63A5\u6536\u4E86\u4E00\u4E2A\u6CA1\u6709 head \u7684\u6D88\u606F\uFF1A" + msg);
            return;
        }
        var handlerClass = this.handlerClassRefMap[msg.head];
        if (handlerClass) {
            new handlerClass().init(msg.body).openAsync();
        }
        else {
            egret.warn("\u6CE8\u610F\uFF1A\u5F00\u653E\u57DF\u7A0B\u5E8F\u5E76\u672A\u6DFB\u52A0\u5BF9 " + msg.head + " \u7684\u6D88\u606F\u5904\u7406~\uFF01");
        }
    };
    return MsgRouter;
}());
__reflect(MsgRouter.prototype, "MsgRouter");
//# sourceMappingURL=MsgRouter.js.map