var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var LvConfig = (function () {
    function LvConfig() {
    }
    LvConfig.prototype.attrs = function () {
        return ["id", "lv", "needExp"];
    };
    return LvConfig;
}());
__reflect(LvConfig.prototype, "LvConfig");
window["LvConfig"] = LvConfig;
//# sourceMappingURL=LvConfig.js.map