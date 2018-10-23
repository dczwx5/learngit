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
var TestMediator = (function (_super) {
    __extends(TestMediator, _super);
    function TestMediator() {
        var _this = _super.call(this) || this;
        _this.viewClass = TestView;
        _this.tf = new egret.TextField();
        return _this;
    }
    TestMediator.prototype.onViewOpen = function () {
        this.regMsg(TestModuleMsg.SetTfVisible, this.tfVisibleHandler, this);
        this.regMsg(TestModuleMsg.SetTfContent, this.setTfContentHandler, this);
    };
    TestMediator.prototype.onViewClose = function () {
        this.unregMsg(TestModuleMsg.SetTfVisible, this.tfVisibleHandler, this);
        this.unregMsg(TestModuleMsg.SetTfContent, this.setTfContentHandler, this);
    };
    TestMediator.prototype.tfVisibleHandler = function (msg) {
        var visible = msg.body.visible;
        var tf = this.tf;
        if (visible) {
            StageUtils.getStage().addChild(tf);
        }
        else {
            if (tf.parent) {
                tf.parent.removeChild(tf);
            }
        }
    };
    TestMediator.prototype.setTfContentHandler = function (msg) {
        var body = msg.body;
        this.tf.text = body.num + "  " + body.str;
    };
    Object.defineProperty(TestMediator.prototype, "openViewMsg", {
        get: function () {
            return TestModuleMsg.OpenTestView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(TestMediator.prototype, "closeViewMsg", {
        get: function () {
            return TestModuleMsg.CloseTestView;
        },
        enumerable: true,
        configurable: true
    });
    return TestMediator;
}(ViewMediator));
__reflect(TestMediator.prototype, "TestMediator");
//# sourceMappingURL=TestMediator.js.map