//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/20.
 * Time: 12:30
 */
package kof.game.talent.talentFacade.talentSystem.proxy.data {

import kof.game.talent.talentFacade.CTalentFacade;
import kof.table.TalentSoul;

/**斗魂点数据*/
    public class CTalentPointData {
        /**斗魂位置表ID*/
        public var soulPointConfigID:int;
        /**斗魂点状态：1已开启未镶嵌 2已镶嵌*/
        public var state:int;
        /**镶嵌的斗魂配置表唯一ID*/
        public var soulConfigID:int;
        /**变更类型 1 新增 2 删除 3 更新*/
        public var updateState:int;
        public function CTalentPointData() {
        }

        public function decode(obj:Object):void
        {
            for(var key:* in obj)
            {
                if(this.hasOwnProperty(key))
                {
                    this[key]=obj[key];
                }
            }
        }

        public function get configData():TalentSoul
        {
            return CTalentFacade.getInstance().getTalentSoul(soulConfigID);
        }
    }
}
