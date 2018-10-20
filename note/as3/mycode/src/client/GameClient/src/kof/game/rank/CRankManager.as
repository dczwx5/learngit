//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/7/20.
 */
package kof.game.rank {

import QFLib.Interface.IUpdatable;

import kof.data.CObjectData;
import kof.framework.CAbstractHandler;
import kof.game.club.data.CClubInfoData;
import kof.game.platform.EPlatformType;
import kof.game.platform.tx.data.CTXData;
import kof.game.player.CPlayerSystem;
import kof.game.rank.data.CRankConst;
import kof.game.rank.data.RankData;
import kof.message.Rank.RankResponse;

public class CRankManager extends CAbstractHandler implements IUpdatable {

    public var rankList : Array;

    public var type : int; //排行榜类型

    public var page : int ;//当前页码

    public var totalPage : int ;//总页数

    public var selfRank : RankData;//自己的排行信息

    public var selfClubRank : CClubInfoData;//自己的俱乐部排行信息

    public var likeList : Array ;//点赞列表

    public var curLikeRoleId : int ; //当前点赞的ID

    public function CRankManager() {
        super();

        rankList = [];
        likeList = [];
    }
    public function update(delta:Number) : void {

    }

    public function updataRankData( response:RankResponse ):void{
        type = response.type;
        page = response.page;
        totalPage = response.totalPage;

        rankList.splice( 0 , rankList.length );
        for each (var data:Object in response.rankData ){
            updataRankDataToDic(data);
        }
        rankList.sortOn( 'rank',Array.NUMERIC );


        if( type == CRankConst.CLUB_RANK ){
            if( response.selfRank.rank ){
                if( !selfClubRank )
                    selfClubRank = new CClubInfoData(system);
                selfClubRank.updateDataByData( response.selfRank );
            }else{
                selfClubRank = null;
            }

        }else{
            if( !selfRank )
                selfRank = new RankData(system);
            selfRank.updateDataByData( response.selfRank );
        }
    }
    public function updataRankDataToDic(data:Object):void{
        if( type == CRankConst.CLUB_RANK ){
            var clubInfoData : CClubInfoData = new CClubInfoData(system);
            clubInfoData.updateDataByData(data);
            rankList.push( clubInfoData );
        }else{
            var rankData : RankData = new RankData(system);
            rankData.updateDataByData(data);
            rankList.push( rankData );
        }

    }

    public function updateCurLikeData():void{
        var objectData : CObjectData = getRankDataByLikeID( curLikeRoleId );
        if(  objectData is CClubInfoData ) {
            ( objectData as CClubInfoData ).like ++;
        }else if(  objectData is RankData  ){
            ( objectData as RankData ).like ++;
        }
    }

    public function getRankDataByLikeID( likeID : int ):CObjectData{
        var objectData : CObjectData;
        for each( objectData in rankList ){
            if( ( objectData is CClubInfoData )  && ( objectData as CClubInfoData ).chairmanInfo.roleID == likeID ){
                  return objectData;
            }else if( ( objectData is RankData ) && ( objectData as RankData )._id == likeID ){
                return objectData;
            }
        }

        return objectData;
    }
    /*
    * type     0:都不是 1：蓝钻 2：黄钻
     subType  蓝钻的时候 1：豪华版年费蓝钻 2：年费蓝钻 3：豪华版蓝钻 4：普通蓝钻
              黄钻的时候 5：年费黄钻 6：普通黄钻
     level    等级
    * */

    public function getTxVipInfo( rankData : RankData ):Object{
        if( !rankData )
                return null;
        var obj : Object = {};
        obj.type = 0;

        var txData:CTXData = (rankData.platformData as CTXData);
        if (!txData) return obj;

        if( _playerSystem.platform.txData.isQGame ){//只显示蓝钻
            if( txData.isBlueVip ){
                obj.type = 1;
                if( txData.isSuperBlueVip && txData.isBlueYearVip ){
                    obj.subType = 1;//豪华版年费蓝钻
                }else if( txData.isBlueYearVip ){
                    obj.subType = 2;//年费蓝钻
                }else if( txData.isSuperBlueVip ){
                    obj.subType = 3;//豪华版蓝钻
                }else {
                    obj.subType = 4;//普通蓝钻
                }
                obj.level = txData.blueVipLevel;
            }

        }else if( _playerSystem.platform.txData.isQZone ){//只显示黄钻
            if( txData.isYellowVip ){
                obj.type = 2;
                if( txData.isYellowYearVip  ){
                    obj.subType = 5;//年费黄钻
                }else{
                    obj.subType = 6;//普通黄钻
                }
                obj.level = txData.yellowVipLevel;
            }

        }

        return obj;

    }

    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }


}
}
