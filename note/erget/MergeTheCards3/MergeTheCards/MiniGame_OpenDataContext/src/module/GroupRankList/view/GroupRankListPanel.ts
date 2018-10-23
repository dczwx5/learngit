class GroupRankListPanel extends ListPanel<RankListItem>{

    protected createItem(): RankListItem {
        return new RankListItem();
    }

    public get itemHeight(): number {
        return RankListItem.HEIGHT;
    }

    public get titleText(): string {
        return "群排行";
    }

    public set dataList(dataList:UserGameData[]){
        this._dataList = dataList;
        this.updateByData();
    }
    public get dataList():UserGameData[]{
        return this._dataList;
    }
}
window["GroupRankListPanel"] = GroupRankListPanel;