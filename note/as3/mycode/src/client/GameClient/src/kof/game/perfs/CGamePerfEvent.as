package kof.game.perfs {

import flash.events.Event;

/**
 * @author jeremy (jeremy@qifun.com)
 */
public class CGamePerfEvent extends Event {

    static public const EVENT_TRIGGERED : String = "_PerfEventTriggered_";
    static public const EVENT_SYNC : String = "_PerfSyncCheckPoint_";
    public static const EVENT_SNAPSHOT : String = "_PerfSnapshot_";

    public function CGamePerfEvent( name : String ) {
        super( name, false, false );
    }

    public var record : CGamePerfRecord;

} // class CGamePerfEvent

} // package kof.game.perfs
