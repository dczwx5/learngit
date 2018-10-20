namespace VL{
    /**
     * 多播委托
     */
    export class Delegate<VO = any>{
        protected _funList:((params:VO)=>void)[] = [];
        protected _thisArgList:any[] = [];
        /** 函数总数 */
        public get count(): number {
            return this._funList.length;
        }
        /**
         * 是否存在参数目标函数。
         * @param fun 目标函数。
         * @return 存在?
         */
        public has(fun:(params:VO)=>void):boolean {
            return this._funList.indexOf(fun) != -1;
        }
        /**
         * 注册函数。
         * @param fun 目标函数。
         * @param thisArg This指针。
         */
        public register(fun:(params:VO)=>void, thisArg:any):void {
            if(this.has(fun) || !fun)
                return;
            this._funList.push(fun);
            this._thisArgList.push(thisArg);
        }
        /**
         * 注销函数。
         * @param fun 目标函数。
         */
        public unregister(fun:(params:VO)=>void):void {
            if(!this.has(fun))
                return;
            let index:number = this._funList.indexOf(fun);
            this._funList.splice(index, 1);
            this._thisArgList.splice(index, 1);
        }
        /**
         * 清空所有函数。
         */
        public clear():void {
            this._funList.length = 0;
            this._thisArgList.length = 0;
        }
        /**
         * 向所有注册函数广播。
         * @param params 任意广播信息
         */
        public boardcast(params?:VO):void {
            for(let i = 0; i <  this._funList.length; i++) {
                let fun = this._funList[i];
                let thisArg = this._thisArgList[i];
                if(thisArg){
                    fun.call(thisArg, params);
                }else {
                    fun(params);
                }
            }
        }
    }

}