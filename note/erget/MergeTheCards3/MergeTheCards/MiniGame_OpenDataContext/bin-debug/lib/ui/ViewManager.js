var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var ViewManager = (function () {
    // private static _instance:ViewManager;
    // public static get instance():ViewManager{
    //     if(!this._instance){
    //         this._instance = new ViewManager();
    //     }
    //     return this._instance;
    // }
    function ViewManager() {
        // if(ViewManager._instance){
        //     throw new Error(`单利模式，别乱new~~`);
        // }
        this.openedViewList = {};
    }
    ViewManager.prototype.onOpenView = function (viewClass) {
        var className = getClassName(viewClass);
        var view;
        if (!this.openedViewList[className]) {
            view = new viewClass();
            this.openedViewList[className] = view;
        }
        else {
            view = this.openedViewList[className];
        }
        Main.stage.addChild(view);
        return view;
    };
    ViewManager.prototype.onCloseView = function (viewClass) {
        var className = getClassName(viewClass);
        var view = this.openedViewList[className];
        if (view) {
            view.parent.removeChild(view);
            delete this.openedViewList[className];
        }
    };
    ViewManager.prototype.onCloseAllView = function () {
        var view;
        for (var className in this.openedViewList) {
            view = this.openedViewList[className];
            view.parent.removeChild(view);
            delete this.openedViewList[className];
        }
    };
    return ViewManager;
}());
__reflect(ViewManager.prototype, "ViewManager");
//# sourceMappingURL=ViewManager.js.map