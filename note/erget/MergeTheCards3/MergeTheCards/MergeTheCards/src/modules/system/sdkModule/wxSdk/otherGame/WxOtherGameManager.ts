class WxOtherGameManager{

    public readonly dg_dataChanged:VL.Delegate = new VL.Delegate;

    private _otherGameDataGroups: WxOtherGameData[][];

    /**每个组当前轮到的数据的索引*/
    private _currGroupDataIdx:number[] = [];

    public setInfo(otherGameDataGroups:WxOtherGameData[][]){
        this._otherGameDataGroups = otherGameDataGroups;
        for(let i = 0, l = otherGameDataGroups.length; i < l; i++){
            this._currGroupDataIdx.push(0);
        }
        this.dg_dataChanged.boardcast();
    }

    /**
     * 获指定组的当前数据
     * @param groupIdx 从0开始
     * @returns {WxOtherGameData}
     */
    public getCurrGameData(groupIdx:number):WxOtherGameData{
        let group = this._otherGameDataGroups[groupIdx];
        let dataIdx = this._currGroupDataIdx[groupIdx];
        return group[dataIdx];
    }

    public get groupCount():number{
        if(!this._otherGameDataGroups){
            return 0;
        }
        return this._otherGameDataGroups.length;
    }

    /**
     * 跳转至指定导流组的当前游戏，并将该组数据更新至下一个游戏
     * @param groupIdx
     * @returns {Promise<T>}
     */
    public async toOtherGame(groupIdx:number){
        return new Promise((resolve, reject) => {
            let otherGameData:WxOtherGameData = this.getCurrGameData(groupIdx);
            wx.navigateToMiniProgram({
                appId:otherGameData.game_appid,
                success:()=>{
                    app.log(`跳转至其他游戏成功 appid：${otherGameData.game_appid}`);
                },
                complete:()=>{
                    if(++this._currGroupDataIdx[groupIdx] >= this._otherGameDataGroups[groupIdx].length){
                        this._currGroupDataIdx[groupIdx] = 0;
                    }
                    this.dg_dataChanged.boardcast();
                    resolve();
                },
                fail:()=>{
                    app.log(`跳转至其他游戏失败…… appid：${otherGameData.game_appid}`);
                }
            });
        })
    }
}
