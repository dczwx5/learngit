//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2014-present, Egret Technology.
//  All rights reserved.
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the Egret nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY EGRET AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL EGRET AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;LOSS OF USE, DATA,
//  OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//////////////////////////////////////////////////////////////////////////////////////

class Main extends egret.DisplayObjectContainer {

    public static get stage():egret.Stage {
        return egret.MainContext.instance.stage;
    }

    private msgRouter:MsgRouter;

    public constructor() {
        super();
        this.init();
    }

    private init(){

        this.msgRouter = new MsgRouter();
        this.initRouter();

        wx.onMessage((msg:WxOpenDataContextMsg) => {
            LogUtil.log(msg);
            if (msg.head) {
                this.msgRouter.handleMsg(msg);
            }
        });

        // this.test();
    }

    private test(){
        // this.msgRouter.handleMsg(new WxOpenDataContextMsg(WxOpenDataContextMsg.UPDATE_PLAYER_DATA));
        this.msgRouter.handleMsg(new WxOpenDataContextMsg(WxOpenDataContextMsg.FRIEND_RANK_LIST));
    }

    private initRouter(){
        let router = this.msgRouter;
        router.regMsgHandler(WxOpenDataContextMsg.INIT_DATA, InitDataHandler);
        router.regMsgHandler(WxOpenDataContextMsg.CLOSE_CONTEXT, CloseContextHandler);
        router.regMsgHandler(WxOpenDataContextMsg.FRIEND_RANK_LIST, ShowFriendRankListHandler);
        router.regMsgHandler(WxOpenDataContextMsg.FRIEND_NEAREST_RANK_LIST, ShowFriendNearestRankListHandler);
        router.regMsgHandler(WxOpenDataContextMsg.GROUP_RANK_LIST, ShowGroupRankListHandler);
        router.regMsgHandler(WxOpenDataContextMsg.UPDATE_PLAYER_DATA, UpdatePlayerDataHandler);
    }
}
