/**
 * 命令组，可以按顺序执行队列里的命令
 */
class CommandGroup extends Command {

    // public static create(commands:Command[] = []):CommandGroup {
    //     return CacheableClass._cachePool.pop(CommandGroup).init(commands) as CommandGroup;
    // }

    private _cmdList:Command[] = [];

    /**
     * 当前执行的命令
     */
    private _currCmd:Command;
    /**
     * 当前执行的命令在队列中的索引
     * @type {number}
     * @private
     */
    private _currIdx:number = -1;


    public init(commands:Command[] = []): CommandGroup {
        let i:number, ilen:number;
        ilen = commands.length;
        for(i = 0; i < ilen; i++) {
            this.add(commands[i]);
        }

        return this;
    }

    /**
     * 往队列增加一条命令
     * @param cmd
     */
    public add(cmd:Command){
        if(this._cmdList.indexOf(cmd) < 0){
            this._cmdList.push(cmd);
        }
        return this;
    }

    /**
     * 从队列移除指定命令
     * @param cmd
     */
    public remove(cmd:Command){
        let idx = this._cmdList.indexOf(cmd);
        if(idx > 0){
            this._cmdList.splice(idx,1);
        }
        return this;
    }

    protected execute() {
        this.executeNext();
    }
    /**
     * 执行命令队列里的下一条命令
     */
    protected executeNext(){
        if(this._cmdList[this._currIdx+1] == null) {
            this.closeAsync();
            return;
        }

        this._currIdx++;
        let currCmd = this._cmdList[this._currIdx];
        this._currCmd = currCmd;

        currCmd.addEventListener(Command.COMMAND_ABORT, this.onSingleCmdAbort, this);
        currCmd.addEventListener(Command.COMMAND_COMPLETE, this.onSingleCmdComplete, this);
        if(currCmd.autoRestore){
            currCmd.autoRestore = false;
        }
        currCmd.context = this.context;
        currCmd.openAsync();
    }
    /**
     * 命令队列里一条命令执行中断
     * @param e
     */
    protected onSingleCmdAbort(e:egret.Event){
        this._currCmd.removeEventListener(Command.COMMAND_ABORT, this.onSingleCmdAbort, this);
        this._currCmd.removeEventListener(Command.COMMAND_COMPLETE, this.onSingleCmdComplete, this);
        this.closeAsync(true);
    }
    /**
     * 命令队列里一条命令执行完毕
     * @param e
     */
    protected onSingleCmdComplete(e:egret.Event){
        this._currCmd.removeEventListener(Command.COMMAND_ABORT, this.onSingleCmdAbort, this);
        this._currCmd.removeEventListener(Command.COMMAND_COMPLETE, this.onSingleCmdComplete, this);
        if(this._currIdx == this._cmdList.length - 1){
            this.closeAsync();
        }else{
            this.executeNext();
        }
    }

    public closeAsync(abort:boolean=false){
        super.closeAsync(abort);
        if(this._currCmd) {
            this._currCmd.removeEventListener(Command.COMMAND_ABORT, this.onSingleCmdAbort, this);
            this._currCmd.removeEventListener(Command.COMMAND_COMPLETE, this.onSingleCmdComplete, this);
        }
        this._currCmd = null;
        this._currIdx = -1;
    }

    /**
     * 清空命令队列
     */
    public clear(abort:boolean=false){
        let i:number, ilen:number;
        ilen = this._cmdList.length;
        for(i = 0; i < ilen; i++) {
            this._cmdList[i].restore();
        }
        this._cmdList.length = 0;
    }
}
window['CommandGroup']=CommandGroup;