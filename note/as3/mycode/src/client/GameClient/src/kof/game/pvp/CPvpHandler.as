//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/26.
 */
package kof.game.pvp {

import kof.framework.CSystemHandler;
import kof.framework.INetworking;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.event.CInstanceEvent;
import kof.message.CAbstractPackMessage;
import kof.message.Pvp.CreateRoomRequest;
import kof.message.Pvp.CreateRoomRespond;
import kof.message.Pvp.FighttingRequest;
import kof.message.Pvp.FighttingRespond;
import kof.message.Pvp.JoinRoomRequest;
import kof.message.Pvp.JoinRoomRespond;
import kof.message.Pvp.LeaveRoomRequest;
import kof.message.Pvp.LeaveRoomRespond;
import kof.message.Pvp.QueryRoomRequest;
import kof.message.Pvp.QueryRoomRespond;

public class CPvpHandler extends CSystemHandler {

    public var roomType:int;

    public function CPvpHandler() {
        super();
    }
    public override function dispose() : void {
        super.dispose();
        _removeEventListeners();
    }

    override protected function onSetup():Boolean
    {
        var ret:Boolean = super.onSetup();
        _addEventListeners();
        return ret;
    }

    override protected function onShutdown():Boolean
    {
        var ret:Boolean = super.onShutdown();
        system.getBean(CPvpViewHandler).removeEventListener(CPvpEvent.QUERY_ROOM,_queryRoomFun);
        system.getBean(CPvpListViewHandler).removeEventListener(CPvpEvent.CREATE_ROOM,_createRoom);
        return ret;
    }

    private function _addEventListeners():void
    {
        system.getBean(CPvpViewHandler).addEventListener(CPvpEvent.QUERY_ROOM,_queryRoomFun);
        networking.bind(QueryRoomRespond).toHandler(_onQueryRoomRespond);
        system.getBean(CPvpListViewHandler).addEventListener(CPvpEvent.CREATE_ROOM,_createRoom);
        networking.bind(CreateRoomRespond).toHandler(_onCreateRoomRespond);
        networking.bind(JoinRoomRespond ).toHandler(_onJoinRoomRespond);
        networking.bind(FighttingRespond ).toHandler(_fighttingRespond);
        networking.bind(LeaveRoomRespond ).toHandler(_leaveRoomRespond);
        var pInstanceSys : IInstanceFacade = system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys ) {
            pInstanceSys.eventDelegate.addEventListener( CInstanceEvent.ENTER_INSTANCE, _onEnterInstance );
        }
    }

    private function _onEnterInstance(e:CInstanceEvent):void{
        var pInstanceSys : IInstanceFacade = system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys && !pInstanceSys.isMainCity) {
            (system.getBean( CPvpListViewHandler ) as CPvpListViewHandler).removeDisplay();
        }
    }

    [Inline]
    private function _removeEventListeners():void
    {
        networking.unbind(QueryRoomRespond);
        networking.unbind(CreateRoomRespond);
        networking.unbind(JoinRoomRespond);
        networking.unbind(FighttingRespond);
        networking.unbind(LeaveRoomRespond);
    }

    //创建房间
    [Inline]
    private function _createRoom(e:CPvpEvent):void{
        var createRoomRequest:CreateRoomRequest = new CreateRoomRequest();
        createRoomRequest.decode([roomType]);
        networking.post(createRoomRequest);
    }

    private final function _onCreateRoomRespond(net:INetworking, message:CAbstractPackMessage):void {
        var response:CreateRoomRespond = message as CreateRoomRespond;
        if(response.ret == 1){
            (system.getBean(CPvpManager) as CPvpManager).createlPvpRoomData(response.info);
        }
    }

    //查询房间
    [Inline]
    private function _queryRoomFun(e:CPvpEvent):void{
        var queryRoomRequest:QueryRoomRequest = new QueryRoomRequest();
        queryRoomRequest.decode([ e.data.selectedIndex + 1 ]);
        networking.post(queryRoomRequest);
        roomType = e.data.selectedIndex + 1;
        (system.getBean( CPvpListViewHandler ) as CPvpListViewHandler).addDisplay();
    }

    private final function _onQueryRoomRespond(net:INetworking, message:CAbstractPackMessage):void {
        var response:QueryRoomRespond = message as QueryRoomRespond;
//        var heroData:CPlayerHeroData = (system.getBean(CPlayerManager) as CPlayerManager).updateHeroData(response);
        (system.getBean(CPvpManager) as CPvpManager).initialPvpListData(response);
    }

    //加入房间
    public function joinRoomRequest(roomId:int):void{
        var joinRoomRequest:JoinRoomRequest = new JoinRoomRequest();
        joinRoomRequest.decode([ roomId ]);
        networking.post(joinRoomRequest);
    }

    private final function _onJoinRoomRespond(net:INetworking, message:CAbstractPackMessage):void {
        var response:JoinRoomRespond = message as JoinRoomRespond;
        if(response.ret == 1)
        {
            (system.getBean(CPvpManager) as CPvpManager).joinRoomData(response.roomDetail);
        }
    }

    //开始挑战
    public function fighttingRequest(roomId:int):void{
        var fighttingRequest:FighttingRequest = new FighttingRequest();
        fighttingRequest.decode([ roomId ]);
        networking.post(fighttingRequest);
    }

    private final function _fighttingRespond(net:INetworking, message:CAbstractPackMessage):void {
        var response:FighttingRespond = message as FighttingRespond;
        trace(response.ret);
    }

    //离开房间
    public function leaveRoomRequest(roomId:int):void{
        var leaveRoomRequest:LeaveRoomRequest = new LeaveRoomRequest();
        leaveRoomRequest.decode([roomId]);
        networking.post(leaveRoomRequest);
    }

    private final function _leaveRoomRespond(net:INetworking, message:CAbstractPackMessage):void {
        var leaveRoomRespond:LeaveRoomRespond = message as LeaveRoomRespond;
        trace(leaveRoomRespond.ret);
    }
}
}
