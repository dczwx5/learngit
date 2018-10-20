/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    import QFLib.QEngine.ThirdParty.Spine.attachments.Attachment;

    public class Skeleton
    {
        public function Skeleton( data : SkeletonData )
        {
            if( data == null )
                throw new ArgumentError( "data cannot be null." );
            _data = data;

            bones = new Vector.<Bone>();
            for each ( var boneData : BoneData in data.bones )
            {
                var parent : Bone = boneData.parent == null ? null : bones[ data.bones.indexOf( boneData.parent ) ];
                bones[ bones.length ] = new Bone( boneData, this, parent );
            }

            slots = new Vector.<Slot>();
            drawOrder = new Vector.<Slot>();
            for each ( var slotData : SlotData in data.slots )
            {
                var bone : Bone = bones[ data.bones.indexOf( slotData.boneData ) ];
                var slot : Slot = new Slot( slotData, bone );
                slots[ slots.length ] = slot;
                drawOrder[ drawOrder.length ] = slot;
            }

            ikConstraints = new Vector.<IkConstraint>();
            for each ( var ikConstraintData : IkConstraintData in data.ikConstraints )
                ikConstraints[ ikConstraints.length ] = new IkConstraint( ikConstraintData, this );

            transformConstraints = new Vector.<TransformConstraint>();
            for each ( var transformConstraintData : TransformConstraintData in data.transformConstraints )
                transformConstraints[ transformConstraints.length ] = new TransformConstraint( transformConstraintData, this );

            updateCache();
        }
        public var bones : Vector.<Bone>;
        public var slots : Vector.<Slot>;
        public var drawOrder : Vector.<Slot>;
        public var ikConstraints : Vector.<IkConstraint>;
        public var transformConstraints : Vector.<TransformConstraint>;
        public var r : Number = 1, g : Number = 1, b : Number = 1, a : Number = 1;
        public var time : Number = 0;
        public var flipX : Boolean, flipY : Boolean;
        public var x : Number = 0, y : Number = 0;
        private var _updateCache : Vector.<Updatable> = new Vector.<Updatable>();

        internal var _data : SkeletonData;

        public function get data() : SkeletonData
        {
            return _data;
        }

        private var _skin : Skin;

        public function get skin() : Skin
        {
            return _skin;
        }

        /** Sets the skin used to look up attachments before looking in the {@link QFLib.QEngine.ThirdParty.Spine.SkeletonData#getDefaultSkin() default skin}.
         * Attachments from the new skin are attached if the corresponding attachment from the old skin was attached. If there was
         * no old skin, each slot's setup mode attachment is attached from the new skin.
         * @param newSkin May be null. */
        public function set skin( newSkin : Skin ) : void
        {
            if( newSkin )
            {
                if( skin )
                    newSkin.attachAll( this, skin );
                else
                {
                    var i : int = 0;
                    for each ( var slot : Slot in slots )
                    {
                        var name : String = slot._data.attachmentName;
                        if( name )
                        {
                            var attachment : Attachment = newSkin.getAttachment( i, name );
                            if( attachment ) slot.attachment = attachment;
                        }
                        i++;
                    }
                }
            }
            _skin = newSkin;
        }

        public function get rootBone() : Bone
        {
            if( bones.length == 0 ) return null;
            return bones[ 0 ];
        }

        /** @return May be null. */
        public function get skinName() : String
        {
            return _skin == null ? null : _skin._name;
        }

        public function set skinName( skinName : String ) : void
        {
            var skin : Skin = data.findSkin( skinName );
            if( skin == null ) throw new ArgumentError( "Skin not found: " + skinName );
            this.skin = skin;
        }

        /** Caches information about bones and constraints. Must be called if bones or constraints are added or removed. */
        public function updateCache() : void
        {
            var updateCache : Vector.<Updatable> = _updateCache;
            var ikConstraints : Vector.<IkConstraint> = this.ikConstraints;
            var transformConstraints : Vector.<TransformConstraint> = this.transformConstraints;
            updateCache.length = bones.length + ikConstraints.length;
            var i : int = 0;
            for each ( var bone : Bone in bones )
            {
                updateCache[ i++ ] = bone;
                for each ( var ikConstraint : IkConstraint in ikConstraints )
                {
                    if( bone == ikConstraint.bones[ ikConstraint.bones.length - 1 ] )
                    {
                        updateCache[ i++ ] = ikConstraint;
                        break;
                    }
                }
            }

            for each ( var transformConstraint : TransformConstraint in transformConstraints )
            {
                for( i = updateCache.length - 1; i >= 0; i-- )
                {
                    var updatable : Updatable = updateCache[ i ];
                    if( updatable == transformConstraint.bone || updatable == transformConstraint.target )
                    {
                        updateCache.splice( i + 1, 0, transformConstraint );
                        break;
                    }
                }
            }
        }

        /** Updates the world transform for each bone and applies constraints. */
        public function updateWorldTransform() : void
        {
            for each ( var updatable : Updatable in _updateCache )
                updatable.update();
        }

        /** Sets the bones, constraints, and slots to their setup pose values. */
        public function setToSetupPose() : void
        {
            setBonesToSetupPose();
            setSlotsToSetupPose();
        }

        /** Sets the bones and constraints to their setup pose values. */
        public function setBonesToSetupPose() : void
        {
            for each ( var bone : Bone in bones )
                bone.setToSetupPose();

            for each ( var ikConstraint : IkConstraint in ikConstraints )
            {
                ikConstraint.bendDirection = ikConstraint._data.bendDirection;
                ikConstraint.mix = ikConstraint._data.mix;
            }

            for each ( var transformConstraint : TransformConstraint in transformConstraints )
            {
                transformConstraint.translateMix = transformConstraint._data.translateMix;
                transformConstraint.x = transformConstraint._data.x;
                transformConstraint.y = transformConstraint._data.y;
            }
        }

        public function setSlotsToSetupPose() : void
        {
            var i : int = 0;
            for each ( var slot : Slot in slots )
            {
                drawOrder[ i++ ] = slot;
                slot.setToSetupPose();
            }
        }

        /** @return May be null. */
        public function findBone( boneName : String ) : Bone
        {
            if( boneName == null )
                throw new ArgumentError( "boneName cannot be null." );
            for each ( var bone : Bone in bones )
                if( bone.data._name == boneName ) return bone;
            return null;
        }

        /** @return -1 if the bone was not found. */
        public function findBoneIndex( boneName : String ) : int
        {
            if( boneName == null )
                throw new ArgumentError( "boneName cannot be null." );
            var i : int = 0;
            for each ( var bone : Bone in bones )
            {
                if( bone.data._name == boneName ) return i;
                i++;
            }
            return -1;
        }

        /** @return May be null. */
        public function findSlot( slotName : String ) : Slot
        {
            if( slotName == null )
                throw new ArgumentError( "slotName cannot be null." );
            for each ( var slot : Slot in slots )
                if( slot._data._name == slotName ) return slot;
            return null;
        }

        /** @return -1 if the bone was not found. */
        public function findSlotIndex( slotName : String ) : int
        {
            if( slotName == null )
                throw new ArgumentError( "slotName cannot be null." );
            var i : int = 0;
            for each ( var slot : Slot in slots )
            {
                if( slot._data._name == slotName ) return i;
                i++;
            }
            return -1;
        }

        /** @return May be null. */
        public function getAttachmentForSlotName( slotName : String, attachmentName : String ) : Attachment
        {
            return getAttachmentForSlotIndex( data.findSlotIndex( slotName ), attachmentName );
        }

        /** @return May be null. */
        public function getAttachmentForSlotIndex( slotIndex : int, attachmentName : String ) : Attachment
        {
            if( attachmentName == null ) throw new ArgumentError( "attachmentName cannot be null." );
            if( skin != null )
            {
                var attachment : Attachment = skin.getAttachment( slotIndex, attachmentName );
                if( attachment != null ) return attachment;
            }
            if( data.defaultSkin != null ) return data.defaultSkin.getAttachment( slotIndex, attachmentName );
            return null;
        }

        /** @param attachmentName May be null. */
        public function setAttachment( slotName : String, attachmentName : String ) : void
        {
            if( slotName == null ) throw new ArgumentError( "slotName cannot be null." );
            var i : int = 0;
            for each ( var slot : Slot in slots )
            {
                if( slot._data._name == slotName )
                {
                    var attachment : Attachment = null;
                    if( attachmentName != null )
                    {
                        attachment = getAttachmentForSlotIndex( i, attachmentName );
                        if( attachment == null )
                            throw new ArgumentError( "Attachment not found: " + attachmentName + ", for slot: " + slotName );
                    }
                    slot.attachment = attachment;
                    return;
                }
                i++;
            }
            throw new ArgumentError( "Slot not found: " + slotName );
        }

        /** @return May be null. */
        public function findIkConstraint( constraintName : String ) : IkConstraint
        {
            if( constraintName == null ) throw new ArgumentError( "constraintName cannot be null." );
            for each ( var ikConstraint : IkConstraint in ikConstraints )
                if( ikConstraint._data._name == constraintName ) return ikConstraint;
            return null;
        }

        /** @return May be null. */
        public function findTransformConstraint( constraintName : String ) : TransformConstraint
        {
            if( constraintName == null ) throw new ArgumentError( "constraintName cannot be null." );
            for each ( var transformConstraint : TransformConstraint in transformConstraints )
                if( transformConstraint._data._name == constraintName ) return transformConstraint;
            return null;
        }

        public function update( delta : Number ) : void
        {
            time += delta;
        }

        public function toString() : String
        {
            return _data.name != null ? _data.name : super.toString();
        }
    }

}
