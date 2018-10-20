/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    public class TransformConstraintData
    {
        public function TransformConstraintData( name : String )
        {
            if( name == null ) throw new ArgumentError( "name cannot be null." );
            _name = name;
        }
        public var bone : BoneData;
        public var target : BoneData;
        public var translateMix : Number;
        public var x : Number;
        public var y : Number;

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
