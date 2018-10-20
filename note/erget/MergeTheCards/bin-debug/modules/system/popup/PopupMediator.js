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
var PopupMediator = (function (_super) {
    __extends(PopupMediator, _super);
    function PopupMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    PopupMediator.prototype.onViewOpen = function (data) {
        app.log("PopupWindowData:", data);
        var view = this.view;
        if (data.title && data.title.length > 0) {
            if (!view.lb_title.parent) {
                view.addChild(view.lb_title);
            }
            view.lb_title.text = data.title;
        }
        else {
            if (view.lb_title.parent) {
                view.removeChild(view.lb_title);
            }
        }
        view.btn_close.visible = data.showClose;
        EventHelper.addTapEvent(view.btn_close, this.onTap, this);
        this._customOnClose = data.onClose;
        view.lb_content.text = data.content;
    };
    PopupMediator.prototype.onViewClose = function () {
        var view = this.view;
        EventHelper.removeTapEvent(view.btn_close, this.onTap, this);
        this._customOnClose = null;
    };
    PopupMediator.prototype.onTap = function (e) {
        var view = this.view;
        switch (e.currentTarget) {
            case view.btn_close:
                this.sendMsg(create(PopupMsg.HidePopup));
                if (this._customOnClose) {
                    this._customOnClose();
                }
                break;
        }
    };
    Object.defineProperty(PopupMediator.prototype, "viewClass", {
        get: function () {
            return PopupWindow;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PopupMediator.prototype, "openViewMsg", {
        get: function () {
            return PopupMsg.ShowPopup;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PopupMediator.prototype, "closeViewMsg", {
        get: function () {
            return PopupMsg.HidePopup;
        },
        enumerable: true,
        configurable: true
    });
    return PopupMediator;
}(ViewMediator));
__reflect(PopupMediator.prototype, "PopupMediator");
//# sourceMappingURL=PopupMediator.js.map