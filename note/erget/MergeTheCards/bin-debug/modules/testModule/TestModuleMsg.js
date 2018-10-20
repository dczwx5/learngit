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
var TestModuleMsg;
(function (TestModuleMsg) {
    var RunTest = (function (_super) {
        __extends(RunTest, _super);
        function RunTest() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return RunTest;
    }(VoyaMVC.Msg));
    TestModuleMsg.RunTest = RunTest;
    __reflect(RunTest.prototype, "TestModuleMsg.RunTest");
    var SetTfVisible = (function (_super) {
        __extends(SetTfVisible, _super);
        function SetTfVisible() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return SetTfVisible;
    }(VoyaMVC.Msg));
    TestModuleMsg.SetTfVisible = SetTfVisible;
    __reflect(SetTfVisible.prototype, "TestModuleMsg.SetTfVisible");
    var SetTfContent = (function (_super) {
        __extends(SetTfContent, _super);
        function SetTfContent() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return SetTfContent;
    }(VoyaMVC.Msg));
    TestModuleMsg.SetTfContent = SetTfContent;
    __reflect(SetTfContent.prototype, "TestModuleMsg.SetTfContent");
    var OpenTestView = (function (_super) {
        __extends(OpenTestView, _super);
        function OpenTestView() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OpenTestView;
    }(VoyaMVC.Msg));
    TestModuleMsg.OpenTestView = OpenTestView;
    __reflect(OpenTestView.prototype, "TestModuleMsg.OpenTestView");
    var CloseTestView = (function (_super) {
        __extends(CloseTestView, _super);
        function CloseTestView() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return CloseTestView;
    }(VoyaMVC.Msg));
    TestModuleMsg.CloseTestView = CloseTestView;
    __reflect(CloseTestView.prototype, "TestModuleMsg.CloseTestView");
})(TestModuleMsg || (TestModuleMsg = {}));
//# sourceMappingURL=TestModuleMsg.js.map