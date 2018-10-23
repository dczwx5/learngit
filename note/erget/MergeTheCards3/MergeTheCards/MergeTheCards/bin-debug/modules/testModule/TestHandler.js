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
var TestController = (function (_super) {
    __extends(TestController, _super);
    function TestController() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    TestController.prototype.activate = function () {
        this.regMsg(TestModuleMsg.RunTest, this.runTestHandler, this);
    };
    TestController.prototype.deactivate = function () {
        this.unregMsg(TestModuleMsg.RunTest, this.runTestHandler, this);
    };
    TestController.prototype.runTestHandler = function () {
        var data = this.getModel(TestModel).dataContent;
        this.sendMsg(create(TestModuleMsg.SetTfContent).init(data));
        this.sendMsg(create(TestModuleMsg.SetTfVisible).init({ visible: true }));
    };
    return TestController;
}(VoyaMVC.Controller));
__reflect(TestController.prototype, "TestController");
//# sourceMappingURL=TestHandler.js.map