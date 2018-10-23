namespace VL.Command {
    /**
     * 命令组，可以按顺序执行队列里的命令
     */
    export class CommandGroup extends Command {

        private _cmdList: Command[] = [];

        /**
         * 当前执行的命令
         */
        private _currCmd: Command;
        /**
         * 当前执行的命令在队列中的索引
         * @type {number}
         * @private
         */
        private _currIdx: number = -1;


        public init(commands: Command[] = []): CommandGroup {
            let i: number, ilen: number;
            ilen = commands.length;
            for (i = 0; i < ilen; i++) {
                this.add(commands[i]);
            }
            return this;
        }

        /**
         * 往队列增加一条命令
         * @param cmd
         */
        public add(cmd: Command) {
            if (this._cmdList.indexOf(cmd) < 0) {
                this._cmdList.push(cmd);
            }
            return this;
        }

        /**
         * 从队列移除指定命令
         * @param cmd
         */
        public remove(cmd: Command) {
            let idx = this._cmdList.indexOf(cmd);
            if (idx > 0) {
                this._cmdList.splice(idx, 1);
            }
            return this;
        }

        protected execute() {
            this.executeNext();
        }

        /**
         * 执行命令队列里的下一条命令
         */
        protected executeNext() {
            if (this._cmdList[this._currIdx + 1] == null) {
                this.closeAsync();
                return;
            }

            this._currIdx++;
            let currCmd = this._cmdList[this._currIdx];
            this._currCmd = currCmd;
            

            currCmd.dg_commandCompleted.register(this.onSingleCmdCompleted, this);


            if (currCmd.autoRestore) {
                currCmd.autoRestore = false;
            }
            currCmd.openAsync();
        }

        protected onSingleCmdCompleted(params:{ isAbort: boolean, isRecursion:boolean }){
            this._currCmd.dg_commandCompleted.unregister(this.onSingleCmdCompleted);
            if(params.isAbort){
                this.closeAsync(params.isRecursion);
            }else {
                if (this._currIdx == this._cmdList.length - 1) {
                    this.closeAsync();
                } else {
                    this.executeNext();
                }
            }
        }

        public closeAsync(isRecursion:boolean = false) {
            if (!this.isOpened)
                return;

            if (this._currCmd ) {
                this._currCmd.dg_commandCompleted.unregister(this.onSingleCmdCompleted);
            }
            this._currCmd = null;
            this._currIdx = -1;

            this.clear();

            this._isOpened = false;
            this.dg_commandCompleted.boardcast({isAbort:isRecursion, isRecursion:isRecursion});

            if (this.autoRestore) {
                this.restore();
            }
        }

        /**
         * 清空命令队列
         */
        public clear() {
            let i: number, ilen: number;
            ilen = this._cmdList.length;
            for (i = 0; i < ilen; i++) {
                this._cmdList[i].restore();
            }
            this._cmdList.length = 0;
        }
    }
}