/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    import QFLib.QEngine.ThirdParty.Spine.animation.Animation;

    public class SkeletonData
    {
        /** May be null. */
        public var name : String;
        public var bones : Vector.<BoneData> = new Vector.<BoneData>(); // Ordered parents first.
        public var slots : Vector.<SlotData> = new Vector.<SlotData>(); // Setup pose draw order.
        public var skins : Vector.<Skin> = new Vector.<Skin>();
        public var defaultSkin : Skin;
        public var events : Vector.<EventData> = new Vector.<EventData>();
        public var animations : Vector.<Animation> = new Vector.<Animation>();
        public var ikConstraints : Vector.<IkConstraintData> = new Vector.<IkConstraintData>();
        public var transformConstraints : Vector.<TransformConstraintData> = new Vector.<TransformConstraintData>();
        public var width : Number, height : Number;
        public var version : String, hash : String;

        // --- Bones.

        /** @return May be null. */
        public function findBone( boneName : String ) : BoneData
        {
            if( boneName == null ) throw new ArgumentError( "boneName cannot be null." );
            for( var i : int = 0, n : int = bones.length; i < n; i++ )
            {
                var bone : BoneData = bones[ i ];
                if( bone._name == boneName ) return bone;
            }
            return null;
        }

        /** @return -1 if the bone was not found. */
        public function findBoneIndex( boneName : String ) : int
        {
            if( boneName == null ) throw new ArgumentError( "boneName cannot be null." );
            for( var i : int = 0, n : int = bones.length; i < n; i++ )
                if( bones[ i ]._name == boneName ) return i;
            return -1;
        }

        // --- Slots.

        /** @return May be null. */
        public function findSlot( slotName : String ) : SlotData
        {
            if( slotName == null ) throw new ArgumentError( "slotName cannot be null." );
            for( var i : int = 0, n : int = slots.length; i < n; i++ )
            {
                var slot : SlotData = slots[ i ];
                if( slot._name == slotName ) return slot;
            }
            return null;
        }

        /** @return -1 if the bone was not found. */
        public function findSlotIndex( slotName : String ) : int
        {
            if( slotName == null ) throw new ArgumentError( "slotName cannot be null." );
            for( var i : int = 0, n : int = slots.length; i < n; i++ )
                if( slots[ i ]._name == slotName ) return i;
            return -1;
        }

        // --- Skins.

        /** @return May be null. */
        public function findSkin( skinName : String ) : Skin
        {
            if( skinName == null ) throw new ArgumentError( "skinName cannot be null." );
            for each ( var skin : Skin in skins )
                if( skin._name == skinName ) return skin;
            return null;
        }

        // --- Events.

        /** @return May be null. */
        public function findEvent( eventName : String ) : EventData
        {
            if( eventName == null ) throw new ArgumentError( "eventName cannot be null." );
            for each ( var eventData : EventData in events )
                if( eventData._name == eventName ) return eventData;
            return null;
        }

        // --- Animations.

        /** @return May be null. */
        public function findAnimation( animationName : String ) : Animation
        {
            if( animationName == null ) throw new ArgumentError( "animationName cannot be null." );
            for each ( var animation : Animation in animations )
                if( animation.name == animationName ) return animation;
            return null;
        }

        // --- IK constraints.

        /** @return May be null. */
        public function findIkConstraint( constraintName : String ) : IkConstraintData
        {
            if( constraintName == null ) throw new ArgumentError( "constraintName cannot be null." );
            for each ( var ikConstraintData : IkConstraintData in ikConstraints )
                if( ikConstraintData._name == constraintName ) return ikConstraintData;
            return null;
        }

        // --- Transform constraints.

        /** @return May be null. */
        public function findTransformConstraint( constraintName : String ) : TransformConstraintData
        {
            if( constraintName == null ) throw new ArgumentError( "constraintName cannot be null." );
            for each ( var transformConstraintData : TransformConstraintData in transformConstraints )
                if( transformConstraintData._name == constraintName ) return transformConstraintData;
            return null;
        }

        // ---

        public function toString() : String
        {
            return name != null ? name : super.toString();
        }
    }

}
