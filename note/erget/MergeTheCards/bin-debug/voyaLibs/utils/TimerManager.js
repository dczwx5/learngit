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
var TimerManager = (function () {
    function TimerManager() {
        this.iFps_time = 16.666; //每秒60帧处理
        if (TimerManager.s_instance) {
            throw new Error('单例类不可实例化');
        }
        egret.startTick(this.onTick, this);
        this.tickList = [];
    }
    TimerManager.prototype.onTick = function (timeStamp) {
        var dataList = this.tickList;
        for (var i = 0, iLen = dataList.length; i < iLen; i++) {
            var data = dataList[i];
            if (data && data.isValid) {
                if ((timeStamp - data.timestamp) >= data.delay) {
                    data.timestamp = timeStamp;
                    data.count++;
                    if (data.callback) {
                        // var t: number = egret.getTimer();
                        data.callback.call(data.thisObj, data.clone());
                        // var t1: number = egret.getTimer();
                        // if (MapManager.instance.isInited && t1 - t > 2) {
                        // 	alert('计时器耗时~~~~~~~~~~~~'+(t1 - t));
                        // 	alert(data.callback)
                        // 	// trace(`tick回调耗时:${t1 - t}`);
                        // }
                    }
                    if (data.count == data.maxCount) {
                        data.isValid = false;
                    }
                }
            }
        }
        var index = dataList.length;
        while (index > 0) {
            var data = dataList[index - 1];
            if (!data.isValid) {
                dataList.splice(index - 1, 1);
            }
            index--;
        }
        return false;
    };
    TimerManager.prototype.addTick = function (delay, replayCount, callback, thisObj) {
        var args = [];
        for (var _i = 4; _i < arguments.length; _i++) {
            args[_i - 4] = arguments[_i];
        }
        var dataList = this.tickList;
        if (dataList) {
            for (var i = 0, iLen = dataList.length; i < iLen; i++) {
                var data = dataList[i];
                if (data.callback == callback && data.thisObj == thisObj && data.delay == delay) {
                    if (!data.isValid) {
                        data.isValid = true;
                        data.delay = delay;
                        data.count = 0;
                        data.maxCount = replayCount <= 0 ? Number.MAX_VALUE : replayCount;
                        data.callback = callback;
                        data.thisObj = thisObj;
                        data.args = args;
                        data.timestamp = egret.getTimer();
                    }
                    return;
                }
            }
        }
        else {
            dataList = [];
            this.tickList = dataList;
        }
        var tick = new TickData();
        tick.delay = delay;
        tick.count = 0;
        tick.maxCount = replayCount <= 0 ? Number.MAX_VALUE : replayCount;
        tick.callback = callback;
        tick.thisObj = thisObj;
        tick.args = args;
        tick.timestamp = egret.getTimer();
        tick.isValid = true;
        dataList.push(tick);
    };
    TimerManager.prototype.hasTick = function (callback, thisObj) {
        var dataList = this.tickList;
        if (dataList) {
            var tickData = void 0;
            for (var i = 0, iLen = dataList.length; i < iLen; i++) {
                tickData = dataList[i];
                if (tickData.callback == callback && tickData.thisObj == thisObj) {
                    return true;
                }
            }
        }
        return false;
    };
    TimerManager.prototype.removeTick = function (callback, thisObj) {
        var dataList = this.tickList;
        if (dataList) {
            var tickData = void 0;
            for (var i = 0, iLen = dataList.length; i < iLen; i++) {
                tickData = dataList[i];
                if (tickData.callback == callback && tickData.thisObj == thisObj) {
                    tickData.isValid = false;
                    return;
                }
            }
        }
    };
    TimerManager.prototype.removeTicks = function (thisObj) {
        var dataList = this.tickList;
        if (dataList) {
            var tickData = void 0;
            for (var i = 0, iLen = dataList.length; i < iLen; i++) {
                tickData = dataList[i];
                if (tickData.thisObj == thisObj) {
                    tickData.isValid = false;
                }
            }
        }
    };
    TimerManager.prototype.removeAllTicks = function () {
        this.tickList.length = 0;
    };
    Object.defineProperty(TimerManager, "instance", {
        get: function () {
            if (TimerManager.s_instance == null) {
                TimerManager.s_instance = new TimerManager();
            }
            return TimerManager.s_instance;
        },
        enumerable: true,
        configurable: true
    });
    TimerManager.hasTick = function (callback, thisObj) {
        return TimerManager.instance.hasTick(callback, thisObj);
    };
    TimerManager.addTick = function (delay, replayCount, callback, thisObj) {
        var args = [];
        for (var _i = 4; _i < arguments.length; _i++) {
            args[_i - 4] = arguments[_i];
        }
        TimerManager.instance.addTick(delay, replayCount, callback, thisObj, args);
    };
    TimerManager.removeTick = function (callback, thisObj) {
        TimerManager.instance.removeTick(callback, thisObj);
    };
    TimerManager.removeTicks = function (thisObj) {
        TimerManager.instance.removeTicks(thisObj);
    };
    TimerManager.removeAllTicks = function () {
        TimerManager.instance.removeAllTicks();
    };
    //delay :ms
    TimerManager.doTimer = function (delay, replayCount, callback, thisObj) {
        var args = [];
        for (var _i = 4; _i < arguments.length; _i++) {
            args[_i - 4] = arguments[_i];
        }
        TimerManager.instance.addTick(delay, replayCount, callback, thisObj, args);
    };
    TimerManager.doFrame = function (delay, replayCount, callback, thisObj) {
        var args = [];
        for (var _i = 4; _i < arguments.length; _i++) {
            args[_i - 4] = arguments[_i];
        }
        delay = delay * TimerManager.instance.iFps_time;
        TimerManager.instance.addTick(delay, replayCount, callback, thisObj, args);
    };
    TimerManager.remove = function (callback, thisObj) {
        TimerManager.instance.removeTick(callback, thisObj);
    };
    TimerManager.removes = function (thisObj) {
        TimerManager.instance.removeTicks(thisObj);
    };
    TimerManager.removeAll = function () {
        TimerManager.instance.removeAllTicks();
    };
    return TimerManager;
}());
var TickData = (function (_super) {
    __extends(TickData, _super);
    function TickData() {
        return _super.call(this) || this;
    }
    TickData.prototype.clone = function () {
        var data = new TickData();
        data.delay = this.delay;
        data.count = this.count;
        data.maxCount = this.maxCount;
        data.callback = this.callback;
        data.thisObj = this.thisObj;
        data.args = this.args;
        data.isValid = this.isValid;
        return data;
    };
    return TickData;
}(egret.HashObject));
