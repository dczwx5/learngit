/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;

    public class AttachmentTimeline implements Timeline
    {
        public function AttachmentTimeline( frameCount : int )
        {
            frames = new Vector.<Number>( frameCount, true );
            attachmentNames = new Vector.<String>( frameCount, true );
        }
                public var slotIndex : int; // time, ...
public var frames : Vector.<Number>;
        public var attachmentNames : Vector.<String>;

        public function get frameCount() : int
        {
            return frames.length;
        }

        /** Sets the time and value of the specified keyframe. */
        [Inline]
        final public function setFrame( frameIndex : int, time : Number, attachmentName : String ) : void
        {
            frames[ frameIndex ] = time;
            attachmentNames[ frameIndex ] = attachmentName;
        }

        public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            if( firedEvents == null ) return; // when firedEvents == null it means this animation's timeline currently has been mixing to the next animation's timeline,
            // in this situation, skip applying the current attachment timeline to prevent the attachment of current timeline
            // to mess replacing the attachment of next animation's timeline

            if( isPassMiddleMixTime )//set lastTime = 0 can insure change attachment
                lastTime = 0;
            var frames : Vector.<Number> = this.frames;
            if( time < frames[ 0 ] )
            {
                if( lastTime > time ) apply( skeleton, lastTime, int.MAX_VALUE, null, 0 );
                return;
            } else if( lastTime > time )
                lastTime = -1;

            var frameIndex : int = time >= frames[ frames.length - 1 ] ? frames.length - 1 : Animation.binarySearch1( frames, time ) - 1;
            if( frames[ frameIndex ] < lastTime ) return;

            var attachmentName : String = attachmentNames[ frameIndex ];
            skeleton.slots[ slotIndex ].attachment = attachmentName == null ? null : skeleton.getAttachmentForSlotIndex( slotIndex, attachmentName );
        }
    }

}
