//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 14:19
 */
package kof.game.talent.talentFacade.talentSystem.proxy {

    import kof.framework.INetworking;

    public interface ITalentNet {
        function set network(value:INetworking):void;
        /**天赋信息请求*/
       function talentInfoRequest():void;
        /**开启斗魂点请求*/
        function openSoulPointRequest(soulID:int,openType:int):void;
        /**镶嵌（替换）请求*/
        function mosaicReplaceRequest(soulID:int,soulReplaceID:int):void;
        /**卸下请求*/
        function takeOffRequest(type:int,pageType:int,soulID:int):void;
        /**斗魂库筛选品质请求*/
        function warehouseSelectRequest(qualityArr:Array):void;
        /**斗魂出售请求*/
        function soulSellRequest(type:int,soulID:int,sellNum:int,sellQualityArr:Array,mainType:int,batchSellWarehouseType:int=1):void;
    }
}
