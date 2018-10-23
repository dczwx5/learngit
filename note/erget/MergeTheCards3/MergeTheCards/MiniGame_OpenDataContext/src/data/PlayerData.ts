type UserData = {
    openId:string,
    nickName?:string
}
type UserGameData = {
    /** 用户的微信头像 url */
    avatarUrl: string,
    /** 用户的微信昵称 */
    nickname: string,
    /** 用户的 openId */
    openid: string,
    /**用户自定义数据 */
    KVDataList?: KVData[],
    /**自定义数据的结构体形式*/
    KVDataSet?:KVDataSet
}
type KVData = {
    key: string,
    value: string
}

type KVDataSet = {
    score?:number,
    score_max?:number,
    score_week?:number,
    score_time?:number,
    // star?:number
}

function  kvList2KvSet(dataList: UserGameData[]): UserGameData[] {
    if (!dataList || dataList.length == 0) {
        return [];
    }
    for (let i = 0, l = dataList.length; i < l; i++) {
        let dataSet: KVDataSet = {};
        let data = dataList[i];
        data.KVDataList.forEach(function (val: KVData, idx: number, arr: KVData[]) {
            dataSet[val.key] = parseInt(val.value);
        });
        data.KVDataSet = dataSet;
    }
    return dataList;
}

function userGamedataListFilterByWeek(dataList: UserGameData[]): UserGameData[] {
    let result:UserGameData[] = [];
    let dateUtil = new DateUtil();
    dateUtil.newToday(Date.now());
    let mondayTS = dateUtil.getMonday().getTime()/1000;
    // let sundayTS = dateUtil.getSunday().getTime();
    let data:UserGameData;
    let scoreTime:number;
    for (let i = 0, l = dataList.length; i < l; i++){
        data = dataList[i];
        if(data.KVDataSet && data.KVDataSet.score_time ){
            scoreTime = data.KVDataSet.score_time;
            if(scoreTime > mondayTS){
                result.push(data);
            }
        }
    }
    return result;
}