//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2017/6/20.
 */
package QFLib.Graphics.FX.effectsystem.keyFrame
{

    import QFLib.Graphics.FX.effectsystem.track.CircleTrack;
    import QFLib.Graphics.FX.effectsystem.track.EllipseTrack;
    import QFLib.Graphics.FX.effectsystem.track.StraightLineTrack;
    import QFLib.Graphics.FX.effectsystem.track.TrackBase;
    import QFLib.Graphics.FX.effectsystem.track.TrackType;
    import QFLib.Math.CVector2;

    public class TrackFrame
    {
        private static const _sHelperPosition : CVector2 = CVector2.zero();

        private  var _trackKeys : Vector.<TrackKey>;
        private var _trackNodes : Vector.<TrackBase>;

        public function TrackFrame()
        {
            _trackKeys = new Vector.<TrackKey>();
            _trackNodes = new Vector.<TrackBase>();
        }

        public function clear() : void
        {
            _trackKeys.fixed = false;
            _trackKeys.length = 0;
            _trackKeys.fixed = true;

            _trackNodes.fixed = false;
            _trackNodes.length = 0;
            _trackNodes.fixed = true;
        }

        public function getPosition ( time : Number ) : CVector2
        {
            var len : int = _trackKeys.length;
            if ( len == 0 )
                return _sHelperPosition;

            for ( var i : int = 0, n : int = len; i < n; ++i )
            {
                if ( _trackKeys[ i ].endTime > time )
                    break;
            }

            if( i == 0 )
            {
                time = time / _trackKeys[ i ].endTime;
                return _trackNodes[i].lerpPostion( _trackKeys[ i ].startPosition, _trackKeys[ i ].endPosition, time );
            }
            else if (i == len)
            {
                return _trackNodes[ i - 1 ].lerpPostion(_trackKeys[ i - 1 ].startPosition, _trackKeys[ i - 1 ].endPosition, 1.0 );
            }
           var f:Number = ( time - _trackKeys[ i - 1 ].endTime ) / ( _trackKeys[ i ].endTime - _trackKeys[ i - 1 ].endTime );
            return _trackNodes[ i ].lerpPostion(_trackKeys[ i ].startPosition, _trackKeys[ i ].endPosition, f );
        }

        public function loadFromObject ( data : Object ) : void
        {
            var i : int = 0;
            var n : int = 0;

            if ( data.hasOwnProperty ( "trackKeys" ) )
            {
                var trackKeyArray : Array = data.trackKeys as Array;

                _trackKeys.fixed = false;
                _trackKeys.length = 0;
                var key : TrackKey;
                var keyData : Object;
                var startVector : CVector2;
                var endVector : CVector2;
                for ( i = 0, n = trackKeyArray.length; i < n; ++i)
                {
                    keyData = trackKeyArray[ i ];
                    startVector = new CVector2(keyData.startPosition.x, keyData.startPosition.y);
                    endVector = new CVector2(keyData.endPosition.x, keyData.endPosition.y);
                    key = new TrackKey(startVector, endVector, keyData.endTime);

                    _trackKeys [ _trackKeys.length ] = key;
                }
                _trackKeys.fixed = true;
            }

            if ( data.hasOwnProperty ( "trackNodes" ) )
            {
                var trackNodeArray : Array = data.trackNodes as Array;

                _trackNodes.fixed = false;
                _trackNodes.length = 0;
                var track : TrackBase;
                var trackData : Object;
                for ( i = 0, n = trackNodeArray.length; i < n; ++i)
                {
                    trackData = trackNodeArray[ i ];
                    track = createTrack( trackData );

                    _trackNodes [ _trackNodes.length ] = track;
                }
                _trackNodes.fixed = true;
            }
        }

        private function createTrack( trackData : Object ) : TrackBase
        {
            var track : TrackBase;
            var trackType : int = trackData.trackType;
            switch (trackType)
            {
                case TrackType.CIRCLE:
                    track = CircleTrack.createTrack( trackData.radius, trackData.startAngle, trackData.endAngle, trackData.clockwise, trackData.easeType );
                    break;
                case TrackType.ELLIPSE:
                    track = EllipseTrack.createTrack( trackData.a, trackData.b, trackData.angle, trackData.clockwise, trackData.easeType );
                    break;
                case TrackType.STRAIGHT_LINE:
                default:
                    track = StraightLineTrack.createTrack( trackData.easeType );
                    break;
            }
            return track;
        }

        public function dispose () : void
        {
            _trackKeys.fixed = false;
            _trackKeys.length = 0;
            _trackKeys = null;

            _trackNodes.fixed = false;
            _trackNodes.length = 0;
            _trackNodes = null;
        }
        
    }
}
