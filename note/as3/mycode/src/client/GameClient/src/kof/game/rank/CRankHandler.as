//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/7/20.
 */
package kof.game.rank {

import kof.framework.INetworking;
import kof.game.club.CClubHandler;
import kof.game.club.CClubSystem;
import kof.game.common.system.CNetHandlerImp;
import kof.game.rank.data.CRankConst;
import kof.message.CAbstractPackMessage;
import kof.message.Rank.RankLikeRequest;
import kof.message.Rank.RankLikeResponse;
import kof.message.Rank.RankRequest;
import kof.message.Rank.RankResponse;
import kof.ui.CUISystem;

public class CRankHandler extends CNetHandlerImp {

    public function CRankHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(RankResponse, _onRankResponseHandler);
        this.bind(RankLikeResponse, _onRankLikeResponseHandler);

        return ret;
    }
    /**********************Request********************************/

    /*排行榜请求*/
    public function onRankRequest( type :int ,page : int ):void{
        var request:RankRequest = new RankRequest();
        request.decode([type,page]);

        networking.post(request);
    }
    /*点赞请求*/
    public function onRankLikeRequest( type :int ,likeRoleId :Number ):void{
        var request:RankLikeRequest = new RankLikeRequest();
        request.decode([type,likeRoleId]);
        _pRankManager.curLikeRoleId = likeRoleId;

        networking.post(request);
    }

    /**********************Response********************************/

    /*排行榜响应*/
    private final function _onRankResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:RankResponse = message as RankResponse;
        _pRankManager.updataRankData( response );
        _pRankManager.likeList =  response.likeList;
        system.dispatchEvent(new CRankEvent(CRankEvent.RANK_DATA_UPDATE ));
    }

    /*点赞响应*/
    private final function _onRankLikeResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:RankLikeResponse = message as RankLikeResponse;
        _pRankManager.likeList =  response.likeList;
        if( !_pRankManager.likeList )
            _pRankManager.likeList = [];
        if( _pRankManager.likeList.length > 0 ){
            _pRankManager.updateCurLikeData();
            system.dispatchEvent(new CRankEvent(CRankEvent.LIKE_DATA_UPDATE ));
        }

    }

    private function get _pRankManager():CRankManager{
        return system.getBean( CRankManager ) as CRankManager;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pClubHandler():CClubHandler{
        return _pClubSystem.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubSystem():CClubSystem{
        return system.stage.getSystem( CClubSystem ) as CClubSystem;
    }

}
}
