class LvConfigHelper{
    private static _arrLvExp:number[];
    private static get arrLvExp():number[]{
        if(!this._arrLvExp){
            let arr = [];
            let cfg = app.config.getConfig(LvConfig);
            for(let key in cfg){
                arr.push(cfg[key].needExp);
            }
            Utils.ArrayUtils.quickSort(arr, (a,b)=>{ return a - b; });
            this._arrLvExp = arr;
        }
        return this._arrLvExp;
    }

    /**
     * 根据经验值获取等级
     * @param exp
     * @returns {number}
     */
    public static getLvByExp(exp:number):number{
        let lv:number;
        let currLvExp:number;
        let nextLvExp:number;
        for(let i = 0, l = this.arrLvExp.length; i < l; i++){
            currLvExp = this.arrLvExp[i];
            nextLvExp = this.arrLvExp[i + 1];
            if(!nextLvExp && nextLvExp != 0){
                lv = i + 1;
                break;
            }
            if(exp >= currLvExp && exp < nextLvExp){
                lv = i + 1;
                break;
            }
        }
        return lv;
    }

    /**
     * 根据等级获取所需经验值
     * @param lv
     * @returns {number}
     */
    public static getExpByLv(lv:number):number{
        return this.arrLvExp[lv-1];
    }

    /**
     * 最大等级
     * @returns {number}
     */
    public static get maxLv():number{
        return this.arrLvExp.length;
    }
}
