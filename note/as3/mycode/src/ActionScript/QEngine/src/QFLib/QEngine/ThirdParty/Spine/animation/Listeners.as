/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    public class Listeners
    {
        private var _listeners : Vector.<Function> = new Vector.<Function>();

        public function get listeners() : Vector.<Function>
        {
            return _listeners;
        }

        public function add( listener : Function ) : void
        {
            if( listener == null )
                throw new ArgumentError( "listener cannot be null." );
            _listeners[ _listeners.length ] = listener;
        }

        public function remove( listener : Function ) : void
        {
            if( listener == null )
                throw new ArgumentError( "listener cannot be null." );
            _listeners.splice( _listeners.indexOf( listener ), 1 );
        }

        public function invoke( ...args : * ) : void
        {
            for each ( var listener : Function in _listeners )
                listener.apply( null, args );
        }
    }
}
