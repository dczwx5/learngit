//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/20.
 * Time: 17:56
 */
package kof.game.talent.talentFacade.talentSystem.proxy {

import QFLib.Foundation.CMap;

import flash.utils.Dictionary;

import kof.framework.IDatabase;

import kof.game.talent.talentFacade.CTalentFacade;
import kof.game.talent.talentFacade.talentSystem.data.CTalentMeltingData;
import kof.game.talent.talentFacade.talentSystem.data.CTalentMeltingListData;
import kof.game.talent.talentFacade.talentSystem.enums.CTalentPointUpdateStateType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPointStateType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentWareType;
import kof.game.talent.talentFacade.talentSystem.events.CTalentEvent;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentAllPointData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentConst;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentEmbedInfo;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentInfoData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentInfoUpdateData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentPointData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentWarehouseData;
import kof.message.Talent.TalentInfoResponse;
import kof.message.Talent.TalentInfoUpdateResponse;
import kof.table.TalentSoul;
import kof.table.TalentSoulPoint;

public class CTalentDataManager {
    private static var _instance : CTalentDataManager = null;
    private var _talentInfoData : CTalentInfoData = null;
    private var _talentInfoUpdateData : CTalentInfoUpdateData = null;
    //斗魂页对应的斗魂点信息
    private var _pageToPoint : Dictionary = new Dictionary();

    private var _embedInfo : CMap = new CMap();// 斗魂镶嵌信息(pageId -- dic)

    private var m_pTalentMeltData:CTalentMeltingListData;// 熔炼数据

    public final function dispose() : void {
        _instance = null;
        _talentInfoData = null;
        _talentInfoUpdateData = null;
        for ( var key : * in _pageToPoint ) {
            delete _pageToPoint[ key ];
        }
        _pageToPoint = null;
    }

    public function CTalentDataManager( cls : PrivateClass ) {
        _talentInfoData = new CTalentInfoData();
        _talentInfoUpdateData = new CTalentInfoUpdateData();
    }

    public function setTalentPointData( response : TalentInfoResponse ) : void {
        _talentInfoData.decodeData( response );
        var len : int = _talentInfoData.allPointInfos.length;
        var i : int = 0;
        var j : *;
        var k : *;
        var talentAllPointData : CTalentAllPointData = null;
        var allPointObj : Object = null;
        for ( i = 0; i < len; i++ ) {
            talentAllPointData = _talentInfoData.allPointInfos[ i ];
            _pageToPoint[ talentAllPointData.pageType ] = talentAllPointData;
        }

        updateEmbedInfo();


        talentMeltData.clearData();
        talentMeltData.updateDataByData(response.furnace);

        CTalentFacade.getInstance().dispatchEvent( CTalentEvent.UPDATE_DATA, null );
    }

    public function get talentWarehouseSelectRecord() : Array {
        return _talentInfoData.warehouseSelectRecord;
    }

    /**
     * 获取对应斗魂库中的斗魂数据
     * @param 要获取的斗魂库类型
     **/
    public function getTalentWarehouse( wareType : int ) : Vector.<CTalentWarehouseData> {
        var arr : Vector.<CTalentWarehouseData> = new <CTalentWarehouseData>[];
        var len : int = _talentInfoData.warehouse.length;
        var data : CTalentWarehouseData = null;
        var talentSoul : TalentSoul = null;
        for ( var i : int = 0; i < len; i++ ) {
            data = _talentInfoData.warehouse[ i ];
            talentSoul = CTalentFacade.getInstance().getTalentSoul( data.soulConfigID );
            if ( talentSoul.warehouseType == wareType ) {
                arr.push( data );
            }
        }
        return arr;
    }

    /**
     * @param talentQuality 斗魂的品质
     * @param waretype 斗魂库类型，-1为查询所有斗魂库的品质
     * @return 返回斗魂库中相同品质斗魂的数量和这些斗魂出售的总价{nu : talentNu, price : price}
     *
     **/
    public function getTalentPointNuForQuality( talentQuality : int, waretype : int = -1 ) : Object {
        var talentNu : int = 0;
        var price : int = 0;
        _talentInfoData.warehouse.forEach(
                function serchTalent( item : CTalentWarehouseData, index : int, vec : Vector.<CTalentWarehouseData> ) : void {
                    var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( item.soulConfigID );
                    if ( waretype == -1 ) {
                        if ( talentSoul.quality == talentQuality ) {
                            talentNu += item.soulNum;
                            price += talentSoul.sellPrice * item.soulNum;
                        }
                    } else {
                        if ( talentSoul.quality == talentQuality && talentSoul.warehouseType == waretype ) {
                            talentNu += item.soulNum;
                            price += talentSoul.sellPrice * item.soulNum;
                        }
                    }

                } );
        return {nu : talentNu, price : price};
    }

    /**
     * @param talentSoulID 配置表中斗魂种类的唯一ID
     * @return 返回某类型斗魂在斗魂库中的数量
     *
     **/
    public function getTalentPointNuForSoulID( talentSoulID : Number ) : int {
        var talentNu : int = 0;
        _talentInfoData.warehouse.forEach(
                function serchTalent( item : CTalentWarehouseData, index : int, vec : Vector.<CTalentWarehouseData> ) : void {
                    if ( item.soulConfigID == talentSoulID ) {
                        talentNu = item.soulNum;
                    }
                } );
        return talentNu;
    }

    /**
     * @param pointID UI界面上镶嵌斗魂的位置
     * @param page 斗魂页
     * @return 返回斗魂库中，此位置可以镶嵌的斗魂
     *
     **/
    public function getTalentPointForWarehouse( pointID : int, page : int ) : Vector.<CTalentWarehouseData> {
        var type : int = CTalentFacade.getInstance().getTalentPointMosaicTypeForTalentSoulPointTable( pointID, page );
        return _fileterWarehouse( type, page );
    }

    /**
     * @param queryMosaicType 查询的镶嵌类型
     * @return 返回斗魂库中该类型的所有斗魂
     * */
    private function _fileterWarehouse( queryMosaicType : int, page : int ) : Vector.<CTalentWarehouseData> {
        var wareType : int = 0;
        if ( page == ETalentPageType.BEN_YUAN ) {
            wareType = ETalentWareType.BENYUAN_WARE;
        } else {
            wareType = ETalentWareType.PEAK_WARE;
        }
        var vec : Vector.<CTalentWarehouseData> = _talentInfoData.warehouse;
        var resultVec : Vector.<CTalentWarehouseData> = new <CTalentWarehouseData>[];
        vec.forEach( function compare( item : CTalentWarehouseData, index : int, vec : Vector.<CTalentWarehouseData> ) : void {
            var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( item.soulConfigID );
            if ( talentSoul.mosaicType == queryMosaicType && talentSoul.warehouseType == wareType ) {
                resultVec.push( item );
            }
        } );
        return resultVec;
    }

    /**
     * @param index 斗魂页索引
     * 1、本源；2、拳皇大赛；
     * @return 返回当前页已开启格子对应的最高等级
     *
     **/
    public function getTalentAlreadyOpenHighestSequence( index : int ) : int {
        var highestSe : int = 0;
        var talentAllPointData : CTalentAllPointData = this.getTalentPagePointData( index );
        if ( !talentAllPointData )return 0;
        var vec : Vector.<CTalentPointData> = talentAllPointData.pointInfos;
        var len : int = vec.length;
        for ( var i : int = 0; i < len; i++ ) {
            var talentSoulPoint : TalentSoulPoint = CTalentFacade.getInstance().getTalentPointSoulForID( vec[ i ].soulPointConfigID );
            if ( highestSe < talentSoulPoint.openID ) {
                highestSe = talentSoulPoint.openID;
            }
        }
        return highestSe;
    }

    /**
     * @param index 斗魂页索引
     * 1、本源；2、拳皇大赛；
     * @return 返回包含对应页面的斗魂点数据
     *
     **/
    public function getTalentPagePointData( index : int ) : CTalentAllPointData {
        return _pageToPoint[ index ];
    }

    public function updateTalentData( response : TalentInfoUpdateResponse ) : void {
        if ( response.hasOwnProperty( "gamePromptID" ) && response.gamePromptID != 0 ) {
            var promptID : int = response[ "gamePromptID" ];
            CTalentFacade.getInstance().showGamePrompt( promptID );
        }
        else {
            _talentInfoUpdateData.decode( response );

            //斗魂界面斗魂数据更新
            if ( _talentInfoUpdateData.updateInfos.pointUpdate ) {
                var pageIndex : int = _talentInfoUpdateData.updateInfos.pointUpdate.pageType;
                var pointUpdateInfos : Vector.<CTalentPointData> = _talentInfoUpdateData.updateInfos.pointUpdate.pointInfos;
                if ( _pageToPoint[ pageIndex ] ) {
                    var talentAllPointData : CTalentAllPointData = _pageToPoint[ pageIndex ];
                    var pointInfos : Vector.<CTalentPointData> = talentAllPointData.pointInfos;
                    var talentPointData : CTalentPointData = null;
                    var talentPointUpdateData : CTalentPointData = null;
                    for ( var i : int = 0; i < pointUpdateInfos.length; i++ ) {
                        talentPointUpdateData = pointUpdateInfos[ i ];
                        if ( talentPointUpdateData.updateState == CTalentPointUpdateStateType.ADD ) {
                            pointInfos.push( talentPointUpdateData );
//                                CTalentFacade.getInstance().dispatchEvent( CTalentEvent.ADD, talentPointUpdateData );
                        }
                        else if ( talentPointUpdateData.updateState == CTalentPointUpdateStateType.DELETE ) {
                            var deletePointVec : Vector.<CTalentPointData> = new <CTalentPointData>[];
                            for ( var j : int = 0; j < pointInfos.length; j++ ) {
                                talentPointData = pointInfos[ j ];
                                if ( talentPointUpdateData.soulPointConfigID == talentPointData.soulPointConfigID ) {
                                    deletePointVec.push( talentPointData );
                                }
                            }
                            for each( var point : * in deletePointVec ) {
                                var indexpt : int = pointInfos.indexOf( point );
                                pointInfos.splice( indexpt, 1 );
                            }
//                                CTalentFacade.getInstance().dispatchEvent( CTalentEvent.DELETE, talentPointUpdateData );
                        }
                        else if ( talentPointUpdateData.updateState == CTalentPointUpdateStateType.UPDATE ) {
                            for ( var k : int = 0; k < pointInfos.length; k++ ) {
                                talentPointData = pointInfos[ k ];
                                if ( talentPointUpdateData.soulPointConfigID == talentPointData.soulPointConfigID ) {
                                    CTalentFacade.getInstance().dispatchEvent( CTalentEvent.REPLACE, {
                                        oldSoul : talentPointData,
                                        newSoul : talentPointUpdateData
                                    } );
                                    talentPointData.soulConfigID = talentPointUpdateData.soulConfigID;
                                    talentPointData.state = talentPointUpdateData.state;
                                }
                            }
                        }
                    }
                } else {
                    _pageToPoint[ pageIndex ] = _talentInfoUpdateData.updateInfos.pointUpdate;
                }

                updateEmbedInfo( pageIndex );
            }//斗魂库数据更新
            if ( _talentInfoUpdateData.updateInfos.warehouse ) {
                var updateWarehouse : Vector.<CTalentWarehouseData> = _talentInfoUpdateData.updateInfos.warehouse;
                var warehouse : Vector.<CTalentWarehouseData> = _talentInfoData.warehouse;
                var x : int = 0;
                var y : int = 0;
                var uplen : int = updateWarehouse.length;
                var len : int = warehouse.length;
                var updateWarehouseData : CTalentWarehouseData = null;
                for ( x; x < uplen; x++ ) {
                    updateWarehouseData = updateWarehouse[ x ];
                    y = 0;
                    if ( updateWarehouseData.updateState == CTalentPointUpdateStateType.ADD ) {
                        var canAdd : Boolean = true;
                        for ( y; y < len; y++ ) {
                            if ( updateWarehouseData.soulConfigID == warehouse[ y ].soulConfigID ) {
                                warehouse[ y ].soulNum++;
                                canAdd = false;
                                break;
                            }
                        }
                        if ( canAdd ) {
                            warehouse.push( updateWarehouseData );
                        }
                    }
                    else if ( updateWarehouseData.updateState == CTalentPointUpdateStateType.DELETE ) {
                        for ( y; y < len; y++ ) {
                            if ( updateWarehouseData.soulConfigID == warehouse[ y ].soulConfigID ) {
                                warehouse.splice( y, 1 );
                                break;
                            }
                        }
                    } else if ( updateWarehouseData.updateState == CTalentPointUpdateStateType.UPDATE ) {
                        for ( y; y < len; y++ ) {
                            if ( updateWarehouseData.soulConfigID == warehouse[ y ].soulConfigID ) {
                                warehouse[ y ].soulNum = updateWarehouseData.soulNum;
                                warehouse[ y ].updateState = updateWarehouseData.updateState;
                                break;
                            }
                        }
                    }
                }
            }

            if(response.updateInfos.hasOwnProperty("furnace"))
            {
                talentMeltData.updateDataByData(response.updateInfos["furnace"]);
                CTalentFacade.getInstance().dispatchEvent(CTalentEvent.UpdateMeltInfo, null);
            }

            CTalentFacade.getInstance().dispatchEvent( CTalentEvent.UPDATE_DATA, null );
        }
    }

    /**
     * @param index 索引值（1-30）
     * @return 返回状态 0没有开启，1开启没有镶嵌，2已镶嵌
     * */
    public function getTalentPointState( index : int ) : int {
        var talentPageData : CTalentAllPointData = getTalentPagePointData( ETalentPageType.BEN_YUAN );
        if ( talentPageData ) {
            var talentPointDataVec : Vector.<CTalentPointData> = talentPageData.pointInfos;
            var len : int = talentPointDataVec.length;
            var talentPointData : CTalentPointData = null;
            for ( var j : int = 0; j < len; j++ ) {
                talentPointData = talentPointDataVec[ j ];
                if ( index == talentPointData.soulPointConfigID ) {
                    if ( talentPointData.state == ETalentPointStateType.OPEN_CAN_EMBED ) {
                        return ETalentPointStateType.OPEN_CAN_EMBED;
                    }
                    else if ( talentPointData.state == ETalentPointStateType.EMBED ) {
                        return ETalentPointStateType.EMBED;
                    }
                    break;
                }
            }
        }

        return ETalentPointStateType.NOT_OPEN;
    }

    public static function getInstance() : CTalentDataManager {
        if ( !_instance ) {
            _instance = new CTalentDataManager( new PrivateClass() );
        }
        return _instance;
    }

    /**
     * 获取对应页面斗魂总等级
     * @param page
     * @return
     */
    public function getTalentTotalLvForTalentPage( page : int ) : int {
        var talentTotalLv : int = 0;
        var recordTalentAdd : Dictionary = new Dictionary();
        var allTalentPointInfos : CTalentAllPointData = getTalentPagePointData( page );
        if ( allTalentPointInfos ) {
            var vec : Vector.<CTalentPointData> = allTalentPointInfos.pointInfos;
            vec.forEach( function filterpropertyAdd( item : CTalentPointData, idx : int, vec : Vector.<CTalentPointData> ) : void {
                if ( item.soulConfigID != 0 ) {
                    var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( item.soulConfigID );
                    if ( recordTalentAdd[ talentSoul.ID ] ) {
                        recordTalentAdd[ talentSoul.ID ]++;
                    }
                    else {
                        recordTalentAdd[ talentSoul.ID ] = 1;
                    }
                }
            } );
            var nu : int = 0;
            var talentSoul : TalentSoul = null;
            for ( var key1 : int in recordTalentAdd ) {
                nu = recordTalentAdd[ key1 ];
                talentSoul = CTalentFacade.getInstance().getTalentSoul( key1 );
                talentTotalLv += talentSoul.quality * nu;
            }
        }
        return talentTotalLv;
    }

    /**
     * 更新镶嵌信息
     */
    public function updateEmbedInfo( pageIndex : int = -1 ) : void {
        var benyuanDic : Array = _embedInfo.find( ETalentPageType.BEN_YUAN ) as Array;
        var peakDic : Array = _embedInfo.find( ETalentPageType.PEAK ) as Array;

        if ( benyuanDic == null ) {
            benyuanDic = [];
            _embedInfo.add( ETalentPageType.BEN_YUAN, benyuanDic );
        }

        if ( peakDic == null ) {
            peakDic = [];
            _embedInfo.add( ETalentPageType.PEAK, peakDic );
        }

        if ( pageIndex < 0 ) {
            benyuanDic.length = 0;
            peakDic.length = 0;

            for ( var i : int = 1; i <= CTalentConst.TalentMaxQualLevel; i++ ) {
                benyuanDic.push( getEmbedInfoByPageAndLevel( ETalentPageType.BEN_YUAN, i ) );
                peakDic.push( getEmbedInfoByPageAndLevel( ETalentPageType.PEAK, i ) );
            }
        }
        else if ( pageIndex == ETalentPageType.BEN_YUAN ) {
            benyuanDic.length = 0;

            for ( i = 1; i <= CTalentConst.TalentMaxQualLevel; i++ ) {
                benyuanDic.push( getEmbedInfoByPageAndLevel( ETalentPageType.BEN_YUAN, i ) );
            }
        }
        else if ( pageIndex == ETalentPageType.PEAK ) {
            peakDic.length = 0;

            for ( i = 1; i <= CTalentConst.TalentMaxQualLevel; i++ ) {
                peakDic.push( getEmbedInfoByPageAndLevel( ETalentPageType.PEAK, i ) );
            }
        }
    }

    public function getEmbedInfoByPageAndLevel( page : int, qualLevel : int ) : CTalentEmbedInfo {
        var embatInfo : CTalentEmbedInfo = new CTalentEmbedInfo();
        var count : int = 0;
        var allTalentPointInfos : CTalentAllPointData = getTalentPagePointData( page );

        if ( allTalentPointInfos ) {
            var vec : Vector.<CTalentPointData> = allTalentPointInfos.pointInfos;
            for each( var item : CTalentPointData in vec ) {
                if ( item && item.configData ) {
                    if ( item.configData.quality >= qualLevel ) {
                        count++;
                    }
                }
            }
        }

        embatInfo.qualLevel = qualLevel;
        embatInfo.totalNum = count;
        return embatInfo;
    }

    public function getEmbatleInfoByPage( pageType : int ) : Array {
        return _embedInfo.find( pageType ) as Array;
    }

    public function get talentInfoData():CTalentInfoData
    {
        return _talentInfoData;
    }

    public function get talentMeltData():CTalentMeltingListData
    {
        if(m_pTalentMeltData == null)
        {
            var dataBase:IDatabase = CTalentFacade.getInstance().talentAppSystem.stage.getSystem(IDatabase) as IDatabase;
            m_pTalentMeltData = new CTalentMeltingListData();
            m_pTalentMeltData.databaseSystem = dataBase;
        }

        return m_pTalentMeltData;
    }

    public function getMeltingDataByType(type:int):CTalentMeltingData
    {
        if(m_pTalentMeltData)
        {
           return m_pTalentMeltData.getMeltData(type);
        }

        return null;
    }
}
}

class PrivateClass {

}

