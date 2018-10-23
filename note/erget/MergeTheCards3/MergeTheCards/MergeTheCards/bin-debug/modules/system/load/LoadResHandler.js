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
var LoadResController = (function (_super) {
    __extends(LoadResController, _super);
    function LoadResController() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    LoadResController.prototype.activate = function () {
        this.regMsg(LoadMsg.LoadRes, this.loadResHandler, this);
    };
    LoadResController.prototype.deactivate = function () {
        this.unregMsg(LoadMsg.LoadRes, this.loadResHandler, this);
    };
    LoadResController.prototype.loadResHandler = function (msg) {
        var _this = this;
        var resMng = app.resManager;
        resMng.loadResTask({
            keys: msg.body.sources,
            taskName: msg.body.taskName,
            onComplete: function (task) {
                _this.sendMsg(create(LoadMsg.OnTaskComplete).init({ taskName: task.taskName }));
            },
            onProgress: function (task, curr, total) {
                _this.sendMsg(create(LoadMsg.OnTaskProgress).init({ curr: curr, total: total, taskName: task.taskName }));
            },
            onCancel: function (task) {
                _this.sendMsg(create(LoadMsg.OnTaskCancel).init({ taskName: task.taskName }));
            }
        });
    };
    return LoadResController;
}(VoyaMVC.Controller));
__reflect(LoadResController.prototype, "LoadResController");
//# sourceMappingURL=LoadResHandler.js.map