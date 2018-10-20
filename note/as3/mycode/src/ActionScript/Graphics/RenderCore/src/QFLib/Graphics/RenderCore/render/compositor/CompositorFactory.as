/**
 * Created by david on 2016/11/30.
 */
package QFLib.Graphics.RenderCore.render.compositor
{

    import QFLib.Graphics.RenderCore.render.ICompositor;
    import QFLib.Graphics.RenderCore.starling.core.Starling;

    public class CompositorFactory
    {
        private static var instance : CompositorFactory = new CompositorFactory ();

        function CompositorFactory ()
        {
        }

        public static function getInstance () : CompositorFactory
        {
            return instance;
        }

        public function registerCompositor ( name : String, ...args ) : ICompositor
        {
            var compositor : ICompositor = null;
            switch ( name )
            {
                case CompositorGaussianBlur.Name:
                    compositor = new CompositorGaussianBlur ( args[ 0 ] );
                    break;
                case CompositorColorGrading.Name:
                    compositor = new CompositorColorGrading ();
                    break;
                case CompositorColorReplace.Name:
                    compositor = new CompositorColorReplace ( args[ 0 ], args[ 1 ] );
                    break;
                case CompositorFake.Name:
                    compositor = new CompositorFake ();
                    break;
                case CompositorColorMultiply.Name:
                    compositor = new CompositorColorMultiply ( args[ 0 ] );
                    break;
                case CompositorSmooth.Name:
                    compositor = new CompositorSmooth();
                default:
                    break;
            }

            if ( null != compositor ) Starling.current.registerCompositor ( compositor );

            return compositor;
        }
    }
}
