namespace App {
    /**
     * 场景基类
     */
    export class BaseScene {

        protected _layers: egret.DisplayObjectContainer[];

        /**
         * 构造函数
         */
        public constructor() {
            // super();
            this._layers = [];
            // this._resLoaded = false;
        }

        /**
         * 当前场景需要的所有Layer，可重写改变顺序和所需的层
         */
        protected addLayers(): void {
            this.addLayer(GameLayers.Game_Bg);
            this.addLayer(GameLayers.Game_Main);
            this.addLayer(GameLayers.UI_Main);
            this.addLayer(GameLayers.UI_Popup);
            this.addLayer(GameLayers.UI_Guide);
            this.addLayer(GameLayers.UI_Message);
            this.addLayer(GameLayers.UI_Tips);
            this.addLayer(GameLayers.UI_Top);
        }

        /**
         * 进入Scene调用
         */
        public enter(...args: any[]): void {
            this.addLayers();
        }

        /**
         * 退出Scene调用
         */
        public exit(): void {
            this.removeAllLayer();
        }

        /**
         * 添加一个Layer到舞台
         * @param layer
         */
        public addLayer(layer: egret.DisplayObjectContainer): void {
            // if (layer instanceof BaseSpriteLayer) {
            let stage = StageUtils.getStage();
            stage.addChild(layer);
            this._layers.push(layer);
            // }
            // else if (layer instanceof BaseEuiLayer) {
            //     StageUtils.getInstance().getUIStage().addChild(layer);
            //     this._layers.push(layer);
            // }
            layer.width = layer.parent.width;
            layer.height = layer.parent.height;
        }

        /**
         * 添加一个Layer到舞台
         * @param layer
         * @param index
         */
        public addLayerAt(layer: egret.DisplayObjectContainer, index: number): void {
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
        }

        /**
         * 在舞台移除一个Layer
         * @param layer
         */
        public removeLayer(layer: egret.DisplayObjectContainer): void {
            // if (layer instanceof BaseSpriteLayer) {
            StageUtils.getStage().removeChild(layer);
            this._layers.splice(this._layers.indexOf(layer), 1);
            // }
            // else if (layer instanceof BaseEuiLayer) {
            //     StageUtils.getInstance().getUIStage().removeChild(layer);
            //     this._layers.splice(this._layers.indexOf(layer), 1);
            // }
        }

        /**
         * Layer中移除所有
         * @param layer
         */
        public layerRemoveAllChildren(layer: egret.DisplayObjectContainer): void {
            layer.removeChildren();
            // if (layer instanceof GameLayer.BaseSpriteLayer) {
            //     layer.removeChildren();
            // }
            // else if (layer instanceof GameLayer.BaseEuiLayer) {
            //     (<GameLayer.BaseEuiLayer>layer).removeChildren();
            // }
        }

        /**
         * 移除所有Layer
         */
        public removeAllLayer(): void {
            while (this._layers.length) {
                let layer: egret.DisplayObjectContainer = this._layers[0];
                this.layerRemoveAllChildren(layer);
                this.removeLayer(layer);
            }
        }
    }

}