package QFLib.Graphics.RenderCore
{
    import QFLib.Foundation;
    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.RenderCore.render.Renderer;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObjectContainer;
    import QFLib.Graphics.RenderCore.starling.display.Sprite;
    import QFLib.Graphics.RenderCore.starling.events.Event;
    import QFLib.Graphics.RenderCore.starling.utils.Version;
    import QFLib.Memory.CSmartObject;
    import QFLib.ResourceLoader.CResourceLoaders;

    import flash.display.Stage;
    import flash.display3D.Context3DRenderMode;
    import flash.geom.Rectangle;

    public class CRenderer extends CSmartObject
    {
        public function CRenderer ( stage : Stage )
        {
            super ();
            m_Stage = stage;
        }

        public override function dispose () : void
        {
            m_Starling.dispose ();
            m_Starling = null;

            if ( m_Renderer )
                m_Renderer.dispose ();
            m_Renderer = null;

            m_Stage = null;
        }

        public function initialize ( onInitialized : Function, viewPortRect : Rectangle = null, backGroundColor : uint = 0x0 , onInitializing : Function = null) : Boolean
        {
            // 设置处理纹理的设备丢失
            if ( !Starling.handleLostContext )
                Starling.handleLostContext = true;
            if ( viewPortRect == null )
            {
                var width : int = m_Stage.stageWidth != 0 ? m_Stage.stageWidth : m_Stage.width;
                var height : int = m_Stage.stageHeight != 0 ? m_Stage.stageHeight : m_Stage.height;
                viewPortRect = new Rectangle ( 0, 0, width, height );
            }

            if ( !m_Starling )
            {
                m_Starling = new Starling ( Sprite, m_Stage, viewPortRect, null, Context3DRenderMode.AUTO, "auto" );
                m_Starling.stage.color = backGroundColor;

                //如果是调试版则开启错误检测
                m_Starling.enableErrorChecking = Version.isDebugBuild ();

                m_Starling.addEventListener ( Event.ROOT_CREATED, _rootCreated );
                function _rootCreated ( e : Event ) : void
                {
                    Foundation.Log.logMsg ( e.toString () );
                    if ( null != onInitialized )
                        onInitialized ();
                    m_Starling.removeEventListener ( Event.ROOT_CREATED, _rootCreated );
                }

                // register a loader for texture loading
                CResourceLoaders.instance ().registerLoader ( CTextureLoader );
                CResourceLoaders.instance ().registerLoader ( CTextureAtlasLoader );

                if (onInitializing != null)//用于BI日志打点，排查卡在哪里
                {
                    onInitializing();
                }

                m_Starling.start ();
            }

            return true;
        }

        public function render () : void
        {
            if ( m_Starling )
            {
                m_Starling.rendering ();
            }
        }

        // camera related
        [Inline]
        public function addCamera ( camera : ICamera ) : void
        {
            m_Starling.renderer.addCamera ( camera );
        }

        [Inline]
        public function get currentCamera () : ICamera
        {
            return m_Starling.renderer.getCurrentCamera ();
        }

        [Inline]
        public function removeCamera ( camera : ICamera ) : void
        {
            m_Starling.renderer.removeCamera ( camera );
        }

        [Inline]
        public function set backGroundColor ( color : uint ) : void
        {
            m_Starling.stage.color = color;
        }

        [Inline]
        public function get nativeStageWidth () : int
        {
            return m_Starling.nativeStage.stageWidth;
        }

        [Inline]
        public function get nativeStageHeight () : int
        {
            return m_Starling.nativeStage.stageHeight;
        }

        [Inline]
        public function get nativeStageScreenRatio () : Number
        {
            return Number ( m_Starling.nativeStage.stageWidth ) / Number ( m_Starling.nativeStage.stageHeight );
        }

        [Inline]
        public function get stageWidth () : int
        {
            return m_Starling.stage.stageWidth;
        }

        [Inline]
        public function get stageHeight () : int
        {
            return m_Starling.stage.stageHeight;
        }

        [Inline]
        public function get stageScreenRatio () : Number
        {
            return Number ( m_Starling.stage.stageWidth ) / Number ( m_Starling.stage.stageHeight );
        }

        public function _rootDisplayObjectContainer () : DisplayObjectContainer
        {
            return DisplayObjectContainer ( Starling.current.root );
        }

        //
        private var m_Starling : Starling;
        private var m_Stage : Stage;
        private var m_Renderer : Renderer;
    }
}
