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
var VL;
(function (VL) {
    var Command;
    (function (Command) {
        /**
         * 方法调用委托
         */
        var DelegateCommand = (function (_super) {
            __extends(DelegateCommand, _super);
            function DelegateCommand() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            DelegateCommand.prototype.init = function (fun, thisArg, argsArr) {
                if (thisArg === void 0) { thisArg = null; }
                if (argsArr === void 0) { argsArr = null; }
                this._fun = fun;
                this._argsArr = argsArr;
                this._thisArg = thisArg;
                return this;
            };
            DelegateCommand.prototype.execute = function () {
                if (this._fun != null) {
                    this._fun.apply(this._thisArg, this._argsArr);
                }
                this.closeAsync();
            };
            DelegateCommand.prototype.clear = function () {
                this._fun = null;
                this._thisArg = null;
                this._argsArr = null;
            };
            return DelegateCommand;
        }(Command.Command));
        __reflect(DelegateCommand.prototype, "DelegateCommand");
    })(Command = VL.Command || (VL.Command = {}));
})(VL || (VL = {}));
//# sourceMappingURL=DelegateCommand.js.map