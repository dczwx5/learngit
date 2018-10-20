var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var App;
(function (App) {
    var Logger = (function () {
        function Logger() {
            this['$log']
                = this['$warn']
                    = this['$error']
                        = function () { };
        }
        Logger.prototype.init = function () {
            this['$log'] = egret.log;
            this['$warn'] = egret.warn;
            this['$error'] = egret.error;
        };
        Logger.prototype.log = function (message) {
            var optionalParams = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                optionalParams[_i - 1] = arguments[_i];
            }
            this['$log'].apply(this, [message].concat(optionalParams));
        };
        Logger.prototype.warn = function (message) {
            var optionalParams = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                optionalParams[_i - 1] = arguments[_i];
            }
            this['$warn'].apply(this, [message].concat(optionalParams));
        };
        Logger.prototype.error = function (message) {
            var optionalParams = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                optionalParams[_i - 1] = arguments[_i];
            }
            this['$error'].apply(this, [message].concat(optionalParams));
        };
        return Logger;
    }());
    App.Logger = Logger;
    __reflect(Logger.prototype, "App.Logger");
})(App || (App = {}));
//# sourceMappingURL=Logger.js.map