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

    public class CTalentNetProxy implements ITalentNet {
        private var _talentNet : CTalentNet = null;

        public function CTalentNetProxy() {
            _talentNet = new CTalentNet();
        }

        public function set network( value : INetworking ) : void {
            _talentNet.network = value;
        }

        /**天赋信息请求*/
        public function talentInfoRequest() : void {
            _talentNet.talentInfoRequest();
        }

        /**开启斗魂点请求
         *
         * @param soulID 斗魂石唯一ID
         * @param openType 开启类型:0正常开启 1付费开启
         * */
        public function openSoulPointRequest( soulID : int, openType : int ) : void {
            _talentNet.openSoulPointRequest( soulID, openType );
        }

        /**镶嵌（替换）请求
         *
         * @param pointID 斗魂位置表ID
         * @param soulID 要镶嵌的斗魂配置表唯一ID
         *
         * */
        public function mosaicReplaceRequest( ID : int, soulID : int ) : void {
            _talentNet.mosaicReplaceRequest( ID, soulID );
        }

        /**卸下请求
         *
         * @param type 卸下类型： 0 卸下当前斗魂点上的斗魂 ; 1 一键卸下当前斗魂页所有斗魂
         * @param pageType 斗魂页类型: 1 本源; 2 出战; 3 特质; 4 相克; 5 招式
         * @param pointID 斗魂位置表ID
         *
         * */
        public function takeOffRequest( type : int, pageType : int, ID : int ) : void {
            _talentNet.takeOffRequest( type, pageType, ID );
        }

        /**斗魂库筛选品质请求
         *
         * @quality 斗魂库筛选品质记录  1-白 2-绿 3-蓝 4-紫 5-橙 (整个发送)
         *
         * */
        public function warehouseSelectRequest( qualityArr : Array ) : void {
            _talentNet.warehouseSelectRequest( qualityArr );
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
        public function soulSellRequest( type : int, soulID : int, sellNum : int, sellQualityArr : Array, mianType : int ,batchSellWarehouseType:int=1) : void {
            _talentNet.soulSellRequest( type, soulID, sellNum, sellQualityArr, mianType ,batchSellWarehouseType);
        }

        /**
         * 斗魂回收请求
         * @param meltType
         * @param recycleSoul
         */
        public function soulRecycleRequest(meltType:int, recycleSoul:Array):void
        {
            _talentNet.soulRecycleRequest(meltType, recycleSoul);
        }
    }
}
