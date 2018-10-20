//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/20.
 * Time: 12:18
 */
package kof.game.talent.talentFacade.talentSystem.proxy.data {

    /**斗魂库信息*/
    public class CTalentWarehouseData {
        /**斗魂配置表唯一ID*/
        public var soulConfigID : int;
        /**斗魂数量*/
        public var soulNum : int;
        /**变更类型 1 新增 2 删除 3 更新*/
        public var updateState : int = 0;

        public function CTalentWarehouseData() {
        }

        public function decode( obj : Object ) : void {
            for ( var key : * in obj ) {
                if ( this.hasOwnProperty( key ) ) {
                    this[ key ] = obj[ key ];
                }
            }
        }
    }
}
