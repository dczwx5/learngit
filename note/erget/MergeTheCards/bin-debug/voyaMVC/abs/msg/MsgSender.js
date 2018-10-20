var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VoyaMVC;
(function (VoyaMVC) {
    var MsgSender = (function () {
        function MsgSender() {
            this.msgHandlerMap = {};
        }
        MsgSender.prototype.sendMsg = function (msg) {
            var msgName = getClassName(msg);
            var handlers = this.msgHandlerMap[msgName];
            if (handlers && handlers.length > 0) {
                for (var i = 0; i < handlers.length; i++) {
                    var handlerVo = handlers[i];
                    handlerVo.handler.call(handlerVo.thisObj, msg);
                }
            }
            msg.restore();
        };
        MsgSender.prototype.regMsg = function (msgClass, handler, thisObj, checkExist) {
            if (checkExist === void 0) { checkExist = false; }
            var msgName = getClassName(msgClass);
            var handlers = this.msgHandlerMap[msgName];
            if (!handlers) {
                this.msgHandlerMap[msgName] = [];
            }
            if (checkExist) {
                if (!this.existMsgHandler(msgClass, handler, thisObj)) {
                    this.msgHandlerMap[msgName].push({ handler: handler, thisObj: thisObj });
                }
            }
            else {
                this.msgHandlerMap[msgName].push({ handler: handler, thisObj: thisObj });
            }
        };
        MsgSender.prototype.unregMsg = function (msgClass, handler, thisObj) {
            if (thisObj === void 0) { thisObj = null; }
            var msgName = getClassName(msgClass);
            var handlers = this.msgHandlerMap[msgName];
            if (handlers && handlers.length > 0) {
                if (handler) {
                    var h = void 0;
                    for (var i = 0; i < handlers.length; i++) {
                        h = handlers[i];
                        if (h.handler == handler) {
                            if (thisObj) {
                                if (h.thisObj == thisObj) {
                                    handlers.splice(i--, 1);
                                }
                            }
                            else {
                                handlers.splice(i--, 1);
                            }
                        }
                    }
                }
            }
        };
        MsgSender.prototype.existMsgHandler = function (msgClass, handler, thisObj) {
            if (handler === void 0) { handler = null; }
            if (thisObj === void 0) { thisObj = null; }
            var msgName = getClassName(msgClass);
            var handlers = this.msgHandlerMap[msgName];
            var result = false;
            if (handlers && handlers.length > 0) {
                if (handler) {
                    var h = void 0;
                    for (var i = 0, l = handlers.length; i < l; i++) {
                        h = handlers[i];
                        if (h.handler == handler) {
                            if (thisObj) {
                                if (h.thisObj == thisObj) {
                                    result = true;
                                    break;
                                }
                            }
                            else {
                                result = true;
                                break;
                            }
                        }
                    }
                }
                else {
                    result = true;
                }
            }
            return result;
        };
        return MsgSender;
    }());
    VoyaMVC.MsgSender = MsgSender;
    __reflect(MsgSender.prototype, "VoyaMVC.MsgSender", ["VoyaMVC.IMsgSender"]);
})(VoyaMVC || (VoyaMVC = {}));
//# sourceMappingURL=MsgSender.js.map