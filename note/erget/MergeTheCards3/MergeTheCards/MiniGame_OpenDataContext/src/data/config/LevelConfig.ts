class LevelConfig{
    public id:number;
    public icon:string;
    public lev:number;
    public name:string;
    public stars:number;
    public baseStars:number;
    public upStars:number;
    public winRank1:number;
    public winStar1:number;
    public lostRank1:number;
    public lostStar1:number;
    public winRank2:number;
    public winStar2:number;
    public lostRank2:number;
    public lostStar2:number;
    public awards:string;
    public nameColour:string;

    public attrs(){
        return ['id','icon','lev','name','stars','baseStars','upStars','winRank1','winStar1','lostRank1','lostStar1','winRank2','winStar2','lostRank2','lostStar2','awards','nameColour'];
    }

    public static getLevelDataByStars(star:number):LevelConfig{
        let dic:Dictionary<LevelConfig> = GlobalData.instance.lvCfg;
        let keys:Array<number> = dic.keys;
        let level:LevelConfig;
        let len:number = keys.length;
        let idx:number = 0;
        let left:number = 0;
        let right:number = len - 1;
        let bRet:boolean = false;
        while (left <= right){
            idx = Math.floor((left + right) / 2);
            level = dic.get(idx + 1);
            let upstars:number = level.upStars;
            let basestars:number = level.baseStars;
            // egret.log("idx ==============",idx,"basestars=",basestars,"upstars=",upstars);
            if(upstars>= star &&  basestars<=star){
                bRet = true;
                break;
            }else {
                if(star > upstars){
                    left = idx + 1;
                }
                if(star <basestars){
                    right = idx - 1;
                }
            }
        }
        if(!bRet){
            egret.error("没有找到对应的段位等级数据!");
            if(star < 1){
                level = dic.get(1);
            }else if(star > 999999){
                level = dic.get(keys[len-1]);
            }
        }
        return level;
    }
}
window["LevelConfig"] = LevelConfig;