/**
 * Created by david on 2016/11/30.
 */
package QFLib.Framework
{

    import QFLib.Foundation.CMap;
    import QFLib.Graphics.RenderCore.render.ICompositor;
    import QFLib.Graphics.RenderCore.render.compositor.CompositorColorMultiply;
    import QFLib.Graphics.RenderCore.render.compositor.CompositorColorGrading;
    import QFLib.Graphics.RenderCore.render.compositor.CompositorColorReplace;
    import QFLib.Graphics.RenderCore.render.compositor.CompositorFactory;
    import QFLib.Graphics.RenderCore.render.compositor.CompositorFake;
    import QFLib.Graphics.RenderCore.render.compositor.CompositorGaussianBlur;
    import QFLib.Graphics.RenderCore.render.compositor.CompositorSmooth;

    public class CPostEffects
    {
        public static const Blur : String = CompositorGaussianBlur.Name;
        public static const Fake : String = CompositorFake.Name;
        public static const ColorReplace : String = CompositorColorReplace.Name;
        public static const ColorGrading : String = CompositorColorGrading.Name;
        public static const ColorMultiply : String = CompositorColorMultiply.Name;

        private static var sPostEffectInstance : CPostEffects = new CPostEffects ();

        private var m_mapRegistedCompositor : CMap = new CMap ();

        function CPostEffects ()
        { }

        public function dispose () : void
        {
            for each ( var compositors : Vector.<ICompositor> in m_mapRegistedCompositor )
            {
                compositors.length = 0;
                compositors = null;
            }
            m_mapRegistedCompositor.clear ();
            m_mapRegistedCompositor = null;
        }

        public static function getInstance () : CPostEffects
        {
            return sPostEffectInstance;
        }

        public function registerPostEffect ( name : String, ... args ) : void
        {
            var factory : CompositorFactory = CompositorFactory.getInstance ();
            if ( null == factory ) return;

            var compositors : Vector.<ICompositor> = m_mapRegistedCompositor.find ( name );
            if ( compositors != null ) return;

            compositors = new Vector.<ICompositor> ();

            switch ( name )
            {
                case Blur:
                    compositors.length = 3;
                    compositors[ 0 ] = factory.registerCompositor( CompositorSmooth.Name );
                    compositors[ 1 ] = factory.registerCompositor ( name, true, args[ 0 ], args[ 1 ] );
                    compositors[ 2 ] = factory.registerCompositor ( name, false, args[ 0 ], args[ 1 ] );
                    break;
                default:
                    compositors.length = 1;
                    compositors[ 0 ] = factory.registerCompositor ( name, args[ 0 ], args[ 1 ] );
                    break;
            }
            m_mapRegistedCompositor.add ( name, compositors, false );
        }

        public function play ( postEffectName : String, gradualChangeTime : Number = 0 ) : void
        {
            var compositors : Vector.<ICompositor> = m_mapRegistedCompositor.find ( postEffectName );
            if ( compositors == null ) return;
            var len : int = compositors.length;
            for ( var i : int = 0; i < len; i++ )
            {

                compositors[ i ].gradualChangeTime = gradualChangeTime;
                compositors[ i ].enable = true;
            }
        }

        public function stop ( postEffectName : String, gradualChangeTime : Number = 0 ) : void
        {
            var compositors : Vector.<ICompositor> = m_mapRegistedCompositor.find ( postEffectName );
            if ( compositors == null ) return;
            var len : int = compositors.length;
            for ( var i : int = 0; i < len; i++ )
            {
                compositors[ i ].gradualChangeTime = gradualChangeTime;
                compositors[ i ].enable = false;
            }
        }

        public function updatePostEffects ( deltaTime : Number ) : void
        {
            var len : int, i : int;
            for each ( var compositors : Vector.<ICompositor> in m_mapRegistedCompositor )
            {
                len = compositors.length;
                for ( i = 0; i < len; i++ )
                {
                    if ( compositors[ i ].enable )
                        compositors[ i ].update ( deltaTime );
                }
            }
        }

        public function playAllPostEffects () : void
        {
            var len : int, i : int;
            for each ( var compositors : Vector.<ICompositor> in m_mapRegistedCompositor )
            {
                len = compositors.length;
                for ( i = 0; i < len; i++ )
                {
                    compositors[ i ].enable = true;
                }
            }
        }

        public function stopAllPostEffects () : void
        {
            var len : int, i : int;
            for each ( var compositors : Vector.<ICompositor> in m_mapRegistedCompositor )
            {
                len = compositors.length;
                for ( i = 0; i < len; i++ )
                {
                    compositors[ i ].enable = false;
                }
            }
        }
    }
}
