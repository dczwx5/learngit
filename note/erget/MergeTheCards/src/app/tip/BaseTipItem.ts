namespace App {
    export class BaseTipItem extends eui.Component implements ITipItem, VL.ObjectCache.ICacheable {

        protected static readonly _cachePool = new VL.ObjectCache.ObjectPool(BaseTipItem);

        //Eui里创建的
        protected container: egret.DisplayObjectContainer;

        public readonly dg_onRestore: VL.Delegate;

        constructor() {
            super();
            this.dg_onRestore = new VL.Delegate();
            this.touchEnabled = this.touchChildren = false;
        }

        /**
         * 从对象池取出或创建出来的时候要做的事
         * @param args
         */
        public init(...args: any[]): BaseTipItem {
            return this;
        }

        public clear() {
            if (this.parent) {
                this.parent.removeChild(this);
            }
            this.dg_onRestore.boardcast(this);

            this.container.y = 0;
            this.container.alpha = 1;
        }

        /**
         * 放回对象池
         */
        public restore() {
            restore(this);
        }

        public onShow(...args: any[]) {
            egret.Tween.get(this.container).set({y: 0, alpha: 1})
                .to({y: -100}, 300, egret.Ease.circOut)
                .wait(700)
                .to({y: -200, alpha: 0}, 400, egret.Ease.circIn)
                .call(this.restore, this);
        }

        protected get cachePool(): VL.ObjectCache.ObjectPool {
            return BaseTipItem._cachePool;
        }


        // public get height():number{
        //     return this.container.height;
        // }
        // public get width():number{
        //     return this.container.width;
        // }
    }
}