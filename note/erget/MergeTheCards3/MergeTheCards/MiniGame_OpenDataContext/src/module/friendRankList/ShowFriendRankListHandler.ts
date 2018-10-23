class ShowFriendRankListHandler extends HandlerBase {

    public init() {
        this.addContextEvent(ContextEvent.CLOSE_CONTEXT, this.onCloseContext, this);
        return this;
    }

    protected execute() {
        LogUtil.log(`ShowFriendRankListHandler execute`);
        //获取小游戏开放数据接口 --- 开始
        wx.getFriendCloudStorage({
            keyList: [ DataKey.SCORE, DataKey.SCORE_MAX, DataKey.SCORE_WEEK, DataKey.SCORE_TIME],
            // keyList: [],
            success: (result: { data: UserGameData[], errMsg: string }) => {
                let dataList = result.data;
                dataList = kvList2KvSet(dataList);
                // dataList = userGamedataListFilterByWeek(dataList);
                dataList.sort(function (a, b) {
                    // return b.KVDataSet.score_week - a.KVDataSet.score_week;
                    return b.KVDataSet.score_max - a.KVDataSet.score_max;
                });

                LogUtil.log(`success: ${JSON.stringify(dataList)}`);
                if (this.isOpened) {
                    let view = this.onOpenView(FriendRankListPanel);
                    view.dataList = dataList;
                } else {
                    LogUtil.warn(` ShowFriendRankListHandler is Closed`);
                }
            },
            fail: err => {
                LogUtil.log(`fail: ${err}`);
                if (!this.isOpened) {
                    LogUtil.warn(` ShowFriendRankListHandler is Closed`);
                }
            },
            complete: () => {
                if (!this.isOpened) {
                    LogUtil.warn(` ShowFriendRankListHandler is Closed`);
                }
            }
        });
    }

    private onCloseContext() {
        this.closeView(FriendRankListPanel);
        this.closeAsync();
    }

    protected clear() {
        this.removeContextEvent(ContextEvent.CLOSE_CONTEXT, this.onCloseContext, this);
    }
}
window["ShowFriendRankListHandler"] = ShowFriendRankListHandler;
