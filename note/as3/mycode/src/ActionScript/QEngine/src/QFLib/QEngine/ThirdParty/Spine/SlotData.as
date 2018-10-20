/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    public class SlotData
    {
        public function SlotData( name : String, boneData : BoneData )
        {
            if( name == null ) throw new ArgumentError( "name cannot be null." );
            if( boneData == null ) throw new ArgumentError( "boneData cannot be null." );
            _name = name;
            _boneData = boneData;
        }
        public var r : Number = 1;
        public var g : Number = 1;
        public var b : Number = 1;
        public var a : Number = 1;
        public var attachmentName : String;
        public var blendMode : BlendMode;

        internal var _name : String;

        public function get name() : String
        {
            return _name;
        }

        internal var _boneData : BoneData;

        public function get boneData() : BoneData
        {
            return _boneData;
        }

        public function toString() : String
        {
            return _name;
        }
    }

}
