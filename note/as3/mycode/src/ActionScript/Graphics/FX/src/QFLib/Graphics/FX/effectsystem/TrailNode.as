package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Math.CVector2;

    public final class TrailNode
    {
        public var life : Number = 1.0;
        public var color : uint = 0xFFFFFF;
        public var width : Number = 1.0;
        public var position : CVector2 = CVector2.zero();
    }
}