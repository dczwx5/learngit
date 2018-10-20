//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/21.
 * Time: 18:04
 */
package kof.game.talent.talentFacade.talentSystem.proxy.data {

    public class CTalentAllPointData {
        /**斗魂页类型: 1 本源; 2 出战; 3 特质; 4 相克; 5 招式*/
        public var pageType : int;
        /**该斗魂页斗魂点信息*/
        public var pointInfos : Vector.<CTalentPointData> = new <CTalentPointData>[];

        public function CTalentAllPointData() {
        }

        public function decode( obj : Object ) : void {
            for ( var key : * in obj ) {
                if ( key == "pageType" ) {
                    this[ key ] = obj[ key ];
                }
                else if ( key == "pointInfos" ) {
                    var len : int = obj[ key ].length;
                    var talentPointData : CTalentPointData = null;
                    for ( var i : int = 0; i < len; i++ ) {
                        var dataObj:Object = obj[key][i];
                        talentPointData=new CTalentPointData();
                        talentPointData.decode(dataObj);
                        this.pointInfos.push(talentPointData);
                    }
                }
            }
        }
    }
}
