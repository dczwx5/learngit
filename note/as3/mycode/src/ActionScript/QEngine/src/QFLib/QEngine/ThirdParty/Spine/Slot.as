/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    import QFLib.QEngine.ThirdParty.Spine.attachments.Attachment;

    public class Slot
    {
        public function Slot( data : SlotData, bone : Bone )
        {
            if( data == null ) throw new ArgumentError( "data cannot be null." );
            if( bone == null ) throw new ArgumentError( "bone cannot be null." );
            _data = data;
            _bone = bone;
            setToSetupPose();
        }
        public var r : Number;
        public var g : Number;
        public var b : Number;
        public var a : Number;
        public var attachmentVertices : Vector.<Number> = new Vector.<Number>();

        internal var _data : SlotData;

        public function get data() : SlotData
        {
            return _data;
        }

        internal var _bone : Bone;

        public function get bone() : Bone
        {
            return _bone;
        }

        internal var _attachment : Attachment;

        /** @return May be null. */
        public function get attachment() : Attachment
        {
            return _attachment;
        }

        /** Sets the attachment and resets {@link #getAttachmentTime()}.
         * @param attachment May be null. */
        public function set attachment( attachment : Attachment ) : void
        {
            if( _attachment == attachment ) return;
            _attachment = attachment;
            _attachmentTime = _bone.skeleton.time;
            attachmentVertices.length = 0;
        }

        private var _attachmentTime : Number;

        /** Returns the time since the attachment was set. */
        public function get attachmentTime() : Number
        {
            return _bone.skeleton.time - _attachmentTime;
        }

        public function set attachmentTime( time : Number ) : void
        {
            _attachmentTime = _bone.skeleton.time - time;
        }

        public function get skeleton() : Skeleton
        {
            return _bone.skeleton;
        }

        public function setToSetupPose() : void
        {
            var slotIndex : int = _bone.skeleton.data.slots.indexOf( data );
            r = _data.r;
            g = _data.g;
            b = _data.b;
            a = _data.a;
            if( _data.attachmentName == null )
                attachment = null;
            else
            {
                _attachment = null;
                attachment = _bone.skeleton.getAttachmentForSlotIndex( slotIndex, data.attachmentName );
            }
        }

        public function toString() : String
        {
            return _data.name;
        }
    }

}
