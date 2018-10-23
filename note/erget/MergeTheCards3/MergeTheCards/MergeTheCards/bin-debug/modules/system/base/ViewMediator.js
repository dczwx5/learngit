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
var ViewMediator = (function (_super) {
    __extends(ViewMediator, _super);
    function ViewMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    ViewMediator.prototype.activate = function () {
        var params = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            params[_i] = arguments[_i];
        }
        this.regMsg(SystemMsg.CloseAllViews, this.onCloseAllViews, this);
        this.regMsg(this.openViewMsg, this.onOpenViewHandler, this);
        this.regMsg(this.closeViewMsg, this.onCloseViewHandler, this);
    };
    ViewMediator.prototype.deactivate = function () {
        this.unregMsg(SystemMsg.CloseAllViews, this.onCloseAllViews, this);
        this.unregMsg(this.openViewMsg, this.onOpenViewHandler, this);
        this.unregMsg(this.closeViewMsg, this.onCloseViewHandler, this);
    };
    ViewMediator.prototype.onCloseAllViews = function (msg) {
        this.closeView();
    };
    ViewMediator.prototype.onOpenViewHandler = function (msg) {
        this.openView(msg.body);
    };
    ViewMediator.prototype.onCloseViewHandler = function (msg) {
        this.closeView(msg.body);
    };
    ViewMediator.prototype.openView = function (param) {
        var _this = this;
        if (param === void 0) { param = null; }
        if (!this.view) {
            this.view = new this.viewClass();
        }
        var view = this.view;
        var onViewInited = function () {
            _this.view.dg_inited.unregister(onViewInited);
            _this.onViewOpen(param);
            app.easyLoadingManager.remove(_this.easyLoadingCaseId);
        };
        if (!view.isInited) {
            this.easyLoadingCaseId = app.easyLoadingManager.add(getClassName(this.viewClass));
            view.dg_inited.register(onViewInited, this);
            view.open(param);
        }
        else {
            view.open(param);
            this.onViewOpen(param);
        }
    };
    // private onViewInited() {
    //     this.view.dg_inited.unregister(this.onViewInited);
    //     this.onViewOpen();
    //     app.easyLoadingManager.remove(this.easyLoadingCaseId);
    // }
    ViewMediator.prototype.closeView = function (param) {
        if (param === void 0) { param = null; }
        if (this.view && this.view.isOpened) {
            this.onViewClose();
            this.view.close(param);
        }
    };
    Object.defineProperty(ViewMediator.prototype, "isViewInited", {
        get: function () {
            return this.view.isInited;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ViewMediator.prototype, "viewClassName", {
        get: function () {
            return getClassName(this.viewClass);
        },
        enumerable: true,
        configurable: true
    });
    return ViewMediator;
}(VoyaMVC.Mediator));
__reflect(ViewMediator.prototype, "ViewMediator");
//# sourceMappingURL=ViewMediator.js.map