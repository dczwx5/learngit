/**
 * Created by Administrator on 2017/6/23.
 */
package QFLib.Graphics.FX.effectsystem.keyFrame {
    import QFLib.Math.CVector2;

    public class TrackKey {

    public var endTime : Number;
    public var startPosition : CVector2;
    public var endPosition : CVector2;

    public function TrackKey( mStartPosition : CVector2, mEndPosition : CVector2, mEndTime : Number ) {
        startPosition = mStartPosition;
        endPosition = mEndPosition;
        endTime = mEndTime;
    }
}
}
