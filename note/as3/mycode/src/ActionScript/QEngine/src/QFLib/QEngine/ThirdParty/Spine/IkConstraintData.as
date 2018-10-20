/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    public class IkConstraintData
    {
        public function IkConstraintData( name : String )
        {
            if( name == null ) throw new ArgumentError( "name cannot be null." );
            _name = name;
        }
        public var bones : Vector.<BoneData> = new Vector.<BoneData>();
        public var target : BoneData;
        public var bendDirection : int = 1;
        public var mix : Number = 1;

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
