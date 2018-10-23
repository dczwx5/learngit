var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var App;
(function (App) {
    var EasyLoadingManager = (function () {
        function EasyLoadingManager() {
            this._caseIDSeed = 0;
            this.loadingCaseList = [];
            this.loadingPanel = new EasyLoadingPanel();
        }
        EasyLoadingManager.prototype.getNewCaseID = function () {
            if (this._caseIDSeed >= 1000000) {
                this._caseIDSeed = 0;
            }
            return "" + this._caseIDSeed++;
        };
        /**
         * 增加一个需要显示loading的事务
         * @param [caseId]
         * @param [text]
         * @returns {string} 返回事务ID
         */
        EasyLoadingManager.prototype.add = function (caseId, text) {
            if (caseId === void 0) { caseId = null; }
            if (text === void 0) { text = null; }
            var caseID = caseId || this.getNewCaseID();
            this.loadingCaseList.push(caseID);
            if (!this.isShow) {
                this.show(text);
            }
            return caseID;
        };
        /**
         * 根据事物ID移除一个显示loading的事物，如果没有其他需要显示loading的事物就关闭loading
         * @param caseID
         */
        EasyLoadingManager.prototype.remove = function (caseID) {
            var idx = this.loadingCaseList.indexOf(caseID);
            if (idx == -1) {
                return;
            }
            this.loadingCaseList.splice(idx, 1);
            if (this.loadingCaseList.length <= 0) {
                this.hide();
            }
        };
        /**
         * 关闭loading并清空所有case
         */
        EasyLoadingManager.prototype.clear = function () {
            this.loadingCaseList.length = 0;
            this.hide();
        };
        EasyLoadingManager.prototype.show = function (text) {
            if (text === void 0) { text = null; }
            this.loadingPanel.show(App.GameLayers.UI_Top, text);
        };
        EasyLoadingManager.prototype.hide = function () {
            this.loadingPanel.hide();
        };
        Object.defineProperty(EasyLoadingManager.prototype, "isShow", {
            /**
             * 是否在展示中
             * @returns {boolean}
             */
            get: function () {
                return this.loadingPanel.isShow;
            },
            enumerable: true,
            configurable: true
        });
        return EasyLoadingManager;
    }());
    App.EasyLoadingManager = EasyLoadingManager;
    __reflect(EasyLoadingManager.prototype, "App.EasyLoadingManager");
})(App || (App = {}));
// window['EasyLoadingManager']=EasyLoadingManager;
//# sourceMappingURL=EasyLoadingManager.js.map