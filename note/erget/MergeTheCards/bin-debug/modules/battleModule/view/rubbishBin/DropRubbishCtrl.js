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
var DropRubbishCtrl = (function (_super) {
    __extends(DropRubbishCtrl, _super);
    function DropRubbishCtrl() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    DropRubbishCtrl.prototype.checkEnableDrop = function (dragItem) {
        return this.rubbishBin.rubbishCount < PublicConfigHelper.MAX_RUBBISH_COUNT;
    };
    Object.defineProperty(DropRubbishCtrl.prototype, "rubbishBin", {
        get: function () {
            return this.container;
        },
        enumerable: true,
        configurable: true
    });
    return DropRubbishCtrl;
}(DropCardContainerCtrl));
__reflect(DropRubbishCtrl.prototype, "DropRubbishCtrl");
//# sourceMappingURL=DropRubbishCtrl.js.map