/**
 * Created by Cliff on 2017/6/22.
 */
package QFLib.Graphics.FX.effectsystem.track {

    import QFLib.Math.CMath;
    import QFLib.Math.CVector2;

    public class EllipseTrack extends TrackBase{

    public var a : Number = 0.0;//长轴长
    public var b : Number = 0.0;//短轴长
    public var angle : int  = 0;//逆时针旋转角度
    public var clockwise : Boolean  = true;//是否顺时针

    public function EllipseTrack() {
        trackType = TrackType.ELLIPSE;
    }

    public static function createTrack( mA : Number, mB : Number, mAngle : int = 0, mClockwise : Boolean = true, mEaseType: int = TrackEaseType.LINEAR ) : EllipseTrack
    {
        var track : EllipseTrack = new EllipseTrack();
        track.a = mA;
        track.b = mB;
        track.angle = mAngle;
        track.clockwise = mClockwise;

        track.easeType = mEaseType;
        return track;
    }

    override public function lerpPostion( startVector2 : CVector2, endVector2 : CVector2, time : Number ) : CVector2
    {
        var pos : CVector2 = super.lerpPostion( startVector2, endVector2, time );

        var ellipse : EllipseTrack  = this as EllipseTrack;
        var tempAngle : Number = ellipse.clockwise? 360:-360;
        tempAngle *= time;
        var tempPos:CVector2 = new CVector2();
        tempPos.x = ellipse.a * Math.cos( CMath.degToRad(tempAngle) );
        tempPos.y = ellipse.b * Math.sin( CMath.degToRad(tempAngle) );
        tempAngle = ellipse.clockwise? CMath.degToRad(ellipse.angle) : -CMath.degToRad(ellipse.angle);
        pos.x += tempPos.x * Math.cos(tempAngle) - tempPos.y * Math.sin(tempAngle);
        pos.y += tempPos.x * Math.sin(tempAngle) + tempPos.y * Math.cos(tempAngle);

        return pos;
    }
}
}
