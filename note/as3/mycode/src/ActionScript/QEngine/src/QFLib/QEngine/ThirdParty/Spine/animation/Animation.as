/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;

    public class Animation
    {
        /** @param target After the first and before the last entry. */
        static public function binarySearch( values : Vector.<Number>, target : Number, step : int ) : int
        {
            var low : int = 0;
            var high : int = values.length / step - 2;
            if( high == 0 )
                return step;
            var current : int = high >>> 1;
            while( true )
            {
                if( values[ int( (current + 1) * step ) ] <= target )
                    low = current + 1;
                else
                    high = current;
                if( low == high )
                    return (low + 1) * step;
                current = (low + high) >>> 1;
            }
            return 0; // Can't happen.
        }

        /** @param target After the first and before the last entry. */
        static public function binarySearch1( values : Vector.<Number>, target : Number ) : int
        {
            var low : int = 0;
            var high : int = values.length - 2;
            if( high == 0 )
                return 1;
            var current : int = high >>> 1;
            while( true )
            {
                if( values[ int( current + 1 ) ] <= target )
                    low = current + 1;
                else
                    high = current;
                if( low == high )
                    return low + 1;
                current = (low + high) >>> 1;
            }
            return 0; // Can't happen.
        }

        static public function linearSearch( values : Vector.<Number>, target : Number, step : int ) : int
        {
            for( var i : int = 0, last : int = values.length - step; i <= last; i += step )
                if( values[ i ] > target )
                    return i;
            return -1;
        }

        public function Animation( name : String, timelines : Vector.<Timeline>, duration : Number )
        {
            if( name == null ) throw new ArgumentError( "name cannot be null." );
            if( timelines == null ) throw new ArgumentError( "timelines cannot be null." );
            _name = name;
            _timelines = timelines;
            this.duration = duration;
        }
        public var duration : Number;

        internal var _name : String;

        public function get name() : String
        {
            return _name;
        }

        private var _timelines : Vector.<Timeline>;

        [Inline]
        final public function get timelines() : Vector.<Timeline>
        {
            return _timelines;
        }

        /** Poses the skeleton at the specified time for this animation. */
        public function apply( skeleton : Skeleton, lastTime : Number, time : Number, loop : Boolean, events : Vector.<Event> ) : void
        {
            if( skeleton == null ) throw new ArgumentError( "skeleton cannot be null." );

            if( loop && duration != 0 )
            {
                time %= duration;
                if( lastTime > 0 ) lastTime %= duration;
            }

            for( var i : int = 0, n : int = timelines.length; i < n; i++ )
                timelines[ i ].apply( skeleton, lastTime, time, events, 1 );
        }

        /** Poses the skeleton at the specified time for this animation mixed with the current pose.
         * @param alpha The amount of this animation that affects the current pose. */
        public function mix( skeleton : Skeleton, lastTime : Number, time : Number, loop : Boolean, events : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            if( skeleton == null ) throw new ArgumentError( "skeleton cannot be null." );

            if( loop && duration != 0 )
            {
                time %= duration;
                if( lastTime > 0 ) lastTime %= duration;
            }

            for( var i : int = 0, n : int = timelines.length; i < n; i++ )
                timelines[ i ].apply( skeleton, lastTime, time, events, alpha, isPassMiddleMixTime );
        }

        public function toString() : String
        {
            return _name;
        }
    }

}
