/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;
    import QFLib.QEngine.ThirdParty.Spine.Slot;
    import QFLib.QEngine.ThirdParty.Spine.attachments.Attachment;
    import QFLib.QEngine.ThirdParty.Spine.attachments.FfdAttachment;

    public class FfdTimeline extends CurveTimeline
    {
        public function FfdTimeline( frameCount : int )
        {
            super( frameCount );
            frames = new Vector.<Number>( frameCount, true );
            frameVertices = new Vector.<Vector.<Number>>( frameCount, true );
        }
        public var slotIndex : int;
        public var frames : Vector.<Number>;
        public var frameVertices : Vector.<Vector.<Number>>;
        public var attachment : Attachment;

        override public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            var slot : Slot = skeleton.slots[ slotIndex ];
            var slotAttachment : FfdAttachment = slot.attachment as FfdAttachment;
            if( !slotAttachment || !slotAttachment.applyFFD( attachment ) ) return;

            var frames : Vector.<Number> = this.frames;
            if( time < frames[ 0 ] ) return; // Time is before first frame.

            var frameVertices : Vector.<Vector.<Number>> = this.frameVertices;
            var vertexCount : int = frameVertices[ 0 ].length;

            var vertices : Vector.<Number> = slot.attachmentVertices;
            if( vertices.length != vertexCount ) alpha = 1; // Don't mix from uninitialized slot vertices.
            vertices.length = vertexCount;

            var i : int;
            if( time >= frames[ frames.length - 1 ] )
            { // Time is after last frame.
                var lastVertices : Vector.<Number> = frameVertices[ int( frames.length - 1 ) ];
                if( alpha < 1 )
                {
                    for( i = 0; i < vertexCount; i++ )
                        vertices[ i ] += (lastVertices[ i ] - vertices[ i ]) * alpha;
                } else
                {
                    for( i = 0; i < vertexCount; i++ )
                        vertices[ i ] = lastVertices[ i ];
                }
                return;
            }

            // Interpolate between the previous frame and the current frame.
            var frameIndex : int = Animation.binarySearch1( frames, time );
            var frameTime : Number = frames[ frameIndex ];
            var percent : Number = 1 - (time - frameTime) / (frames[ int( frameIndex - 1 ) ] - frameTime);
            percent = getCurvePercent( frameIndex - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent) );

            var prevVertices : Vector.<Number> = frameVertices[ int( frameIndex - 1 ) ];
            var nextVertices : Vector.<Number> = frameVertices[ frameIndex ];

            var prev : Number;
            if( alpha < 1 )
            {
                for( i = 0; i < vertexCount; i++ )
                {
                    prev = prevVertices[ i ];
                    vertices[ i ] += (prev + (nextVertices[ i ] - prev) * percent - vertices[ i ]) * alpha;
                }
            } else
            {
                for( i = 0; i < vertexCount; i++ )
                {
                    prev = prevVertices[ i ];
                    vertices[ i ] = prev + (nextVertices[ i ] - prev) * percent;
                }
            }
        }

        /** Sets the time and value of the specified keyframe. */
        [Inline]
        final public function setFrame( frameIndex : int, time : Number, vertices : Vector.<Number> ) : void
        {
            frames[ frameIndex ] = time;
            frameVertices[ frameIndex ] = vertices;
        }
    }

}
