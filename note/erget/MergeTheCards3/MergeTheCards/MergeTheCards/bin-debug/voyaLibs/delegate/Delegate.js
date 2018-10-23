var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    /**
     * 多播委托
     */
    var Delegate = (function () {
        function Delegate() {
            this._funList = [];
            this._thisArgList = [];
        }
        Object.defineProperty(Delegate.prototype, "count", {
            /** 函数总数 */
            get: function () {
                return this._funList.length;
            },
            enumerable: true,
            configurable: true
        });
        /**
         * 是否存在参数目标函数。
         * @param fun 目标函数。
         * @return 存在?
         */
        Delegate.prototype.has = function (fun) {
            return this._funList.indexOf(fun) != -1;
        };
        /**
         * 注册函数。
         * @param fun 目标函数。
         * @param thisArg This指针。
         */
        Delegate.prototype.register = function (fun, thisArg) {
            if (this.has(fun) || !fun)
                return;
            this._funList.push(fun);
            this._thisArgList.push(thisArg);
        };
        /**
         * 注销函数。
         * @param fun 目标函数。
         */
        Delegate.prototype.unregister = function (fun) {
            if (!this.has(fun))
                return;
            var index = this._funList.indexOf(fun);
            this._funList.splice(index, 1);
            this._thisArgList.splice(index, 1);
        };
        /**
         * 清空所有函数。
         */
        Delegate.prototype.clear = function () {
            this._funList.length = 0;
            this._thisArgList.length = 0;
        };
        /**
         * 向所有注册函数广播。
         * @param params 任意广播信息
         */
        Delegate.prototype.boardcast = function (params) {
            for (var i = 0; i < this._funList.length; i++) {
                var fun = this._funList[i];
                var thisArg = this._thisArgList[i];
                if (thisArg) {
                    fun.call(thisArg, params);
                }
                else {
                    fun(params);
                }
            }
        };
        return Delegate;
    }());
    VL.Delegate = Delegate;
    __reflect(Delegate.prototype, "VL.Delegate");
})(VL || (VL = {}));
//# sourceMappingURL=Delegate.js.map