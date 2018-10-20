/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    public class Event
    {
        public function Event( time : Number, data : EventData )
        {
            if( data == null ) throw new ArgumentError( "data cannot be null." );
            this.time = time;
            _data = data;
        }
        public var time : Number;
        public var intValue : int;
        public var floatValue : Number;
        public var stringValue : String;

        internal var _data : EventData;

        public function get data() : EventData
        {
            return _data;
        }

        public function toString() : String
        {
            return _data._name;
        }
    }

}
