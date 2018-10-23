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
var DropCardContainerCtrl = (function (_super) {
    __extends(DropCardContainerCtrl, _super);
    function DropCardContainerCtrl() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    Object.defineProperty(DropCardContainerCtrl.prototype, "tarDragItemClass", {
        get: function () {
            return Card;
        },
        enumerable: true,
        configurable: true
    });
    return DropCardContainerCtrl;
}(VL.DragDrop.DropContainerCtrlBase));
__reflect(DropCardContainerCtrl.prototype, "DropCardContainerCtrl");
//# sourceMappingURL=DropCardContainerCtrl.js.map