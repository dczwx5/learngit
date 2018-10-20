var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var App;
(function (App) {
    /**
     * 场景基类
     */
    var BaseScene = (function () {
        /**
         * 构造函数
         */
        function BaseScene() {
            // super();
            this._layers = [];
            // this._resLoaded = false;
        }
        /**
         * 当前场景需要的所有Layer，可重写改变顺序和所需的层
         */
        BaseScene.prototype.addLayers = function () {
            this.addLayer(App.GameLayers.Game_Bg);
            this.addLayer(App.GameLayers.Game_Main);
            this.addLayer(App.GameLayers.UI_Main);
            this.addLayer(App.GameLayers.UI_Popup);
            this.addLayer(App.GameLayers.UI_Guide);
            this.addLayer(App.GameLayers.UI_Message);
            this.addLayer(App.GameLayers.UI_Tips);
            this.addLayer(App.GameLayers.UI_Top);
        };
        /**
         * 进入Scene调用
         */
        BaseScene.prototype.enter = function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i] = arguments[_i];
            }
            this.addLayers();
        };
        /**
         * 退出Scene调用
         */
        BaseScene.prototype.exit = function () {
            this.removeAllLayer();
        };
        /**
         * 添加一个Layer到舞台
         * @param layer
         */
        BaseScene.prototype.addLayer = function (layer) {
            // if (layer instanceof BaseSpriteLayer) {
            var stage = StageUtils.getStage();
            stage.addChild(layer);
            this._layers.push(layer);
            // }
            // else if (layer instanceof BaseEuiLayer) {
            //     StageUtils.getInstance().getUIStage().addChild(layer);
            //     this._layers.push(layer);
            // }
            layer.width = layer.parent.width;
            layer.height = layer.parent.height;
        };
        /**
         * 添加一个Layer到舞台
         * @param layer
         * @param index
         */
        BaseScene.prototype.addLayerAt = function (layer, index) {
            // if (layer instanceof BaseSpriteLayer) {
            StageUtils.getStage().addChildAt(layer, index);
            this._layers.push(layer);
            // }
            // else if (layer instanceof BaseEuiLayer) {
            //     StageUtils.getInstance().getUIStage().addChildAt(layer, index);
            //     this._layers.push(layer);
            // }
            layer.width = layer.parent.width;
            layer.height = layer.parent.height;
        };
        /**
         * 在舞台移除一个Layer
         * @param layer
         */
        BaseScene.prototype.removeLayer = function (layer) {
            // if (layer instanceof BaseSpriteLayer) {
            StageUtils.getStage().removeChild(layer);
            this._layers.splice(this._layers.indexOf(layer), 1);
            // }
            // else if (layer instanceof BaseEuiLayer) {
            //     StageUtils.getInstance().getUIStage().removeChild(layer);
            //     this._layers.splice(this._layers.indexOf(layer), 1);
            // }
        };
        /**
         * Layer中移除所有
         * @param layer
         */
        BaseScene.prototype.layerRemoveAllChildren = function (layer) {
            layer.removeChildren();
            // if (layer instanceof GameLayer.BaseSpriteLayer) {
            //     layer.removeChildren();
            // }
            // else if (layer instanceof GameLayer.BaseEuiLayer) {
            //     (<GameLayer.BaseEuiLayer>layer).removeChildren();
            // }
        };
        /**
         * 移除所有Layer
         */
        BaseScene.prototype.removeAllLayer = function () {
            while (this._layers.length) {
                var layer = this._layers[0];
                this.layerRemoveAllChildren(layer);
                this.removeLayer(layer);
            }
        };
        return BaseScene;
    }());
    App.BaseScene = BaseScene;
    __reflect(BaseScene.prototype, "App.BaseScene");
})(App || (App = {}));
//# sourceMappingURL=BaseScene.js.map