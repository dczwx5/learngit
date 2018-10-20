/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{

    public class BoneData
    {
        /** @param parent May be null. */
        public function BoneData( name : String, parent : BoneData )
        {
            if( name == null ) throw new ArgumentError( "name cannot be null." );
            _name = name;
            _parent = parent;
        }
        public var length : Number;
        public var x : Number;
        public var y : Number;
        public var rotation : Number;
        public var scaleX : Number = 1;
        public var scaleY : Number = 1;
        public var inheritScale : Boolean = true;
        public var inheritRotation : Boolean = true;

        internal var _name : String;

        public function get name() : String
        {
            return _name;
        }

        internal var _parent : BoneData;

        /** @return May be null. */
        public function get parent() : BoneData
        {
            return _parent;
        }

        public function toString() : String
        {
            return _name;
        }
    }

}
