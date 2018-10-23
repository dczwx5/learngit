class SC_FriendsRankMediator extends ShareCanvasMediator{
    protected onViewOpen() {
        super.onViewOpen();
    }

    protected onViewClose() {
        super.onViewClose();
    }

    protected get viewClass(): new()=>SC_FriendsRankView {
        return SC_FriendsRankView;
    }

    protected get openViewMsg(): new()=>VoyaMVC.IMsg  {
        return WxSdkMsg.OpenFriendRankListView;
    }

    protected get closeViewMsg(): new()=>VoyaMVC.IMsg  {
        return WxSdkMsg.CloseFriendRankListView;
    }

    protected onBack() {
        this.sendMsg(create(WxSdkMsg.CloseFriendRankListView));
    }
}
