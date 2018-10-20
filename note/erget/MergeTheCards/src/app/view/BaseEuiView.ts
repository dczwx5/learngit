namespace App {
    export abstract class BaseEuiView extends eui.Component implements App.IBaseView {

        public readonly dg_inited: VL.Delegate;

        protected _myParent: egret.DisplayObjectContainer;
        protected _isOpened: boolean = false;
        protected _isInited: boolean = false;

        public abstract readonly resources: string[];

        /**
         *
         * @param skinName 皮肤类名
         * @param parent 父级容器
         */
        public constructor(skinName:string, parent: egret.DisplayObjectContainer) {
            super();
            this.dg_inited = new VL.Delegate();
            this.skinName = skinName;
            this.myParent = parent;
        }

        protected createChildren() {
            super.createChildren();
            this.init();
        }

        protected async init() {
            if (this.resources.length > 0) {
                await this.loadRes();
            }
            this.onInit();
            this._isInited = true;
            this.dg_inited.boardcast();
        }

        protected async loadRes() {
            return new Promise(resolve => {
                app.resManager.loadResTask({
                    keys: this.resources,
                    taskName: getClassName(this),
                    onComplete: task => {
                        resolve();
                    }
                });
            })
        }

        protected abstract onInit();

        /**
         * 面板开启执行函数
         */
        public open(param:any = null) {
            StageUtils.getStage().addEventListener(egret.Event.RESIZE, this.onResize, this);
            this.addEventListener(egret.Event.RESIZE, this.onResize, this);
            this.updateLayout();
            this.addToParent();
            this._isOpened = true;
        }

        /**
         * 面板关闭执行函数
         */
        public close(param:any = null) {
            this.removeFromParent();
            this._isOpened = false;
            StageUtils.getStage().removeEventListener(egret.Event.RESIZE, this.onResize, this);
            this.removeEventListener(egret.Event.RESIZE, this.onResize, this);
        }

        private onResize(e: egret.Event) {
            this.updateLayout();
        }

        protected updateLayout() {
            this.width = StageUtils.getStageWidth();
            this.height = StageUtils.getStageHeight();
        }

        /**
         * 添加到父级
         */
        protected addToParent(): void {
            this._myParent.addChild(this);
        }

        /**
         * 从父级移除
         */
        protected removeFromParent(): void {
            if (this.parent) {
                this.parent.removeChild(this);
            }
        }

        /**
         * 销毁
         */
        public destroy(): void {
            this.onDestroy();
            this.removeFromParent();
            this._isInited = false;
        }

        protected abstract onDestroy();

        public set myParent(parent: egret.DisplayObjectContainer) {
            this._myParent = parent;
            if (this.isOpened) {
                this.addToParent();
            }
        }

        public get isOpened(): boolean {
            return this._isOpened;
        }

        public get isInited(): boolean {
            return this._isInited;
        }

        /**
         * 获取我的父级
         * @returns {egret.DisplayObjectContainer}
         */
        public get myParent(): egret.DisplayObjectContainer {
            return this._myParent;
        }


    }
}