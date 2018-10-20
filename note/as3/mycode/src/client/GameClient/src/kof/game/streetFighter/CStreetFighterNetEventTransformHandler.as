//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter {


import kof.framework.CAbstractHandler;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.enum.EStreetFighterDataEventType;
import kof.game.streetFighter.event.CStreetFighterEvent;
import kof.message.StreetFighter.StreetFighterFightReportResponse;

// net 事件转换成其他事件
public class CStreetFighterNetEventTransformHandler extends CAbstractHandler {
    public function CStreetFighterNetEventTransformHandler() {
    }

    public override function dispose():void {
        super.dispose();
        _system.unListenEvent(_onNetEvent);
    }


    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();

        _system.listenEvent(_onNetEvent);
        return ret;
    }

    private function _onNetEvent(e:CStreetFighterEvent) : void {
        if (e.type == CStreetFighterEvent.DATA_EVENT) {
            return ;
        }
        var dataObject:Object = e.data as Object;

        switch (e.type) {
            case CStreetFighterEvent.NET_EVENT_DATA :
            case CStreetFighterEvent.NET_EVENT_UPDATE_DATA :
                var oldMatchState:int = _data.matchState;
                if (CStreetFighterEvent.NET_EVENT_DATA == e.type) {
                    // 初始化数据
                    _data.initialData(dataObject);
                } else {
                    // 更新数据
                    _data.updateDataByData(dataObject);

                    // check match stage // 匹配状态  0空闲 1匹配中 2匹配成功
                    var newMatchState:int = _data.matchState;
                    if (oldMatchState != newMatchState) {
                        _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_MATCHING, null));
                    }
                }
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.DATA, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_MATCHING :
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.MATCHING, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_MATCH_DATA :
                _data.updateMatchData(dataObject);
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.MATCH_DATA, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_SELECTED_HERO :
                _data.updateEnemySelectHero(dataObject);
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.SELECT_HERO, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_REPORT_DATA :
                    var reportNetData:StreetFighterFightReportResponse = dataObject as StreetFighterFightReportResponse;
                _data.updateReportData(reportNetData.fightReportDatas, reportNetData.fightData);
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.REPORT, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_RANK_DATA :
                _data.updateRankData(dataObject);
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.RANK, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_LOADING_DATA :
                _data.updateLoadingData(dataObject);
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.LOADING, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_LOADING_PROGRESS_SYNC_DATA :
                _data.updateProgressData({enemyProgress:dataObject as int});
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.LOADING_PROGRESS_SYNC, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_ENTER_ERROR :
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.ENTER_ERROR, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_NOTIFY_CLIENT_REFRESH :
//                _data.isServerData = false;
                _data.resetEnterRoom();
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.DATA, _data));
                break;
            case CStreetFighterEvent.NET_EVENT_GAME_PROMT :

                break;
            case CStreetFighterEvent.NET_EVENT_GET_REWARD :
                var rewardList:Array = e.data as Array;
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.GET_REWARD, rewardList ));
                break;
            case CStreetFighterEvent.NET_EVENT_SELECT_HERO_READY :
                _data.isAllSelectHeroOpened = true;
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.SELECT_HERO_READY ));
                break;
            case CStreetFighterEvent.NET_EVENT_SELECT_HERO_SYNC :
                _data.enemySelectHeroID = e.data as int;
                _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.DATA_EVENT, EStreetFighterDataEventType.ENEMY_SELECT_HERO_SYNC ));
                break;
        }

    }


    [Inline]
    private function get _system() : CStreetFighterSystem {
        return system as CStreetFighterSystem;
    }
    [Inline]
    private function get _data() : CStreetFighterData {
        return _system.data;
    }
}
}
