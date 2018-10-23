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
var DragCardCtrl = (function (_super) {
    __extends(DragCardCtrl, _super);
    function DragCardCtrl() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    DragCardCtrl.prototype.onDropSecceed = function (container) {
    };
    DragCardCtrl.prototype.startDrag = function (localX, localY, stageX, stageY) {
        _super.prototype.startDrag.call(this, localX, localY, stageX, stageY);
        this.card.alpha = 0.5;
    };
    DragCardCtrl.prototype.stopDrag = function () {
        _super.prototype.stopDrag.call(this);
        this.card.alpha = 1;
    };
    DragCardCtrl.prototype.backupBeforeDrag = function () {
        this.origParent = this.dragItem.parent;
        this.origX = this.dragItem.x;
        this.origY = this.dragItem.y;
    };
    DragCardCtrl.prototype.rollBackBeforDrag = function () {
        this.dragItem.x = this.origX;
        this.dragItem.y = this.origY;
        this.origParent.addChild(this.dragItem);
    };
    Object.defineProperty(DragCardCtrl.prototype, "card", {
        get: function () {
            return this.dragItem;
        },
        enumerable: true,
        configurable: true
    });
    return DragCardCtrl;
}(VL.DragDrop.DragItemCtrlBase));
__reflect(DragCardCtrl.prototype, "DragCardCtrl");
//# sourceMappingURL=DragCardCtrl.js.map