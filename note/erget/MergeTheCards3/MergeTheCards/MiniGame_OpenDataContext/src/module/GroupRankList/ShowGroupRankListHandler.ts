class ShowGroupRankListHandler extends HandlerBase{

    private shareTicket:string;
    public init(shareTicket:string) {
        this.shareTicket = shareTicket;
        this.addContextEvent(ContextEvent.CLOSE_CONTEXT, this.onCloseContext, this);
        return this;
    }

    protected execute() {
        LogUtil.log(`ShowGroupRankListHandler execute`);
        wx.getGroupCloudStorage({
            shareTicket:this.shareTicket,
            keyList: [DataKey.SCORE, DataKey.SCORE_MAX, DataKey.SCORE_WEEK, DataKey.SCORE_TIME],
            // keyList: [],
            success: (result: { data: UserGameData[], errMsg: string }) => {
                let dataList = result.data;
                dataList = kvList2KvSet(dataList);
                // dataList = userGamedataListFilterByWeek(dataList);
                dataList.sort(function (a, b) {
                    return b.KVDataSet.score_week - a.KVDataSet.score_week;
                    // return b.KVDataSet.star - a.KVDataSet.star;
                });

                LogUtil.log(`success: ${JSON.stringify(dataList)}`);
                if (this.isOpened) {
                    let view = this.onOpenView(GroupRankListPanel);
                    view.dataList = dataList;
                } else {
                    LogUtil.warn(` ShowGroupRankListHandler is Closed`);
                }
            },
            fail: err => {
                LogUtil.log(`fail: ${err}`);
                if (!this.isOpened) {
                    LogUtil.warn(` ShowGroupRankListHandler is Closed`);
                }
            },
            complete: () => {
                if (!this.isOpened) {
                    LogUtil.warn(` ShowGroupRankListHandler is Closed`);
                }
            }
        });
    }

    private onCloseContext(){
        this.closeView(FriendRankListPanel);
        this.closeAsync();
    }

    protected clear() {
        this.removeContextEvent(ContextEvent.CLOSE_CONTEXT, this.onCloseContext, this);
    }
}

window["ShowGroupRankListHandler"] = ShowGroupRankListHandler;
