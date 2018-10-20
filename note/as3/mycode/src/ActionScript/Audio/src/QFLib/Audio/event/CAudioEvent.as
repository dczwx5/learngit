/**
 * Created by Administrator on 2016/8/5.
 */
package QFLib.Audio.event {
import QFLib.Audio.audio.CAudioMP3Source;

import flash.events.Event;

public class CAudioEvent extends Event {

    public static const SOUND_COMPLETE:String = "SOUND_COMPLETE";

    public static const SOUND_START:String = "SOUND_START";

    public static const IO_ERROR:String = "IO_ERROR";

    public var soundItem:CAudioMP3Source;

    public function CAudioEvent(type:String, soundItem:CAudioMP3Source = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);

        this.soundItem = soundItem;
    }

    override public function clone():Event
    {
        return (new CAudioEvent(type,this.soundItem, bubbles, cancelable));
    }
}
}
