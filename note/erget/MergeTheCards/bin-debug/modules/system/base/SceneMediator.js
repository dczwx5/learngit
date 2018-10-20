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
var SceneMediator = (function (_super) {
    __extends(SceneMediator, _super);
    function SceneMediator() {
        var _this = _super.call(this) || this;
        _this._scene = _this.createScene();
        return _this;
    }
    SceneMediator.prototype.activate = function () {
        var params = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            params[_i] = arguments[_i];
        }
        this.regMsg(SystemMsg.EnterScene, this.onEnterScene, this);
    };
    SceneMediator.prototype.deactivate = function () {
        this.unregMsg(SystemMsg.EnterScene, this.onEnterScene, this);
    };
    SceneMediator.prototype.onEnterScene = function (msg) {
        this.exit();
        if (msg.body.scene == getClassByEntity(this.scene)) {
            this.enter();
        }
    };
    SceneMediator.prototype.enter = function () {
        this.scene.enter();
    };
    SceneMediator.prototype.exit = function () {
        this.sendMsg(create(SystemMsg.CloseAllViews).init({ closeSystemView: false }));
        this.scene.exit();
    };
    Object.defineProperty(SceneMediator.prototype, "scene", {
        get: function () {
            return this._scene;
        },
        enumerable: true,
        configurable: true
    });
    return SceneMediator;
}(VoyaMVC.Mediator));
__reflect(SceneMediator.prototype, "SceneMediator");
//# sourceMappingURL=SceneMediator.js.map