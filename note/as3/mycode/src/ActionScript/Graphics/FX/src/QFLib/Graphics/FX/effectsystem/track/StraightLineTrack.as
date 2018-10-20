//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2017/6/20.
 */
package QFLib.Graphics.FX.effectsystem.track {

public class StraightLineTrack extends  TrackBase{
    public function StraightLineTrack() {
        trackType = TrackType.STRAIGHT_LINE;
    }

    public static function createTrack( mEaseType: int = TrackEaseType.LINEAR ) : StraightLineTrack
    {
        var track : StraightLineTrack = new StraightLineTrack();
        track.easeType = mEaseType;
        return track;
    }
}
}
