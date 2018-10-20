/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    public class TrackEntry
    {
        public var next : TrackEntry;
        public var animation : Animation;
        public var loop : Boolean;
        public var delay : Number, time : Number = 0, lastTime : Number = -1, endTime : Number, timeScale : Number = 1;
        public var onStart : Function, onEnd : Function, onComplete : Function, onEvent : Function;
        internal var previous : TrackEntry;
        internal var mixTime : Number, mixDuration : Number, mix : Number = 1;

        public function toString() : String
        {
            return animation == null ? "<none>" : animation.name;
        }
    }

}
