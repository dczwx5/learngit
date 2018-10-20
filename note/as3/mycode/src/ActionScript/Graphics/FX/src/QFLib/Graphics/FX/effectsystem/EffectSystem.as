package QFLib.Graphics.FX.effectsystem
{
    public class EffectSystem
    {
        //effect
        public static const EMITTER : uint = 0;
        public static const PARTICLE : uint = 1;
        public static const TRAIL : uint = 2;
        public static const HALO : uint = 3;
        public static const FRAME : uint = 4;
        public static const CONTAINER : uint = 5;
        public static const SPRITEANIMATION : uint = 6;

        //modifier, like color modifier
        public static const COLORMODIFIER : int = 8;
        public static const ADVCOLORMODIFIER : int = 9;
        public static const TRITONECOLORTRASFORM : int = 11;

        //GHOSTING
        public static const GHOSTING : int = 10;

        //DISTORTION
        public static const DISTORTION : int = 12;

        //UVAnimation
        public static const UV_ANIMATION : int = 13;

        //Outline
        public static const OUTLINE : int = 14;

        public static const BOX : uint = 0;
        public static const CIRCLE : uint = 1;
        public static const RING : uint = 2;
        public static const EMITTER_TYPE_COUNT : uint = 3;

        public static const LOADEFFECT : uint = 0;
        public static const LOADMATERIAL : uint = 1;

        public static function createEffect ( type : int ) : IEffect
        {
            switch ( type )
            {
                case EMITTER: return new EffectEmitter ();
                case PARTICLE: return new ParticleInstance ();
                case TRAIL: return new TrailInstance ();
                case HALO: return new HaloInstance ();
                case FRAME: return new FrameAnimationInstance ();
                case CONTAINER: return new EffectContainer ();
                case SPRITEANIMATION: return new SpriteAnimationInstance ();
                case COLORMODIFIER: return new ColorModifier ();
                case ADVCOLORMODIFIER: return new AdvColorModifier ();
                case GHOSTING: return new GhostingInstance ();
                case TRITONECOLORTRASFORM: return new TritoneColorTransform();
                case DISTORTION: return new Distortion ();
                case UV_ANIMATION: return new UVAnimationInstance ();
                case OUTLINE: return new OutlineModifier ();
                default:
                    throw new ErrorInvalidTypeID ( type, "effect" );
                    return null;
            }
        }
    }
}

class ErrorInvalidTypeID extends ArgumentError
{
    public function ErrorInvalidTypeID ( id : int, type : String )
    {
        super ( "no such " + type + " type : " + id.toString () );
    }
}