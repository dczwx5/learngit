namespace VL.Command {
    /**
     * 命令基类，主要用于执行逻辑，随创建随用
     */
    export abstract class Command extends VL.ObjectCache.CacheableClass implements ICommand {

        public readonly dg_commandCompleted: Delegate<{ isAbort: boolean, isRecursion: boolean }>;

        /**
         * 执行完毕时是否自动回收回对象池
         * @type {boolean}
         */
        protected _autoRestore: boolean = true;

        /**
         * 该命令是否已经打开
         * @type {boolean}
         * @private
         */
        protected _isOpened: boolean = false;


        constructor() {
            super();
            this.dg_commandCompleted = new Delegate<{ isAbort: boolean, isRecursion: boolean }>();
        }

        /**
         * 打开
         */
        public openAsync() {
            if (this._isOpened)
                return;
            this._isOpened = true;
            this.execute();
        }

        /**
         * 关闭
         * @param abort 是否中断所属命令组
         * @param isRecursion 是否递归继续中断下去， 为false只中断最近一层命令组，true就继续递归中断下去
         */
        public closeAsync(abort: boolean = false, isRecursion: boolean = false): void {
            if (!this._isOpened)
                return;
            this.clear();
            this._isOpened = false;

            this.dg_commandCompleted.boardcast({isAbort: abort, isRecursion: isRecursion});

            if (this.autoRestore) {
                this.restore();
            }
        }


        /** 立即执行打开并关闭 */
        public run(): void {
            this.openAsync();
            this.closeAsync();
        }

        /** 执行 */
        protected abstract execute();


        /**
         * 该命令是否已经执行完毕
         */
        public get isOpened() {
            return this._isOpened;
        }

        /**
         * 是否自动回收
         * @returns {boolean}
         */
        public get autoRestore(): boolean {
            return this._autoRestore;
        }

        public set autoRestore(value: boolean) {
            this._autoRestore = value;
        }
    }
}