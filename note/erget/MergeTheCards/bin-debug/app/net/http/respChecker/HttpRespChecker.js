var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var App;
(function (App) {
    var HttpRespChecker = (function () {
        function HttpRespChecker() {
            this.dg_checkHttpResp = new VL.Delegate();
        }
        /**
         * 这个是HTTP业务逻辑层的错误，一般由后端返回错误码
         */
        HttpRespChecker.prototype.check = function (packData) {
            // let checkResult: VL.Net.IHttpRespCheckResult = {pass: true};
            var checkResult = this.onCheck(packData);
            this.dg_checkHttpResp.boardcast(checkResult);
            return checkResult;
        };
        return HttpRespChecker;
    }());
    App.HttpRespChecker = HttpRespChecker;
    __reflect(HttpRespChecker.prototype, "App.HttpRespChecker");
})(App || (App = {}));
//# sourceMappingURL=HttpRespChecker.js.map