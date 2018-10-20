var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var DragDrop;
    (function (DragDrop) {
        var DragItemCtrlBase = (function () {
            function DragItemCtrlBase(dragItem) {
                this._enableDrag = false;
                this.dg_DragBegin = new VL.Delegate();
                this.dg_DragEnd = new VL.Delegate();
                this.dragItem = dragItem;
            }
            DragItemCtrlBase.prototype.addEvent = function () {
                this._dragItem.addEventListener(egret.TouchEvent.TOUCH_BEGIN, this.onTouchBegin, this);
            };
            DragItemCtrlBase.prototype.removeEvent = function () {
                this._dragItem.removeEventListener(egret.TouchEvent.TOUCH_BEGIN, this.onTouchBegin, this);
            };
            DragItemCtrlBase.prototype.onTouchBegin = function (e) {
                this.startDrag(e.localX, e.localY, e.stageX, e.stageY);
            };
            DragItemCtrlBase.prototype.startDrag = function (localX, localY, stageX, stageY) {
                var comp = this._dragItem;
                this.backupBeforeDrag();
                this._offsetX = localX;
                this._offsetY = localY;
                var stage = StageUtils.getStage();
                stage.addChild(comp);
                comp.x = stageX - localX;
                comp.y = stageY - localY;
                comp.touchEnabled = false;
                stage.addEventListener(egret.TouchEvent.TOUCH_MOVE, this.onTouchMove, this);
                stage.addEventListener(egret.TouchEvent.TOUCH_END, this.onTouchCancel, this);
                stage.addEventListener(egret.TouchEvent.TOUCH_CANCEL, this.onTouchCancel, this);
                this._isDragging = true;
                this.dg_DragBegin.boardcast(this.dragItem);
            };
            DragItemCtrlBase.prototype.stopDrag = function () {
                var comp = this._dragItem;
                this._offsetX = null;
                this._offsetY = null;
                var stage = StageUtils.getStage();
                stage.removeEventListener(egret.TouchEvent.TOUCH_MOVE, this.onTouchMove, this);
                stage.removeEventListener(egret.TouchEvent.TOUCH_END, this.onTouchCancel, this);
                stage.removeEventListener(egret.TouchEvent.TOUCH_CANCEL, this.onTouchCancel, this);
                this._isDragging = false;
                comp.touchEnabled = true;
                this.dg_DragEnd.boardcast(this.dragItem);
            };
            // protected rollBackBeforDrag(){
            //     let comp = this._dragItem;
            //     this._origParent.addChild(comp);
            //     comp.x = this._origX;
            //     comp.y = this._origY;
            //     this._origX = null;
            //     this._origY = null;
            //     this._origParent = null;
            // }
            DragItemCtrlBase.prototype.onTouchMove = function (e) {
                var comp = this._dragItem;
                comp.x = e.stageX - this._offsetX;
                comp.y = e.stageY - this._offsetY;
            };
            DragItemCtrlBase.prototype.onTouchCancel = function (e) {
                this.stopDrag();
            };
            DragItemCtrlBase.prototype.onDropTo = function (container) {
                container ? this.onDropSecceed(container) : this.onDropFaild();
            };
            DragItemCtrlBase.prototype.onDropFaild = function () {
                this.rollBackBeforDrag();
            };
            Object.defineProperty(DragItemCtrlBase.prototype, "dragItem", {
                get: function () {
                    return this._dragItem;
                },
                set: function (value) {
                    if (this._dragItem == value) {
                        return;
                    }
                    if (this.isDragging) {
                        this.stopDrag();
                    }
                    this._dragItem = value;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(DragItemCtrlBase.prototype, "isDragging", {
                get: function () {
                    return this._isDragging;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(DragItemCtrlBase.prototype, "enableDrag", {
                get: function () {
                    return this._enableDrag;
                },
                set: function (value) {
                    if (this.enableDrag == value) {
                        return;
                    }
                    this.removeEvent();
                    this._enableDrag = value;
                    if (value) {
                        this.addEvent();
                    }
                    else {
                        this.stopDrag();
                    }
                },
                enumerable: true,
                configurable: true
            });
            return DragItemCtrlBase;
        }());
        DragDrop.DragItemCtrlBase = DragItemCtrlBase;
        __reflect(DragItemCtrlBase.prototype, "VL.DragDrop.DragItemCtrlBase", ["VL.DragDrop.IDragItemCtrl"]);
    })(DragDrop = VL.DragDrop || (VL.DragDrop = {}));
})(VL || (VL = {}));
//# sourceMappingURL=DragItemCtrlBase.js.map