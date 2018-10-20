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
    (function (Command_1) {
        /**
         * 命令基类，主要用于执行逻辑，随创建随用
         */
        var Command = (function (_super) {
            __extends(Command, _super);
            function Command() {
                var _this = _super.call(this) || this;
                /**
                 * 执行完毕时是否自动回收回对象池
                 * @type {boolean}
                 */
                _this._autoRestore = true;
                /**
                 * 该命令是否已经打开
                 * @type {boolean}
                 * @private
                 */
                _this._isOpened = false;
                _this.dg_commandCompleted = new VL.Delegate();
                return _this;
            }
            /**
             * 打开
             */
            Command.prototype.openAsync = function () {
                if (this._isOpened)
                    return;
                this._isOpened = true;
                this.execute();
            };
            /**
             * 关闭
             * @param abort 是否中断所属命令组
             * @param isRecursion 是否递归继续中断下去， 为false只中断最近一层命令组，true就继续递归中断下去
             */
            Command.prototype.closeAsync = function (abort, isRecursion) {
                if (abort === void 0) { abort = false; }
                if (isRecursion === void 0) { isRecursion = false; }
                if (!this._isOpened)
                    return;
                this.clear();
                this._isOpened = false;
                this.dg_commandCompleted.boardcast({ isAbort: abort, isRecursion: isRecursion });
                if (this.autoRestore) {
                    this.restore();
                }
            };
            /** 立即执行打开并关闭 */
            Command.prototype.run = function () {
                this.openAsync();
                this.closeAsync();
            };
            Object.defineProperty(Command.prototype, "isOpened", {
                /**
                 * 该命令是否已经执行完毕
                 */
                get: function () {
                    return this._isOpened;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(Command.prototype, "autoRestore", {
                /**
                 * 是否自动回收
                 * @returns {boolean}
                 */
                get: function () {
                    return this._autoRestore;
                },
                set: function (value) {
                    this._autoRestore = value;
                },
                enumerable: true,
                configurable: true
            });
            return Command;
        }(VL.ObjectCache.CacheableClass));
        Command_1.Command = Command;
        __reflect(Command.prototype, "VL.Command.Command", ["VL.Command.ICommand"]);
    })(Command = VL.Command || (VL.Command = {}));
})(VL || (VL = {}));
//# sourceMappingURL=Command.js.map