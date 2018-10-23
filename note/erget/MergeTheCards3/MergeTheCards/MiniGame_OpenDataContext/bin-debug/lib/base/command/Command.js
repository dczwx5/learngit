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
        _this.eventDispatcher = new egret.EventDispatcher();
        return _this;
    }
    Object.defineProperty(Command, "COMMAND_COMPLETE", {
        get: function () {
            return "commandComplete";
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(Command, "COMMAND_ABORT", {
        get: function () {
            return "commandAbort";
        },
        enumerable: true,
        configurable: true
    });
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
     * @param abort 是否是被中断的
     */
    Command.prototype.closeAsync = function (abort) {
        if (abort === void 0) { abort = false; }
        if (!this._isOpened)
            return;
        this.clear();
        this.context = null;
        this._isOpened = false;
        this.dispatchEvent(egret.Event.create(egret.Event, abort ? Command.COMMAND_ABORT : Command.COMMAND_COMPLETE));
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
    Command.prototype.addEventListener = function (type, listener, thisObject, useCapture, priority) {
        this.eventDispatcher.addEventListener(type, listener, thisObject, useCapture, priority);
    };
    Command.prototype.once = function (type, listener, thisObject, useCapture, priority) {
        this.eventDispatcher.once(type, listener, thisObject, useCapture, priority);
    };
    Command.prototype.removeEventListener = function (type, listener, thisObject, useCapture) {
        this.eventDispatcher.removeEventListener(type, listener, thisObject, useCapture);
    };
    Command.prototype.hasEventListener = function (type) {
        return this.eventDispatcher.hasEventListener(type);
    };
    Command.prototype.dispatchEvent = function (event) {
        return this.eventDispatcher.dispatchEvent(event);
    };
    Command.prototype.willTrigger = function (type) {
        return this.eventDispatcher.willTrigger(type);
    };
    return Command;
}(CacheableClass));
__reflect(Command.prototype, "Command", ["ICommand", "egret.IEventDispatcher"]);
//# sourceMappingURL=Command.js.map