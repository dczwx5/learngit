//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/20.
 * Time: 12:05
 */
package kof.game.talent.talentFacade.talentSystem.proxy.data {

import kof.message.Talent.TalentInfoUpdateResponse;

/**更新反馈*/
public class CTalentInfoUpdateData {
    /**更新反馈数据*/
    public var updateInfos : CTalentPointUpdateData = null;
    /**提示码*/
    public var gamePromptID : int;

    public function CTalentInfoUpdateData() {
    }

    public function decode( data : TalentInfoUpdateResponse ) : void {
        this.gamePromptID = data.gamePromptID;
        updateInfos = new CTalentPointUpdateData();
        this.updateInfos.decode( data.updateInfos );
    }
}
}

import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentAllPointData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentInfoData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentWarehouseData;

class CTalentPointUpdateData {
    public var pointUpdate : CTalentAllPointData;
    public var warehouse : Vector.<CTalentWarehouseData>;

    public function decode( data : Object ) : void {
        for ( var key : * in data ) {
            if ( key == "pointUpdate" ) {
                this.pointUpdate = new CTalentAllPointData();
                this.pointUpdate.decode( data[ key ] );
            }
            else if ( key == "warehouse" ) {
                this.warehouse = new Vector.<CTalentWarehouseData>();
                var len : int = data.warehouse.length;
                var talentWarehouse : CTalentWarehouseData = null;
                for ( var i : int = 0; i < len; i++ ) {
                    talentWarehouse = new CTalentWarehouseData();
                    talentWarehouse.decode( data.warehouse[ i ] );
                    this.warehouse.push( talentWarehouse );
                }
            }
        }

        // 更新历史最高镶嵌总等级信息
        if(data.hasOwnProperty("historyHighSoulPointTotalLevelUpdate"))
        {
            var hisLevelInfo:Object = data["historyHighSoulPointTotalLevelUpdate"];
            var pageType:int = 0;
            var hisHighLevel:int = 0;
            if(hisLevelInfo.hasOwnProperty("pageType"))
            {
                pageType = hisLevelInfo["pageType"];
            }

            if(hisLevelInfo.hasOwnProperty("historyHighSoulPointTotalLevel"))
            {
                hisHighLevel = hisLevelInfo["historyHighSoulPointTotalLevel"];
            }

            var talentInfoData:CTalentInfoData = CTalentDataManager.getInstance().talentInfoData;
            talentInfoData.historyHighTotalLevelDic[pageType] = hisHighLevel;
        }
    }
}
