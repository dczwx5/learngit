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
var RubbishBin = (function (_super) {
    __extends(RubbishBin, _super);
    function RubbishBin() {
        var _this = _super.call(this) || this;
        _this._isReady = false;
        _this._rubbishCount = 0;
        _this._skinId = 1;
        _this._needUpdate = false;
        _this.skinName = "RubbishBinSkin";
        _this.touchChildren = false;
        _this.touchEnabled = true;
        _this.dg_onDropIn = new VL.Delegate();
        _this.dropContainerCtrl = new DropRubbishCtrl(_this);
        return _this;
    }
    RubbishBin.prototype.childrenCreated = function () {
        _super.prototype.childrenCreated.call(this);
        this._isReady = true;
        this.updateShow();
        this.updateSkin();
        this.grp_cell.mask = this.rect_mask;
    };
    RubbishBin.prototype.activate = function (skinId) {
        app.dragDropManager.regDropContainer(this);
        this.dg_onDropIn.register(this.onDropIn, this);
        this._skinId = skinId;
        this.updateSkin();
    };
    RubbishBin.prototype.deactivate = function () {
        app.dragDropManager.regDropContainer(this);
        this.dg_onDropIn.unregister(this.onDropIn);
    };
    RubbishBin.prototype.checkHover = function (touchTarget) {
        var result = touchTarget == this;
        this.img_border.visible = result;
        // if(result){
        // 	this.filters = [DropEnableFilter.instance];
        // }else {
        // 	this.filters = [];
        // }
        return result;
    };
    RubbishBin.prototype.onDropIn = function () {
        this.img_border.visible = false;
        // this.filters = [];
    };
    RubbishBin.prototype.getRubbishCell = function (idx) {
        return this['cell' + idx];
    };
    RubbishBin.prototype.updateShow = function () {
        var _this = this;
        if (!this._isReady) {
            return;
        }
        if (!this._needUpdate) {
            this._needUpdate = true;
            egret.callLater(function () {
                var max = PublicConfigHelper.MAX_RUBBISH_COUNT;
                var cell;
                for (var i = 0; i < max; i++) {
                    cell = _this.getRubbishCell(i);
                    cell.isEmpty = i >= _this.rubbishCount;
                    cell.enableClear = i < _this.clearCellChance;
                }
                _this._needUpdate = false;
            }, this);
        }
    };
    RubbishBin.prototype.updateSkin = function () {
        if (this._isReady) {
            var max = PublicConfigHelper.MAX_RUBBISH_COUNT;
            for (var i = 0; i < max; i++) {
                this.getRubbishCell(i).skinId = this._skinId;
            }
        }
    };
    Object.defineProperty(RubbishBin.prototype, "rubbishCount", {
        get: function () {
            return this._rubbishCount;
        },
        set: function (value) {
            var max = PublicConfigHelper.MAX_RUBBISH_COUNT;
            value = Math.min(max, Math.max(value, 0));
            this._rubbishCount = value;
            this.updateShow();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(RubbishBin.prototype, "clearCellChance", {
        get: function () {
            return this._clearCellChance;
        },
        set: function (value) {
            var max = PublicConfigHelper.MAX_RUBBISH_COUNT;
            value = Math.min(max, Math.max(value, 0));
            this._clearCellChance = value;
            this.updateShow();
        },
        enumerable: true,
        configurable: true
    });
    return RubbishBin;
}(eui.Component));
__reflect(RubbishBin.prototype, "RubbishBin", ["eui.UIComponent", "egret.DisplayObject", "VL.DragDrop.IDropContainer"]);
window['RubbishBin'] = RubbishBin;
//# sourceMappingURL=RubbishBin.js.map