var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var PublicConfig = (function () {
    function PublicConfig() {
    }
    PublicConfig.prototype.attrs = function () {
        return ["cardGroupCount", "maxRubbishCount", "maxHandCardCount", "maxGroupCardCount"];
    };
    return PublicConfig;
}());
__reflect(PublicConfig.prototype, "PublicConfig");
window["PublicConfig"] = PublicConfig;
//# sourceMappingURL=PublicConfig.js.map