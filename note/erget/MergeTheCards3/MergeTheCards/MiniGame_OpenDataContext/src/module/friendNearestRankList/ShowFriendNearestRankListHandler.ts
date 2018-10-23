class ShowFriendNearestRankListHandler extends HandlerBase {

    public init(): HandlerBase {
        this.addContextEvent(ContextEvent.CLOSE_CONTEXT, this.onCloseContext, this);
        return this;
    }

    protected execute() {
        LogUtil.log(`ShowFriendNearestRankListHandler execute`);
        //获取小游戏开放数据接口 --- 开始
        wx.getFriendCloudStorage({
            keyList: [ DataKey.SCORE, DataKey.SCORE_MAX, DataKey.SCORE_WEEK, DataKey.SCORE_TIME],
            // keyList: [],
            success: (result: { data: UserGameData[], errMsg: string }) => {
                let dataList = result.data;
                dataList = kvList2KvSet(dataList);
                // dataList = userGamedataListFilterByWeek(dataList);
                dataList.sort(function (a, b) {
                    return b.KVDataSet.score_week - a.KVDataSet.score_week;
                });

                LogUtil.log(`success: ${JSON.stringify(dataList)}`);
                if (this.isOpened) {
                    let view = this.onOpenView(FriendNearestRankListPanel);
                    view.dataList = dataList;
                } else {
                    LogUtil.warn(` ShowFriendNearestRankListHandler is Closed`);
                }
            },
            fail: err => {
                LogUtil.log(`fail: ${err}`);
                if (!this.isOpened) {
                    LogUtil.warn(` ShowFriendNearestRankListHandler is Closed`);
                }
            },
            complete: () => {
                if (!this.isOpened) {
                    LogUtil.warn(` ShowFriendNearestRankListHandler is Closed`);
                }
            }
        });
    }

    private onCloseContext() {
        this.closeView(FriendNearestRankListPanel);
        this.closeAsync();
    }

    protected clear() {
        this.removeContextEvent(ContextEvent.CLOSE_CONTEXT, this.onCloseContext, this);
    }
}
window["ShowFriendNearestRankListHandler"] = ShowFriendNearestRankListHandler;