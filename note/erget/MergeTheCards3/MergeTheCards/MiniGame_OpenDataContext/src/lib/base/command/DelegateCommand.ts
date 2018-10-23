/**
 * xhfzcmt
 * date: 5 Sep 2017
 *
 * 方法调用委托
 */
class DelegateCommand extends Command {

    private _fun:Function;
    private _argsArr:any[];
    private _thisArg:any;
    // public static create(fun:Function, thisArg:any, ...argsArr:any[]):DelegateCommand {
    //     let cmd:DelegateCommand =  CacheableClass._cachePool.pop(DelegateCommand);
    //     cmd._fun = fun;
    //     cmd._argsArr = argsArr;
    //     cmd._thisArg = thisArg;
    //     return cmd;
    // }
    public init(fun:Function, thisArg:any=null, argsArr:any[]=null):DelegateCommand {
        this._fun = fun;
        this._argsArr = argsArr;
        this._thisArg = thisArg;
        return this;
    }
    protected execute() {
        if(this._fun != null) {
            this._fun.apply(this._thisArg, this._argsArr);
        }
        egret.log('finish DelegateCommand')
        this.closeAsync();
    }

    protected clear() {
        this._fun = null;
        this._thisArg = null;
        this._argsArr = null;
    }
}
window['DelegateCommand']=DelegateCommand;