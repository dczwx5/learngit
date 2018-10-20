/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{

    public class EventData
    {
        public function EventData( name : String )
        {
            if( name == null ) throw new ArgumentError( "name cannot be null." );
            _name = name;
        }
        public var intValue : int;
        ;
        public var floatValue : Number;
        public var stringValue : String;

        internal var _name : String;

        public function get name() : String
        {
            return _name;
        }

        public function toString() : String
        {
            return _name;
        }
    }

}
