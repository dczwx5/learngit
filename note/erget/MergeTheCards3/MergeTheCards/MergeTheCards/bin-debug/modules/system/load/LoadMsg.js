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
var LoadMsg;
(function (LoadMsg) {
    var Enum_LoadStyle;
    (function (Enum_LoadStyle) {
        Enum_LoadStyle[Enum_LoadStyle["VIEW"] = 0] = "VIEW";
        Enum_LoadStyle[Enum_LoadStyle["MASK"] = 1] = "MASK";
        Enum_LoadStyle[Enum_LoadStyle["NONE"] = 2] = "NONE";
    })(Enum_LoadStyle = LoadMsg.Enum_LoadStyle || (LoadMsg.Enum_LoadStyle = {}));
    var LoadRes = (function (_super) {
        __extends(LoadRes, _super);
        function LoadRes() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return LoadRes;
    }(VoyaMVC.Msg));
    LoadMsg.LoadRes = LoadRes;
    __reflect(LoadRes.prototype, "LoadMsg.LoadRes");
    var AddEasyLoadingTask = (function (_super) {
        __extends(AddEasyLoadingTask, _super);
        function AddEasyLoadingTask() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return AddEasyLoadingTask;
    }(VoyaMVC.Msg));
    LoadMsg.AddEasyLoadingTask = AddEasyLoadingTask;
    __reflect(AddEasyLoadingTask.prototype, "LoadMsg.AddEasyLoadingTask");
    var OpenLoadingView = (function (_super) {
        __extends(OpenLoadingView, _super);
        function OpenLoadingView() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OpenLoadingView;
    }(VoyaMVC.Msg));
    LoadMsg.OpenLoadingView = OpenLoadingView;
    __reflect(OpenLoadingView.prototype, "LoadMsg.OpenLoadingView");
    var CloseLoadingView = (function (_super) {
        __extends(CloseLoadingView, _super);
        function CloseLoadingView() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return CloseLoadingView;
    }(VoyaMVC.Msg));
    LoadMsg.CloseLoadingView = CloseLoadingView;
    __reflect(CloseLoadingView.prototype, "LoadMsg.CloseLoadingView");
    var OnTaskProgress = (function (_super) {
        __extends(OnTaskProgress, _super);
        function OnTaskProgress() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OnTaskProgress;
    }(VoyaMVC.Msg));
    LoadMsg.OnTaskProgress = OnTaskProgress;
    __reflect(OnTaskProgress.prototype, "LoadMsg.OnTaskProgress");
    var OnTaskCancel = (function (_super) {
        __extends(OnTaskCancel, _super);
        function OnTaskCancel() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OnTaskCancel;
    }(VoyaMVC.Msg));
    LoadMsg.OnTaskCancel = OnTaskCancel;
    __reflect(OnTaskCancel.prototype, "LoadMsg.OnTaskCancel");
    var OnTaskComplete = (function (_super) {
        __extends(OnTaskComplete, _super);
        function OnTaskComplete() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OnTaskComplete;
    }(VoyaMVC.Msg));
    LoadMsg.OnTaskComplete = OnTaskComplete;
    __reflect(OnTaskComplete.prototype, "LoadMsg.OnTaskComplete");
})(LoadMsg || (LoadMsg = {}));
//# sourceMappingURL=LoadMsg.js.map