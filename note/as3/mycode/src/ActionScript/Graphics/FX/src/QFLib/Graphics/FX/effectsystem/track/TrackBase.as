//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2017/6/20.
 */
package QFLib.Graphics.FX.effectsystem.track {

    import QFLib.Math.CVector2;

    public  class TrackBase {

    public var trackType : int;
    public var easeType : int = TrackEaseType.LINEAR;

    public function TrackBase() {
    }

    public virtual function lerpPostion( startVector2 : CVector2, endVector2 : CVector2, time : Number ) : CVector2
    {
        time = TrackEaseType.caculateEaseTimeByType(time, this.easeType);

        var pos : CVector2 = CVector2.lerp( startVector2, endVector2, time );
        return pos;
    }
}
}
