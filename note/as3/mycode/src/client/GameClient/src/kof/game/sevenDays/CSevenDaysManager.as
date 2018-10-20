//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/7/27.
 */
package kof.game.sevenDays {

import QFLib.Interface.IUpdatable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.bundle.ISystemBundleContext;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.game.sevenDays.event.CSevenDaysEvent;
import kof.message.Activity.SevenDaysLoginActivityResponse;

public class CSevenDaysManager extends CAbstractHandler implements IUpdatable {

    private var m_pSevenDaysTable : IDataTable;
    private var m_iOpenSeverDays : int;//开服时间
    private var m_sevenDaysStateArr : Array;//七天登录领取状态，0代表未领取 1代表已经领取
    private var m_iSelectedDay : int;
    private var m_iSelectedPage : int;

    public static const ACTIVITY_DAYS : int = 14;
    public static const ROLL_DAYS : int = 1; //每次滚动的天数
    public static const ROLL_MAX : int = (ACTIVITY_DAYS - 7)/ROLL_DAYS;//最大滚动，末尾显示最后一天不能在翻页了

    public function CSevenDaysManager() {
        super();
    }

    override public function dispose() : void
    {
        super.dispose();
        var pPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
        if (pPlayerSystem) {
            pPlayerSystem.removeEventListener(CPlayerEvent.PLAYER_SYSTEM,_onPlayerDataUpdate);
        }
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        m_pSevenDaysTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.SEVEN_DAYS );
        var pPlayerSystem : CPlayerSystem = ( system.stage.getSystem( CPlayerSystem ) as CPlayerSystem );
        pPlayerSystem.addEventListener(CPlayerEvent.PLAYER_SYSTEM,_onPlayerDataUpdate);
        _playerDataUpdate();
        if( sevenDaysStateArr == null )
        {
            return ret;
        }
        m_iSelectedDay = getDefaultSelectDay();
        m_iSelectedPage = (m_iSelectedDay - 1)/ ROLL_DAYS;
        //判断奖励是否已经领完，领完关闭系统入口
        if( allGiftGeted() )
        {
            closeSevenDaysSys();
        }
        return ret;
    }

    /**
     * 默认选择第几天
     * */
    public function getDefaultSelectDay() : int
    {

        if( openSeverDays > ACTIVITY_DAYS || sevenDaysStateArr[ openSeverDays -1 ] == 1 )//如果开服时间超过活动时间或者当天已经领取，从第一天开始选择没有领取
        {
            for( var index : int = 0; index < sevenDaysStateArr.length ; index ++ )
            {
                if( sevenDaysStateArr[ index ] == 0 )
                {
                    return index + 1;
                }
            }
        }
        else
        {
            return openSeverDays;
        }
        return 1;
    }

    public function getSelectedWithPage( page : int ) : int
    {
        var defaultPage : int = ( getDefaultSelectDay() - 1 ) / ROLL_DAYS;
        defaultPage = defaultPage > ROLL_MAX ? ROLL_MAX : defaultPage;
        if( defaultPage == page )
        {
            return getDefaultSelectDay();
        }
        else
        {
            for( var index : int = page * ROLL_DAYS ; index <  page * ROLL_DAYS + 7 ,index < sevenDaysStateArr.length; index ++)
            {
                if( sevenDaysStateArr[ index ] == 0 )
                {
                    return index + 1;
                }
            }
        }
        return 1 + page * ROLL_DAYS;
    }

    /**
     * 领取奖励请求的回应数据
     * */
    public function updateSevenDaysState( response : SevenDaysLoginActivityResponse ):void
    {
        var stateArr : Array = response.getRewardState;
        m_sevenDaysStateArr = stateArr;
    }

    private function _onPlayerDataUpdate( e : CPlayerEvent ) : void
    {
        _playerDataUpdate();
        system.dispatchEvent( new CSevenDaysEvent( CSevenDaysEvent.SEVEN_DAYS_SEVER_UPDATE ) );
    }

    /**
     * 玩家数据更新
     * */
    private function _playerDataUpdate() : void
    {
        m_iOpenSeverDays = pCPlayerData.systemData.openSeverDays;
        m_sevenDaysStateArr = pCPlayerData.systemData.sevenDaysLoginActivityState;
    }

    /**
     * 是否有可以领取的奖励
     * **/
    public function canGetReward() : Boolean
    {
        var result : Boolean = false;
        for( var i : int = 0; i < m_sevenDaysStateArr.length , i < m_iOpenSeverDays ; i++ )
        {
            if( m_sevenDaysStateArr[ i ] == 0 ) //可以领取
            {
                result = true;
            }
        }
        return result;
    }

    private function get pCPlayerData() : CPlayerData
    {
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        return playerManager.playerData;
    }

    /**
     * 判断奖励是否已领取完
     * */
    public function allGiftGeted() : Boolean
    {
        var result : Boolean = true;
        for( var index : int = 0; index <  m_sevenDaysStateArr.length; index ++)
        {
            if( m_sevenDaysStateArr[index] == 0)
            {
                result = false;
                break;
            }
        }
        return result;
    }

    /**
     * 关闭系统入口
     * */
    public function closeSevenDaysSys() : void
    {
        var sys : ISystemBundleContext =  ( system.stage.getSystem(CSevenDaysSystem) as CSevenDaysSystem).ctx;
        if( sys )
        {
            sys.unregisterSystemBundle(system.stage.getSystem(CSevenDaysSystem) as CSevenDaysSystem);
        }
    }

    public function get sevenDaysTable() : IDataTable //七天登录活动配置
    {
        return m_pSevenDaysTable;
    }

    public function get openSeverDays() : int //开服时间获取
    {
        return m_iOpenSeverDays;
    }

    public function get sevenDaysStateArr() : Array //七天登录领取状态
    {
        return m_sevenDaysStateArr;
    }

    public function set selectedDay( value : int ) : void
    {
        m_iSelectedDay = value;
    }

    public function get selectedDay() : int //选择查看的第几天的奖励
    {
        return m_iSelectedDay;
    }

    public function set selectedPage( value : int ) : void
    {
        m_iSelectedPage = value;
    }
    public function get selectedPage() : int //选择第几页
    {
        //处理超出最大页数
        m_iSelectedPage = m_iSelectedPage > ROLL_MAX ? ROLL_MAX : m_iSelectedPage;
        return m_iSelectedPage;
    }

    public function update( delta : Number ) : void
    {

    }
}
}
