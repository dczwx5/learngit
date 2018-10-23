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
 * 命令组，可以按顺序执行队列里的命令
 */
var CommandGroup = (function (_super) {
    __extends(CommandGroup, _super);
    function CommandGroup() {
        // public static create(commands:Command[] = []):CommandGroup {
        //     return CacheableClass._cachePool.pop(CommandGroup).init(commands) as CommandGroup;
        // }
        var _this = _super !== null && _super.apply(this, arguments) || this;
        _this._cmdList = [];
        /**
         * 当前执行的命令在队列中的索引
         * @type {number}
         * @private
         */
        _this._currIdx = -1;
        return _this;
    }
    CommandGroup.prototype.init = function (commands) {
        if (commands === void 0) { commands = []; }
        var i, ilen;
        ilen = commands.length;
        for (i = 0; i < ilen; i++) {
            this.add(commands[i]);
        }
        return this;
    };
    /**
     * 往队列增加一条命令
     * @param cmd
     */
    CommandGroup.prototype.add = function (cmd) {
        if (this._cmdList.indexOf(cmd) < 0) {
            this._cmdList.push(cmd);
        }
        return this;
    };
    /**
     * 从队列移除指定命令
     * @param cmd
     */
    CommandGroup.prototype.remove = function (cmd) {
        var idx = this._cmdList.indexOf(cmd);
        if (idx > 0) {
            this._cmdList.splice(idx, 1);
        }
        return this;
    };
    CommandGroup.prototype.execute = function () {
        this.executeNext();
    };
    /**
     * 执行命令队列里的下一条命令
     */
    CommandGroup.prototype.executeNext = function () {
        if (this._cmdList[this._currIdx + 1] == null) {
            this.closeAsync();
            return;
        }
        this._currIdx++;
        var currCmd = this._cmdList[this._currIdx];
        this._currCmd = currCmd;
        currCmd.addEventListener(Command.COMMAND_ABORT, this.onSingleCmdAbort, this);
        currCmd.addEventListener(Command.COMMAND_COMPLETE, this.onSingleCmdComplete, this);
        if (currCmd.autoRestore) {
            currCmd.autoRestore = false;
        }
        currCmd.context = this.context;
        currCmd.openAsync();
    };
    /**
     * 命令队列里一条命令执行中断
     * @param e
     */
    CommandGroup.prototype.onSingleCmdAbort = function (e) {
        this._currCmd.removeEventListener(Command.COMMAND_ABORT, this.onSingleCmdAbort, this);
        this._currCmd.removeEventListener(Command.COMMAND_COMPLETE, this.onSingleCmdComplete, this);
        this.closeAsync(true);
    };
    /**
     * 命令队列里一条命令执行完毕
     * @param e
     */
    CommandGroup.prototype.onSingleCmdComplete = function (e) {
        this._currCmd.removeEventListener(Command.COMMAND_ABORT, this.onSingleCmdAbort, this);
        this._currCmd.removeEventListener(Command.COMMAND_COMPLETE, this.onSingleCmdComplete, this);
        if (this._currIdx == this._cmdList.length - 1) {
            this.closeAsync();
        }
        else {
            this.executeNext();
        }
    };
    CommandGroup.prototype.closeAsync = function (abort) {
        if (abort === void 0) { abort = false; }
        _super.prototype.closeAsync.call(this, abort);
        if (this._currCmd) {
            this._currCmd.removeEventListener(Command.COMMAND_ABORT, this.onSingleCmdAbort, this);
            this._currCmd.removeEventListener(Command.COMMAND_COMPLETE, this.onSingleCmdComplete, this);
        }
        this._currCmd = null;
        this._currIdx = -1;
    };
    /**
     * 清空命令队列
     */
    CommandGroup.prototype.clear = function (abort) {
        if (abort === void 0) { abort = false; }
        var i, ilen;
        ilen = this._cmdList.length;
        for (i = 0; i < ilen; i++) {
            this._cmdList[i].restore();
        }
        this._cmdList.length = 0;
    };
    return CommandGroup;
}(Command));
__reflect(CommandGroup.prototype, "CommandGroup");
window['CommandGroup'] = CommandGroup;
//# sourceMappingURL=CommandGroup.js.map