//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/19.
 * Time: 17:55
 */
package kof.game.talent.talentFacade.talentSystem.proxy.data {

import flash.utils.Dictionary;

import kof.message.Talent.TalentInfoResponse;

    /**天赋信息反馈*/
    public class CTalentInfoData {

        /**全部斗魂页斗魂点信息*/
        public var allPointInfos : Vector.<CTalentAllPointData> = new <CTalentAllPointData>[];
        /**斗魂库筛选品质记录  1-白 2-绿 3-蓝 4-紫 5-橙 6-黄 7-红*/
        public var warehouseSelectRecord : Array = [];
        /**斗魂库信息*/
        public var warehouse : Vector.<CTalentWarehouseData> = new <CTalentWarehouseData>[];

        /** 历史最高斗魂等级信息 */
        public var historyHighTotalLevelDic:Dictionary = new Dictionary();

        public function CTalentInfoData() {
        }

        public function decodeData( data : TalentInfoResponse ) : void {
            warehouse.splice( 0, warehouse.length );
            this.warehouseSelectRecord = data.warehouseSelectRecord;

            var len : int = data.allPointInfos.length;
            var i : int = 0;
            var talentAllpointData : CTalentAllPointData = null;
            for ( i = 0; i < len; i++ ) {
                talentAllpointData = new CTalentAllPointData();
                talentAllpointData.decode( data.allPointInfos[ i ] );
                this.allPointInfos.push( talentAllpointData );

                // 更新历史最高镶嵌总等级信息
                var infoData:Object = data.allPointInfos[i];
                var pageType:int = 0;
                var histHighLevel:int = 0;
                if(infoData.hasOwnProperty("pageType"))
                {
                    pageType = infoData["pageType"];
                }

                if(infoData.hasOwnProperty("historyHighSoulPointTotalLevel"))
                {
                    histHighLevel = infoData["historyHighSoulPointTotalLevel"];
                }

                historyHighTotalLevelDic[pageType] = histHighLevel;
            }

            len = data.warehouse.length;
            var talentWarehouse : CTalentWarehouseData = null;
            for ( i = 0; i < len; i++ ) {
                talentWarehouse = new CTalentWarehouseData();
                talentWarehouse.decode( data.warehouse[ i ] );
                this.warehouse.push( talentWarehouse );
            }
        }
    }
}


