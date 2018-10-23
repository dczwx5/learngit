namespace VL.Command{
    /**
     * 方法调用委托
     */
    class DelegateCommand extends Command {

        private _fun:Function;
        private _argsArr:any[];
        private _thisArg:any;

        public init(fun:Function, thisArg:any=null, argsArr:any[]=null) {
            this._fun = fun;
            this._argsArr = argsArr;
            this._thisArg = thisArg;
            return this;
        }

        protected execute() {
            if(this._fun != null) {
                this._fun.apply(this._thisArg, this._argsArr);
            }
            this.closeAsync();
        }

        public clear() {
            this._fun = null;
            this._thisArg = null;
            this._argsArr = null;
        }
    }
}
