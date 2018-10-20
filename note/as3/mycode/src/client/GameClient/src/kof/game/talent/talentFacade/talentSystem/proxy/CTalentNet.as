//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 14:23
 */
package kof.game.talent.talentFacade.talentSystem.proxy {

    import kof.framework.INetworking;
    import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentInfoData;
    import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentPointData;
    import kof.message.CAbstractPackMessage;
    import kof.message.Talent.MosaicReplaceRequest;
    import kof.message.Talent.OpenSoulPointRequest;
import kof.message.Talent.SoulRecycleRequest;
import kof.message.Talent.SoulSellRequest;
    import kof.message.Talent.TakeOffRequest;
    import kof.message.Talent.TalentInfoRequest;
    import kof.message.Talent.TalentInfoResponse;
    import kof.message.Talent.TalentInfoUpdateResponse;
    import kof.message.Talent.WarehouseSelectRequest;

    internal class CTalentNet implements ITalentNet {
        private var _netWork : INetworking = null;

        public function CTalentNet() {}

        public function set network( value : INetworking ) : void {
            this._netWork = value;
            this._netWork.bind(TalentInfoResponse).toHandler(_onTalentInfoResponse);
            this._netWork.bind(TalentInfoUpdateResponse).toHandler(_onTalentInfoUpdateResponse);
        }

        private function _onTalentInfoResponse(net:INetworking, message:CAbstractPackMessage):void
        {
            var response:TalentInfoResponse = message as TalentInfoResponse;
            CTalentDataManager.getInstance().setTalentPointData(response);
        }

        private function _onTalentInfoUpdateResponse(net:INetworking, message:CAbstractPackMessage):void
        {
            var response:TalentInfoUpdateResponse = message as TalentInfoUpdateResponse;
            CTalentDataManager.getInstance().updateTalentData(response);
        }

        /**天赋信息请求*/
        public function talentInfoRequest() : void {
            var talentInfoReq:TalentInfoRequest = new TalentInfoRequest();
            talentInfoReq.decode([1]);
            _netWork.post(talentInfoReq);
        }

        /**开启斗魂点请求
         *
         * @param soulID 斗魂石唯一ID
         * @param openType 开启类型:0正常开启 1付费开启
         * */
        public function openSoulPointRequest(soulID:int,openType:int) : void {
            var opneSoulPoint:OpenSoulPointRequest = new OpenSoulPointRequest();
//            opneSoulPoint.decode([soulID,openType]);
            opneSoulPoint.soulPointConfigID = soulID;
            opneSoulPoint.openType = openType;
            _netWork.post(opneSoulPoint);
        }

        /**镶嵌（替换）请求
         *
         * @param pointID 斗魂位置表ID
         * @param soulReplaceID 要镶嵌的斗魂配置表唯一ID
         *
         * */
        public function mosaicReplaceRequest(ID:int,soulID:int) : void {
            var mosaicReplace:MosaicReplaceRequest = new MosaicReplaceRequest();
            mosaicReplace.decode([ID,soulID]);
            _netWork.post(mosaicReplace);
        }

        /**卸下请求
         *
         * @param type 卸下类型： 0 卸下当前斗魂点上的斗魂 ; 1 一键卸下当前斗魂页所有斗魂
         * @param pageType 斗魂页类型: 1 本源; 2 出战; 3 特质; 4 相克; 5 招式
         * @param pointID 斗魂位置表ID
         *
         * */
        public function takeOffRequest(type:int,pageType:int,ID:int) : void {
            var takeOff:TakeOffRequest = new TakeOffRequest();
            takeOff.decode([type,pageType,ID]);
            _netWork.post(takeOff);
        }

        /**斗魂库筛选品质请求
         *
         * @param quality 斗魂库筛选品质记录  1-白 2-绿 3-蓝 4-紫 5-橙 (整个发送)
         *
         * */
        public function warehouseSelectRequest(qualityArr:Array) : void {
            var warehouseSelect:WarehouseSelectRequest = new WarehouseSelectRequest();
            warehouseSelect.decode([qualityArr]);
            _netWork.post(warehouseSelect);
        }

        /**斗魂出售请求
         *
         * @param type 出售类型： 0 单一出售 ; 1 批量出售
         * @param soulID 斗魂配置表唯一ID
         * @param sellNum 出售数量
         * @param sellQualityArr 批量出售选择的品质
         * @param mainType 批量出售的主类型 0-代表全部 1-攻击类 2-防御类 3-技巧类 4-特殊类
         * @param batchSellWarehouseType 批量出售库类型 1 本源斗魂库 ; 2 拳皇大赛斗魂库
         *
         * */
        public function soulSellRequest(type:int,soulID:int,sellNum:int,sellQualityArr:Array,mianType:int,batchSellWarehouseType:int=1) : void {
            var soulSell:SoulSellRequest = new SoulSellRequest();
            soulSell.decode([type,soulID,sellNum,sellQualityArr,mianType,batchSellWarehouseType]);
            _netWork.post(soulSell);
        }

        /**
         * 斗魂回收请求
         */
        public function soulRecycleRequest(meltType:int, recycleSoul:Array) : void {
            var soulSell:SoulRecycleRequest = new SoulRecycleRequest();
            soulSell.furnaceType = meltType;
            soulSell.recycleSoul = recycleSoul;
            _netWork.post(soulSell);
        }
    }
}
