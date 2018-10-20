//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.activityTreasure {

import kof.framework.INetworking;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.data.CActivityState;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityTreasure.data.CActivityTreasureTaskData;
import kof.game.activityTreasure.data.CDartsPointData;
import kof.game.activityTreasure.data.CTreasureBoxData;
import kof.game.common.system.CNetHandlerImp;
import kof.message.Activity.ActivityChangeResponse;
import kof.message.Activity.DigTreasureActivityDataRequest;
import kof.message.Activity.DigTreasureActivityDataResponse;
import kof.message.Activity.DigTreasureActivityDataUpdateEvent;
import kof.message.Activity.DigTreasureRequest;
import kof.message.Activity.DigTreasureResponse;
import kof.message.Activity.OpenDigTreasureBoxRequest;
import kof.message.Activity.OpenDigTreasureBoxResponse;
import kof.message.CAbstractPackMessage;

public class CActivityTreasureHandler extends CNetHandlerImp {

    private var _isDispose : Boolean;

    public function CActivityTreasureHandler() {
        super();

        _isDispose = false;
    }

    public override function dispose() : void {
        if ( _isDispose ) return;
        super.dispose();
        this.unbind( DigTreasureActivityDataResponse );
        this.unbind( DigTreasureResponse );
        this.unbind( OpenDigTreasureBoxResponse );
        this.unbind( DigTreasureActivityDataUpdateEvent );

        _isDispose = true;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        this.bind( DigTreasureActivityDataResponse, _onDigTreasureActivityDataResponseHandler );
        this.bind( DigTreasureResponse, _onDigTreasureResponseHandler );
        this.bind( OpenDigTreasureBoxResponse, _onOpenDigTreasureBoxResponseHandler );
        this.bind( DigTreasureActivityDataUpdateEvent, _onDigTreasureActivityDataUpdateEventHandler );

        _addEventListener();
        return ret;
    }

    private function _addEventListener() : void {
        activityHallSystem.addEventListener( CActivityHallEvent.ActivityStateChanged, _onActivityStateRespone );
    }

    private function get activityHallSystem() : CActivityHallSystem {
        return system.stage.getSystem( CActivityHallSystem ) as CActivityHallSystem;
    }

    /**
     * 活动状态变更
     * @param event
     */
    private function _onActivityStateRespone( event : CActivityHallEvent ) : void {
        var response : ActivityChangeResponse = event.data as ActivityChangeResponse;
        if ( !response ) return;

        var activityType : int = activityTreasureManager.getActivityType( response.activityID );
        if ( activityType == CActivityHallActivityType.ACTIVITY_TREASURE ) {
            activityTreasureManager.curActivityId = response.activityID;
            //1准备中2进行中3已完成4已结束5已关闭/
            activityTreasureManager.curActivityState = response.state;
            if ( response.params ) {
                activityTreasureManager.startTime = response.params.startTick;
                activityTreasureManager.endTime = response.params.endTick;
            }
            if ( response.state == CActivityState.ACTIVITY_START ) {
                activityTreasureManager.openActivity();
            }
            else if ( response.state == CActivityState.ACTIVITY_END ) {
                activityTreasureManager.closeActivity();
                activityTreasureManager.curActivityId = 0;
            }
        }
    }

    public function get activityTreasureManager() : CActivityTreasureManager {
        return system.getBean( CActivityTreasureManager ) as CActivityTreasureManager;
    }


    /**
     * 向服务器请求影二的修行活动数据
     * @param activityId 活动Id
     */
    public function onDigTreasureActivityDataRequest( activityId : int ) : void {
        var request : DigTreasureActivityDataRequest = new DigTreasureActivityDataRequest();
        request.activityId = activityId;
        networking.post( request );
    }

    /**
     * 向服务器请求影二的修行活动数据的反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onDigTreasureActivityDataResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : DigTreasureActivityDataResponse = message as DigTreasureActivityDataResponse;

        //活动时间
//        activityTreasureManager.startTime = response.startTime;
//        activityTreasureManager.endTime = response.endTime;
        //苦无数量
        activityTreasureManager.dartsNum = response.shovelNum;
        //如果是一个空数组，则表示需要重置
        if ( response.diggedPoints.length == 0 ) {
            activityTreasureManager.dartsBoardStateArr.splice( 0 );
            for ( var p : int = 1; p <= 16; p++ ) {
                activityTreasureManager.dartsBoardStateArr.push( new CDartsPointData( p ) );
            }
        }
        else {
            //苦无靶子
            for ( var i : int = 0; i < response.diggedPoints.length; i++ ) {
                var pointId : int = response.diggedPoints[ i ];
                for ( var j : int = 0; j < activityTreasureManager.dartsBoardStateArr.length; j++ ) {
                    var dartsPointData : CDartsPointData = activityTreasureManager.dartsBoardStateArr[ j ] as CDartsPointData;
                    if ( pointId == dartsPointData.m_id ) {
                        dartsPointData.m_state = 1;
                        break;
                    }
                }
            }
        }
        //福袋
        for ( var m : int = 0; m < response.treasureBoxes.length; m++ ) {
            var obj : Object = response.treasureBoxes[ m ];
            for ( var n : int = 0; n < activityTreasureManager.treasureBoxArr.length; n++ ) {
                var treasureBoxData : CTreasureBoxData = activityTreasureManager.treasureBoxArr[ n ] as CTreasureBoxData;
                if ( obj.boxId == treasureBoxData.m_boxId ) {
                    treasureBoxData.m_boxState = obj.state;
                    break;
                }
            }
        }
        //任务数据
        for ( var t : int = 0; t < response.taskDatas.length; t++ ) {
            var obj2 : Object = response.taskDatas[ t ];
            for ( var k : int = 0; k < activityTreasureManager.taskDataArr.length; k++ ) {
                var treasureTaskData : CActivityTreasureTaskData = activityTreasureManager.taskDataArr[ k ] as CActivityTreasureTaskData;
                if ( obj2.id == treasureTaskData.m_id ) {
                    treasureTaskData.m_currVal = obj2.currVal;
                    treasureTaskData.m_state = obj2.state;
                    break;
                }
            }
        }

        //抛事件要求更新
        system.dispatchEvent( new CActivityTreasureEvent( CActivityTreasureEvent.DigTreasureActivityDataResponse ) );
    }

    /**
     * 向服务器请求发射飞镖射中指定点
     * @param pointId 飞镖点索引
     */
    public function onDigTreasureRequest( pointId : int ) : void {
        var request : DigTreasureRequest = new DigTreasureRequest();
        request.pointId = pointId;
        networking.post( request );
    }

    /**
     * 向服务器请求发射飞镖射中指定点的反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onDigTreasureResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : DigTreasureResponse = message as DigTreasureResponse;

        //抛事件告知获得的奖励
        system.dispatchEvent( new CActivityTreasureEvent( CActivityTreasureEvent.DigTreasureResponse, response.awardId ) );
    }

    /**
     * 向服务器请求打开宝箱
     * @param boxId 宝箱Id
     */
    public function onOpenDigTreasureBoxRequest( boxId : int ) : void {
        var request : OpenDigTreasureBoxRequest = new OpenDigTreasureBoxRequest();
        request.boxId = boxId;
        networking.post( request );
    }

    /**
     * 向服务器请求打开宝箱的反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onOpenDigTreasureBoxResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : OpenDigTreasureBoxResponse = message as OpenDigTreasureBoxResponse;

        //抛事件告知获得的奖励
        system.dispatchEvent( new CActivityTreasureEvent( CActivityTreasureEvent.OpenDigTreasureBoxResponse, response.boxId ) );
    }

    /**
     * 影二的修行活动数据更新的反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onDigTreasureActivityDataUpdateEventHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;
        var response : DigTreasureActivityDataUpdateEvent = message as DigTreasureActivityDataUpdateEvent;
        //如果苦无数量有变动
        if ( response.updateData.hasOwnProperty( "shovelNum" ) ) {
            activityTreasureManager.dartsNum = response.updateData.shovelNum;
        }
        //如果飞镖靶子数据有变动
        if ( response.updateData.hasOwnProperty( "diggedPoints" ) ) {
            var diggedPointsArr : Array = response.updateData.diggedPoints as Array;
            //如果是一个空数组，则表示需要重置
            if ( diggedPointsArr.length == 0 ) {
                activityTreasureManager.dartsBoardStateArr.splice( 0 );
                for ( var p : int = 1; p <= 16; p++ ) {
                    activityTreasureManager.dartsBoardStateArr.push( new CDartsPointData( p ) );
                }
            }
            else {
                for ( var i : int = 0; i < diggedPointsArr.length; i++ ) {
                    var pointId : int = diggedPointsArr[ i ];
                    for ( var j : int = 0; j < activityTreasureManager.dartsBoardStateArr.length; j++ ) {
                        var dartsPointData : CDartsPointData = activityTreasureManager.dartsBoardStateArr[ j ] as CDartsPointData;
                        if ( pointId == dartsPointData.m_id ) {
                            dartsPointData.m_state = 1;
                            break;
                        }
                    }
                }
            }
        }
        //如果福袋数据有变动
        if ( response.updateData.hasOwnProperty( "treasureBoxes" ) ) {
            var treasureBoxArr : Array = response.updateData.treasureBoxes as Array;
            for ( var m : int = 0; m < treasureBoxArr.length; m++ ) {
                var obj : Object = treasureBoxArr[ m ];
                for ( var n : int = 0; n < activityTreasureManager.treasureBoxArr.length; n++ ) {
                    var treasureBoxData : CTreasureBoxData = activityTreasureManager.treasureBoxArr[ n ] as CTreasureBoxData;
                    if ( obj.boxId == treasureBoxData.m_boxId ) {
                        treasureBoxData.m_boxState = obj.state;
                        break;
                    }
                }
            }
        }
        //如果任务数据有变动
        if ( response.updateData.hasOwnProperty( "treasureTasks" ) ) {
            var treasureTaskArr : Array = response.updateData.treasureTasks as Array;
            for ( var t : int = 0; t < treasureTaskArr.length; t++ ) {
                var obj2 : Object = treasureTaskArr[ t ];
                for ( var k : int = 0; k < activityTreasureManager.taskDataArr.length; k++ ) {
                    var treasureTaskData : CActivityTreasureTaskData = activityTreasureManager.taskDataArr[ k ] as CActivityTreasureTaskData;
                    if ( obj2.id == treasureTaskData.m_id ) {
                        treasureTaskData.m_currVal = obj2.currVal;
                        treasureTaskData.m_state = obj2.state;
                        break;
                    }
                }
            }
        }

        system.dispatchEvent( new CActivityTreasureEvent( CActivityTreasureEvent.DigTreasureActivityDataUpdateEvent ) );
    }

}
}
