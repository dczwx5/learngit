//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2017/6/20.
 */
package QFLib.Graphics.FX.effectsystem.track {

    import QFLib.Math.CMath;
    import QFLib.Math.CVector2;

    public class CircleTrack extends  TrackBase{

    public var radius : Number  = 0.0;//半径
    public var startAngle : int  = 0;//起始角度
    public var endAngle : int  = 0;//结束角度
    public var clockwise : Boolean  = true;//是否顺时针

    public function CircleTrack() {
        trackType = TrackType.CIRCLE;
    }

    public static function createTrack(mRadius : Number, mStartAngle : int , mEndAngle : int, mClockwise : Boolean = true, mEaseType: int = TrackEaseType.LINEAR ) : CircleTrack
    {
        var track : CircleTrack = new CircleTrack();
        track.radius = mRadius;
        track.startAngle = mStartAngle;
        track.endAngle = mEndAngle;
        track.clockwise = mClockwise;

        track.easeType = mEaseType;
        return track;
    }

    override public function lerpPostion( startVector2 : CVector2, endVector2 : CVector2, time : Number ) : CVector2
    {
        var pos : CVector2 = super.lerpPostion( startVector2, endVector2, time );

        var circle : CircleTrack  = this as CircleTrack;
        var angle : Number  = (circle.endAngle - circle.startAngle) * time + circle.startAngle;
        if (!circle.clockwise) angle = -angle;
        pos.x += circle.radius * Math.cos( CMath.degToRad(angle) );
        pos.y += circle.radius * Math.sin( CMath.degToRad(angle) );

        return pos;
    }
}
}
