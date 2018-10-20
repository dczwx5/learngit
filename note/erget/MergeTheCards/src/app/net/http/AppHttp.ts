namespace App {
    export class AppHttp extends AppHttpBase {


        public init(http: VL.Net.Http, clientVersion: string, httpServer: string, serverPort: string): AppHttp {
            super.init(http, clientVersion, httpServer, serverPort);
            return this;
        }

        /**
         * 登录
         * @param {string} inviteOpenId
         * @param {number} inviteUserId
         * @param {Enum_System} system
         * @param {string} source
         * @param {number} source_lv
         * @param {number} shareId
         * @param {string} code
         * @param {(data: any, otherData: any) => void} onResp
         * @param thisArg
         * @param userData
         * @returns {Promise<VL.Net.HttpRespPack>}
         */
        public async login(inviteOpenId: string, inviteUserId: number, system: Enum_System, source: string, source_lv: number, shareId: number, code: string, onResp?: (data: any, otherData: any) => void, thisArg?: any, userData?: any) {
            return await this.sendHttp({
                api_name: "weixin_reg_login",
                jscode: code,
                nikename: "",
                sex: "",
                avatar: "",
                content_id: shareId,
                sys: system,
                source: source,
                source_lv: source_lv,
                invite_openid: inviteOpenId,
                invite_user_id: inviteUserId,
            }, function (data: any, otherData: any) {
                // if (data.code == Enum_HttpRespCode.SUCCESS) {
                this.serverTimestamp = parseInt(data["timestamp"]);
                this.token = data["token"];
                onResp.call(thisArg, data, otherData);
                // }
            }.bind(this), this, userData);
        }

        /**
         * 提交战报
         * @param lv
         * @param score
         * @param onResp
         * @param thisArg
         * @param userData
         * @returns {Promise<HttpRespPack>}
         */
        public async submitBattleRecord(lv: number, score: number, onResp?: (data: any, otherData: any) => void, thisArg?: any, userData?: any) {
            app.log(`========= submit battle record =======`);
            return await this.sendHttp({
                api_name: "combat",
                lv: lv,
                score: score
            }, onResp, this, userData);
        }

        /**
         * 获取分享文案和图片
         * @param onResp
         * @param thisArg
         * @param userData
         */
        public async getAboutShare(onResp?: (data: any, otherData: any) => void, thisArg?: any, userData?: any) {
            return await this.sendHttp({
                api_name: "get_share_content_image_list",
            }, onResp, this, userData);
        }

        /**
         * 分享统计
         * @param shareId 分享文案id
         * @param onResp
         * @param thisArg
         * @param userData
         */
        public async shareStatistics(shareId: number, onResp?: (msg: VL.Net.HttpRespPack, userdata: any) => void, thisArg?: any, userData?: any) {
            return await this.sendHttp({
                api_name: "share_log",
                content_id: shareId
            }, onResp, thisArg, userData);
        }

        /**
         * 获取游戏审核状态（1正常版本 2审核版本）
         * @param onResp
         * @param thisArg
         * @param userData
         */
        public async getGameExamineStatus(onResp?: (data: any, otherData: any) => void, thisArg?: any, userData?: any) {
            return await this.sendHttp({
                api_name: "get_version_status",
            }, onResp, this, userData);
        }

        /**
         * 分享进入
         * @param id
         * @param openId
         * @param onResp
         * @param thisArg
         * @param userData
         */
        public async enterFromShare(id: number, openId: string, onResp?: (data: any, otherData: any) => void, thisArg?: any, userData?: any) {
            return await this.sendHttp({
                api_name: "invite_into_game",
                invite_openid: openId,
                invite_user_id: id,
            }, onResp, thisArg, userData);
        }

        /**
         *
         * @param onResp
         * @param thisArg
         * @param userData
         * @returns {Promise<HttpRespPack>}
         */
        public async getOtherGamesInfo(onResp?: (data: {
            image_list: WxOtherGameData[];
            image_list_2: WxOtherGameData[];
        }, otherData: any) => void, thisArg?: any, userData?: any) {
            return await this.sendHttp({
                api_name: "get_guide_image_list_new",
            }, onResp, thisArg, userData);
        }

        /**
         * 获取用户信息
         * @param onResp
         * @param thisArg
         * @param otherData
         */
        public async getUseinfo(onResp?: (data: any, otherData: any) => void, thisArg?: any, otherData?: any) {
            return await this.sendHttp({
                api_name: "get_base_info",
            }, onResp, thisArg, otherData);
        }

        /**
         * 发送统计视频
         * @param type 视频入口
         * @param action_type   1,开始观看；2，完成
         * @param onResp
         * @param thisArg
         * @param otherData
         */
        public async sendWatchTVStep(type: Enum_WxWatchVideoFlag, action_type: 1 | 2, onResp?: (data: {type:number}, otherData: any) => void, thisArg?: any, otherData?: any) {
            return await this.sendHttp({
                api_name: "video_log",
                type: type,
                action_type: action_type
            }, onResp, thisArg, otherData);
        }

        /**
         * 群分享唯一检测
         * @param shareId 分享文案id
         * @param onResp
         * @param thisArg
         * @param otherData
         */
        public async checkGroupShare(encrypted: string, iv: string, onResp?: (data: any, otherData: any) => void, thisArg?: any, otherData?: any) {
            return await this.sendHttp({
                api_name: "check_share_group",
                encrypted: encrypted,
                iv: iv
            }, onResp, thisArg, otherData);
        }


//
//     /**
//      * 同步货币
//      * @param goodsid 商品id (购买和回收对应的道具id，普通类型填0即可)
//      * @param buySum 购买商品的次数
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static asyncMoney(goodsid:number = 0, buySum:number = 0, onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"sync_coin_info",
//             coin_list:PlayerData.goldCoinData.digitStr,
//             coin_speed_list:PlayerData.secondIncomeData.digitStr,
//             online_time_sum:PlayerData.onlinetimes,
//             goods_id:goodsid,
//             buy_sum:buySum
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 获取购买过的狗狗数
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static getGainDoglist(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"goods_buy_log_list"
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 获取邀请信息
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static getInvatedInfo(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"get_invite_info"
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 获取邀请好友奖励
//      * @param goodsid 奖励id
//      * @param value 奖励数量
//      * @param type 奖励类型 1,金币； 2,钻石
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static getInvatedAward(goodsid:number,onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"award_invite",
//             award_id:goodsid
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     public static buyByDiamond(gold:number, goods_id:number, onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"buy_goods_by_gold",
//             gold:gold,
//             goods_id:goods_id
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 获取分享群次数
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static getShareFreeAwardTimes(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"get_share_group_default"
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 同步每天分享次数
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static asyncShareTimes(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"update_share_group_default"
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 获取狗数据
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static getAllDogData(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"get_scene_list"
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 改变狗数据
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static asyncDogData(arr:Array<any>,onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"update_scene_list",
//             list:JSON.stringify(arr)
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 解锁物品
//      * @param id
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static unlockingGoods(id:number,onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"unlocking_goods",
//             goods_id:id,
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }


//
//     /**
//      * 看视频次数
//      * @param callFunc
//      * @param thisObj
//      * @param args
//      */
//     public static addWatchVideoCount(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any){
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"look_ad_fail",
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 获取看视频次数
//      * @param callFunc
//      * @param thisObj
//      * @param args
//      */
//     public static getWatchVideoCount(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any){
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"get_ad_info",
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 免费领取钻石
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static getFreeDiamond(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"award_gold_free",
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 获取用户基础信息
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static getUserBaseInfo(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"get_base_info",
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 增加额外奖励时间
//      * @param t 秒
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static addExtAwardTime(t:number,onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"update_coin_speed_multiple",
//             multiple_time:t
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//

//
//     /**
//      * 更新新手引导步骤
//      * @param step
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static updateNewGuidStep(step:E_GUIDE_STEP_TYPE, onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name : "update_guide_step",
//             guide_step : step
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//
//
//
//
//
//
//
//
        /*********************************************公共协议********************************************/


//
//     /**
//      * 更新最高分
//      */
//     public static updateTopScore(score:number,onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any){
//         egret.log("提交分数token："+App.token)
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"combat",
//             score:score
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 看视频次数
//      * @param callFunc
//      * @param thisObj
//      * @param args
//      */
//     public static watchVideoCount(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any){
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"look_ad_fail"
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 获取商品
//      * @param callFunc
//      * @param thisObj
//      * @param args
//      */
//     public static getGoodsList(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any){
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"goods_list"
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 使用商品
//      * @param goodsId
//      * @param callFunc
//      * @param thisObj
//      * @param args
//      */
//     public static useGoods(goodsId:number,onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any){
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"set_balloon_id",
//             balloon_id:goodsId.toString(10)
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 广告奖励商品
//      * @param callFunc
//      * @param thisObj
//      * @param args
//      */
//     public static advertisementAward(goodsId:number,onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any){
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name:"look_ad",
//             goods_id:goodsId.toString(10),
//             type:"4"//type1观看视频送红心 2观看视频接着玩 3看红包视频 4看视频送道具
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 获取好友助力
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static getHelpList(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any){
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name: "get_help_list",
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//
//     /**
//      * 使用好友助力
//      * @param frdUID
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static useFriedsHelp(frdUID:string,onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name: "use_help",
//             help_id:frdUID
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }
//

//
//     /**
//      * 获取其他游戏图标和图片
//      * @param onResp
//      * @param thisArg
//      * @param userData
//      */
//     public static getOtherGameImg(onResp?:(msg: HttpRespPack, userdata:any)=>void, thisArg?:any, userData?:any) {
//         let pack = HttpReqPack.create(this.httpServerPort, {
//             api_name: "get_guide_image_list",
//             game_id:App.appId
//         });
//         App.Http.send(pack, userData).register(onResp, thisArg);
//     }


    }
}