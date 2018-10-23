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
var LoadMediator = (function (_super) {
    __extends(LoadMediator, _super);
    function LoadMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    Object.defineProperty(LoadMediator.prototype, "viewClass", {
        get: function () {
            return LoadingView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LoadMediator.prototype, "openViewMsg", {
        get: function () {
            return LoadMsg.OpenLoadingView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(LoadMediator.prototype, "closeViewMsg", {
        get: function () {
            return LoadMsg.CloseLoadingView;
        },
        enumerable: true,
        configurable: true
    });
    LoadMediator.prototype.onViewOpen = function () {
        this.regTaskMsg();
    };
    LoadMediator.prototype.onViewClose = function () {
        this.unregTaskMsg();
    };
    LoadMediator.prototype.onOpenViewHandler = function (msg) {
        this.taskName = msg.body.taskName;
        this.closeAfterComplete = msg.body.closeAfterComplete;
        _super.prototype.onOpenViewHandler.call(this, msg);
    };
    LoadMediator.prototype.onCloseViewHandler = function (msg) {
        _super.prototype.onCloseViewHandler.call(this, msg);
        this.taskName = null;
    };
    LoadMediator.prototype.onTaskProgress = function (msg) {
        if (this.view && this.view.isInited) {
            var body = msg.body;
            if (body.taskName == this.taskName) {
                this.view.setProgress(body.curr, body.total);
            }
        }
    };
    LoadMediator.prototype.onTaskCancel = function (msg) {
        var body = msg.body;
        if (body.taskName == this.taskName && this.closeAfterComplete) {
            this.sendMsg(create(LoadMsg.CloseLoadingView));
        }
    };
    LoadMediator.prototype.onTaskComplete = function (msg) {
        var body = msg.body;
        if (body.taskName == this.taskName && this.closeAfterComplete) {
            this.sendMsg(create(LoadMsg.CloseLoadingView));
        }
    };
    LoadMediator.prototype.regTaskMsg = function () {
        this.regMsg(LoadMsg.OnTaskProgress, this.onTaskProgress, this);
        this.regMsg(LoadMsg.OnTaskComplete, this.onTaskComplete, this);
        this.regMsg(LoadMsg.OnTaskCancel, this.onTaskCancel, this);
    };
    LoadMediator.prototype.unregTaskMsg = function () {
        this.unregMsg(LoadMsg.OnTaskProgress, this.onTaskProgress, this);
        this.unregMsg(LoadMsg.OnTaskComplete, this.onTaskComplete, this);
        this.unregMsg(LoadMsg.OnTaskCancel, this.onTaskCancel, this);
    };
    return LoadMediator;
}(ViewMediator));
__reflect(LoadMediator.prototype, "LoadMediator");
//# sourceMappingURL=LoadMediator.js.map