var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var HttpModel = (function (_super) {
    __extends(HttpModel, _super);
    function HttpModel() {
        var _this = _super.call(this) || this;
        _this.httpAPI = new MiniGameHttpAPI();
        return _this;
    }
    Object.defineProperty(HttpModel.prototype, "serverTimestamp", {
        get: function () {
            return this._serverTs_ms + Math.floor((egret.getTimer() - this._loginTs_ms) * 0.001);
        },
        set: function (value) {
            this._loginTs_ms = egret.getTimer();
            this._serverTs_ms = value;
        },
        enumerable: true,
        configurable: true
    });
    return HttpModel;
}(VoyaMVC.Model));
