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
var TestModel = (function (_super) {
    __extends(TestModel, _super);
    function TestModel() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    Object.defineProperty(TestModel.prototype, "dataContent", {
        get: function () {
            return { num: 1, str: "hello world~" };
        },
        enumerable: true,
        configurable: true
    });
    return TestModel;
}(VoyaMVC.Model));
__reflect(TestModel.prototype, "TestModel");
//# sourceMappingURL=TestModel.js.map