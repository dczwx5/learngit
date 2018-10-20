/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{

    public class TransformConstraint implements Updatable
    {
        public function TransformConstraint( data : TransformConstraintData, skeleton : Skeleton )
        {
            if( data == null ) throw new ArgumentError( "data cannot be null." );
            if( skeleton == null ) throw new ArgumentError( "skeleton cannot be null." );
            _data = data;
            translateMix = data.translateMix;
            x = data.x;
            y = data.y;

            bone = skeleton.findBone( data.bone._name );
            target = skeleton.findBone( data.target._name );
        }
        public var bone : Bone;
        public var target : Bone;
        public var translateMix : Number;
        public var x : Number;
        public var y : Number;

        internal var _data : TransformConstraintData;

        public function get data() : TransformConstraintData
        {
            return _data;
        }

        public function apply() : void
        {
            update();
        }

        public function update() : void
        {
            var translateMix : Number = translateMix;
            if( translateMix > 0 )
            {
                var local : Vector.<Number> = new Vector.<Number>( 2, true );
                local[ 0 ] = x;
                local[ 1 ] = y;
                target.localToWorld( local );
                bone.worldX += (local[ 0 ] - bone.worldX) * translateMix;
                bone.worldY += (local[ 1 ] - bone.worldY) * translateMix;
            }
        }

        public function toString() : String
        {
            return _data._name;
        }
    }

}
