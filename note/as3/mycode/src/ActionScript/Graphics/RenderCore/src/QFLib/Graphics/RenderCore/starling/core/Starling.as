// =================================================================================================
//
//	Starling Framework
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package QFLib.Graphics.RenderCore.starling.core
{

	import QFLib.Utils.Quality;
	import QFLib.Graphics.RenderCore.render.Camera;
    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.RenderCore.render.ICompositor;
    import QFLib.Graphics.RenderCore.render.IRenderer;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.render.Renderer;
    import QFLib.Graphics.RenderCore.render.shader.ShaderLib;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.display.SceneManager;
    import QFLib.Graphics.RenderCore.starling.display.Stage;
    import QFLib.Graphics.RenderCore.starling.events.Event;
    import QFLib.Graphics.RenderCore.starling.events.EventDispatcher;
    import QFLib.Graphics.RenderCore.starling.events.ResizeEvent;
    import QFLib.Graphics.RenderCore.starling.events.TouchProcessor;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.GetNextPowerOfTwo;
    import QFLib.Graphics.RenderCore.starling.utils.HAlign;
    import QFLib.Graphics.RenderCore.starling.utils.RenderTexturePool;
    import QFLib.Graphics.RenderCore.starling.utils.SystemUtil;
    import QFLib.Graphics.RenderCore.starling.utils.VAlign;
    import QFLib.Utils.CFlashVersion;

    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProfile;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.TextureBase;
    import flash.errors.IllegalOperationError;
    import flash.events.ErrorEvent;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.system.Capabilities;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    import flash.utils.setTimeout;

    /** Dispatched when a new render context is created. */
    [Event(name="context3DCreate", type="QFLib.Graphics.RenderCore.starling.events.Event")]

    /** Dispatched when the root class has been created. */
    [Event(name="rootCreated", type="QFLib.Graphics.RenderCore.starling.events.Event")]

    /** The Starling class represents the core of the Starling framework.
     *
     *  <p>The Starling framework makes it possible to create 2D applications and games that make
     *  use of the Stage3D architecture introduced in Flash Player 11. It implements a display tree
     *  system that is very similar to that of conventional Flash, while leveraging modern GPUs
     *  to speed up rendering.</p>
     *
     *  <p>The Starling class represents the link between the conventional Flash display tree and
     *  the Starling display tree. To create a Starling-powered application, you have to create
     *  an instance of the Starling class:</p>
     *
     *  <pre>var starling:Starling = new Starling(Game, stage);</pre>
     *
     *  <p>The first parameter has to be a Starling display object class, e.g. a subclass of
     *  <code>starling.display.Sprite</code>. In the sample above, the class "Game" is the
     *  application root. An instance of "Game" will be created as soon as Starling is initialized.
     *  The second parameter is the conventional (Flash) stage object. Per default, Starling will
     *  display its contents directly below the stage.</p>
     *
     *  <p>It is recommended to store the Starling instance as a member variable, to make sure
     *  that the Garbage Collector does not destroy it. After creating the Starling object, you
     *  have to start it up like this:</p>
     *
     *  <pre>starling.start();</pre>
     *
     *  <p>It will now render the contents of the "Game" class in the frame rate that is set up for
     *  the application (as defined in the Flash stage).</p>
     *
     *  <strong>Context3D Profiles</strong>
     *
     *  <p>Stage3D supports different rendering profiles, and Starling works with all of them. The
     *  last parameter of the Starling constructor allows you to choose which profile you want.
     *  The following profiles are available:</p>
     *
     *  <ul>
     *    <li>BASELINE_CONSTRAINED: provides the broadest hardware reach. If you develop for the
     *        browser, this is the profile you should test with.</li>
     *    <li>BASELINE: recommend for any mobile application, as it allows Starling to use a more
     *        memory efficient texture type (RectangleTextures). It also supports more complex
     *        AGAL code.</li>
     *    <li>BASELINE_EXTENDED: adds support for textures up to 4096x4096 pixels. This is
     *        especially useful on mobile devices with very high resolutions.</li>
     *  </ul>
     *
     *  <p>The recommendation is to deploy your app with the profile "auto" (which makes Starling
     *  pick the best available of those three), but test it in all available profiles.</p>
     *
     *  <strong>Accessing the Starling object</strong>
     *
     *  <p>From within your application, you can access the current Starling object anytime
     *  through the static method <code>Starling.current</code>. It will return the active Starling
     *  instance (most applications will only have one Starling object, anyway).</p>
     *
     *  <strong>Viewport</strong>
     *
     *  <p>The area the Starling content is rendered into is, per default, the complete size of the
     *  stage. You can, however, use the "viewPort" property to change it. This can be  useful
     *  when you want to render only into a part of the screen, or if the player size changes. For
     *  the latter, you can listen to the RESIZE-event dispatched by the Starling
     *  stage.</p>
     *
     *  <strong>Native overlay</strong>
     *
     *  <p>Sometimes you will want to display native Flash content on top of Starling. That's what the
     *  <code>nativeOverlay</code> property is for. It returns a Flash Sprite lying directly
     *  on top of the Starling content. You can add conventional Flash objects to that overlay.</p>
     *
     *  <p>Beware, though, that conventional Flash content on top of 3D content can lead to
     *  performance penalties on some (mobile) platforms. For that reason, always remove all child
     *  objects from the overlay when you don't need them any longer. Starling will remove the
     *  overlay from the display list when it's empty.</p>
     *
     *  <strong>Multitouch</strong>
     *
     *  <p>Starling supports multitouch input on devices that provide it. During development,
     *  where most of us are working with a conventional mouse and keyboard, Starling can simulate
     *  multitouch events with the help of the "Shift" and "Ctrl" (Mac: "Cmd") keys. Activate
     *  this feature by enabling the <code>simulateMultitouch</code> property.</p>
     *
     *  <strong>Handling a lost render context</strong>
     *
     *  <p>On some operating systems and under certain conditions (e.g. returning from system
     *  sleep), Starling's stage3D render context may be lost. Starling can recover from a lost
     *  context if the class property "handleLostContext" is set to "true". Keep in mind, however,
     *  that this comes at the price of increased memory consumption; Starling will cache textures
     *  in RAM to be able to restore them when the context is lost. (Except if you use the
     *  'AssetManager' for your textures. It is smart enough to recreate a texture directly
     *  from its origin.)</p>
     *
     *  <p>In case you want to react to a context loss, Starling dispatches an event with
     *  the type "Event.CONTEXT3D_CREATE" when the context is restored. You can recreate any
     *  invalid resources in a corresponding event listener.</p>
     *
     *  <strong>Sharing a 3D Context</strong>
     *
     *  <p>Per default, Starling handles the Stage3D context itself. If you want to combine
     *  Starling with another Stage3D engine, however, this may not be what you want. In this case,
     *  you can make use of the <code>shareContext</code> property:</p>
     *
     *  <ol>
     *    <li>Manually create and configure a context3D object that both frameworks can work with
     *        (through <code>stage3D.requestContext3D</code> and
     *        <code>context.configureBackBuffer</code>).</li>
     *    <li>Initialize Starling with the stage3D instance that contains that configured context.
     *        This will automatically enable <code>shareContext</code>.</li>
     *    <li>Call <code>start()</code> on your Starling instance (as usual). This will make
     *        Starling queue input events (keyboard/mouse/touch).</li>
     *    <li>Create a game loop (e.g. using the native <code>ENTER_FRAME</code> event) and let it
     *        call Starling's <code>nextFrame</code> as well as the equivalent method of the other
     *        Stage3D engine. Surround those calls with <code>context.clear()</code> and
     *        <code>context.present()</code>.</li>
     *  </ol>
     *
     *  <p>The Starling wiki contains a <a href="http://goo.gl/BsXzw">tutorial</a> with more
     *  information about this topic.</p>
     *
     */
    public class Starling extends EventDispatcher
    {
        /** The key for the shader programs stored in 'contextData' */
        private static var sViewPortHelper : Rectangle = new Rectangle ();
        private static var sCurrent : Starling;
        private static var sHandleLostContext : Boolean;
        private static var sContextData : Dictionary = new Dictionary ( true );

        // members
        private var mStage3D : Stage3D;
        private var mStage : Stage; // starling.display.stage!
        private var mRootClass : Class;
        private var mRoot : DisplayObject;
        private var mSupport : RenderSupport;
        private var mTouchProcessor : TouchProcessor;
        private var mAntiAliasing : int;
        private var mSimulateMultitouch : Boolean;
        private var mEnableErrorChecking : Boolean;
        private var mLastFrameTimestamp : Number;
        private var mStatsDisplay : StatsDisplay;
        private var mShareContext : Boolean;
        private var mEventDict : Dictionary;

        private var mProfiles : Vector.<String>;
        private var mProfile : String;
        private var mRenderMode : String;
        private var mDriverInfo : String;
        private var mIsOpenGL : Boolean;

        private var mContext : Context3D;
        private var mStarted : Boolean;
        private var mRendering : Boolean;
        private var mSupportHighResolutions : Boolean;

        private var mViewPort : Rectangle;
        private var mPreviousViewPort : Rectangle;
        private var mClippedViewPort : Rectangle;

        private var mNativeStage : flash.display.Stage;
        private var mNativeOverlay : Sprite;
        private var mNativeStageContentScaleFactor : Number;

        /// 渲染队列
        private var mRenderer : IRenderer = null;
        private var mDefaultCamera : Camera = null;
        private var mFilterCamera : Camera = null;
        private var mCompositorCamera : Camera = null;
        private var mUICamera : Camera = null;

        private var mSceneManager : SceneManager = null;
        private var mCompositorInTexture : Texture = null;
        private var mCompositorOutTexture : Texture = null;
        private var mCompositors : Vector.<ICompositor> = new Vector.<ICompositor> ();

        //flash player version
        private var mFlashPriorOrEqualTo12 : Boolean = false;
        private var mFlashPriorOrEqualTo14 : Boolean = false;

        //software mode
        private var mIsSoftwareMode : Boolean = false;

        private var mFrameHandlers : Vector.<Function> = new Vector.<Function> ();

        private var mOriginalWidth : int = 0;
        // construction

        //vertex buffer
        private var mVertexBufferCount : int = 0;

        //index buffer
        private var mIndexBufferCount : int = 0;

        //drawCall Count
        private var mDrawCallCount : int = 0;

        public var snapshotCallback : Function;

        /** Creates a new Starling instance.
         *  @param rootClass  A subclass of a Starling display object. It will be created as soon as
         *                    initialization is finished and will become the first child of the
         *                    Starling stage.
         *  @param stage      The Flash (2D) stage.
         *  @param viewPort   A rectangle describing the area into which the content will be
         *                    rendered. Default: stage size
         *  @param stage3D    The Stage3D object into which the content will be rendered. If it
         *                    already contains a context, <code>sharedContext</code> will be set
         *                    to <code>true</code>. Default: the first available Stage3D.
         *  @param renderMode Use this parameter to force "software" rendering.
         *  @param profile    The Context3D profile that should be requested.
         *
         *                    <ul>
         *                    <li>If you pass a profile String, this profile is enforced.</li>
         *                    <li>Pass an Array/Vector of profiles to make Starling pick the best
         *                        available profile from this list.</li>
         *                    <li>Pass the String "auto" to make Starling pick the best available
         *                        profile automatically.</li>
         *                    </ul>
         *
         *                    <p>Beware that automatic profile selection is only available starting
         *                    with AIR 4. If you use "auto" or an Array/Vector, and the AIR version
         *                    is smaller than that, the lowest profile will be used.</p>
         */
        public function Starling ( rootClass : Class, stage : flash.display.Stage,
                                   viewPort : Rectangle = null, stage3D : Stage3D = null,
                                   renderMode : String = "auto", profile : Object = "baselineConstrained" )
        {
            if ( stage == null ) throw new ArgumentError ( "Stage must not be null" );
            if ( rootClass == null ) throw new ArgumentError ( "Root class must not be null" );
            if ( viewPort == null ) viewPort = new Rectangle ( 0, 0, stage.stageWidth, stage.stageHeight );
            if ( stage3D == null ) stage3D = stage.stage3Ds[ 0 ];

            mFlashPriorOrEqualTo12 = CFlashVersion.isPlayerVersionPriorOrEqualTo ( 12, 0 );
            mFlashPriorOrEqualTo14 = CFlashVersion.isPlayerVersionPriorOrEqualTo ( 14, 0 );


            SystemUtil.initialize ();
            makeCurrent ();

            mRootClass = rootClass;
            mViewPort = viewPort;
            mOriginalWidth = viewPort.width;

            mPreviousViewPort = new Rectangle ();
            mStage3D = stage3D;
            mStage = new Stage ( viewPort.width, viewPort.height, stage.color );
            mNativeOverlay = new Sprite ();
            mNativeStage = stage;
            mNativeStage.addChild ( mNativeOverlay );
            mNativeStageContentScaleFactor = 1.0;
            mTouchProcessor = new TouchProcessor ( mStage );
            mAntiAliasing = 0;
            mSimulateMultitouch = false;
            mEnableErrorChecking = false;
            mSupportHighResolutions = false;
            mLastFrameTimestamp = getTimer () / 1000.0;
            mEventDict = new Dictionary();

            mSupport = new RenderSupport ();
            mSupport.setOrthographicProjection ( 0, 0, viewPort.width, viewPort.height );

            mSceneManager = new SceneManager ();

            mRenderer = new Renderer ();

            mDefaultCamera = new Camera ();
            mDefaultCamera.cullingMask = 0;
            mDefaultCamera.enabled = false;
            mRenderer.addCamera ( mDefaultCamera );

            mFilterCamera = new Camera ();
            mFilterCamera.cullingMask = 0;
            mFilterCamera.enabled = false;
            mRenderer.addCamera ( mFilterCamera );

            mCompositorCamera = new Camera ();
            mCompositorCamera.clearMask = 0;
            mCompositorCamera.enabled = false;
            mCompositorCamera.setOrthoSize ( 100, 100 );
            mCompositorCamera.setPosition ( 0.0, 0.0 );
            mRenderer.addCamera ( mCompositorCamera );

            mUICamera = new Camera ();
            mUICamera.clearMask = 0;
            mUICamera.enabled = false;
            mRenderer.addCamera ( mUICamera );

            ShaderLib.init ();

            // for context data, we actually reference by stage3D, since it survives a context loss
            sContextData[ stage3D ] = new Dictionary ();

            // all other modes are problematic in Starling, so we force those here
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            // register other event handlers
            stage.addEventListener ( flash.events.Event.RESIZE, onResize, false, 0, true );
            mStage3D.addEventListener ( flash.events.Event.CONTEXT3D_CREATE, onContextCreated, false, 10, true );
            mStage3D.addEventListener ( ErrorEvent.ERROR, onStage3DError, false, 10, true );

            if ( mStage3D.context3D && mStage3D.context3D.driverInfo != "Disposed" )
            {
                if ( profile == "auto" || profile is Array || profile is Vector.<String> )
                    throw new ArgumentError ( "When sharing the context3D, the actual profile has " +
                            "to be passed as last argument to the Starling constructor" );
                else
                    mProfile = profile as String;

                mShareContext = true;
                setTimeout ( initialize, 1 ); // we don't call it right away, because Starling should
                                              // behave the same way with or without a shared context
            }
            else
            {
                mShareContext = false;
                requestContext3D ( stage3D, renderMode, profile );
            }
        }

        public function get fps () : Number
        {
            return mStatsDisplay.fps;
        }

        public function get drawCall () : int
        {
            return mDrawCallCount;
        }

        public function get indexBufferCount () : int
        {
            return mIndexBufferCount;
        }

        public function get vertexBufferCount () : int
        {
            return mVertexBufferCount;
        }

        /** Disposes all children of the stage and the render context; removes all registered
         *  event listeners. */
        public function dispose () : void
        {
            stop ( true );

            if ( !mIsSoftwareMode )
                disposeCompositor ();

            //mNativeStage.removeEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame, false);
            mNativeStage.removeEventListener ( flash.events.Event.RESIZE, onResize, false );
            mNativeStage.removeChild ( mNativeOverlay );

            mStage3D.removeEventListener ( flash.events.Event.CONTEXT3D_CREATE, onContextCreated, false );
            mStage3D.removeEventListener ( ErrorEvent.ERROR, onStage3DError, false );

            if ( mStage ) mStage.dispose ();
            if ( mSupport ) mSupport.dispose ();
            if ( mTouchProcessor ) mTouchProcessor.dispose ();
            if ( mContext && !mShareContext )
            {
                // Per default, the context is recreated as long as there are listeners on it.
                // Beginning with AIR 3.6, we can avoid that with an additional parameter.

                var disposeContext3D : Function = mContext.dispose;
                if ( disposeContext3D.length == 1 ) disposeContext3D ( false );
                else disposeContext3D ();
            }

            mRenderer.removeCamera ( mDefaultCamera );
            mDefaultCamera = null;

            mRenderer.removeCamera ( mFilterCamera );
            mFilterCamera = null;

            mRenderer.removeCamera ( mCompositorCamera );
            mCompositorCamera = null;

            mRenderer.removeCamera ( mUICamera );
            mUICamera = null;

            if ( mEventDict != null )
            {
                var eventFuncKeyArr : Array = [];
                for each ( var eventFuncKey : Object in mEventDict )
                {
                    eventFuncKeyArr.push( eventFuncKey );
                }
                for each ( eventFuncKey in eventFuncKeyArr )
                {
                    delete mEventDict[ eventFuncKey ];
                }
                mEventDict = null;
            }

            if ( mSceneManager )
            {
                mSceneManager.dispose ();
            }
            renderer.dispose ();

            StaticBuffers.getInstance().dispose ();
            RenderTexturePool.instance().dispose();
            if ( sCurrent == this ) sCurrent = null;
        }

        public function simulateLostDriver () : void
        {
            if ( mContext )
            {
                // Per default, the context is recreated as long as there are listeners on it.
                // Beginning with AIR 3.6, we can avoid that with an additional parameter.

                var disposeContext3D : Function = mContext.dispose;
                if ( disposeContext3D.length == 1 ) disposeContext3D ( false );
                else disposeContext3D ();
            }
        }

        private const AVAILABLE_PROFILES : Vector.<String> =
                new <String>[ "standard", Context3DProfile.BASELINE_EXTENDED, Context3DProfile.BASELINE, Context3DProfile.BASELINE_CONSTRAINED ];
        // functions

        private function requestContext3D ( stage3D : Stage3D, renderMode : String, profile : Object ) : void
        {
            var profiles : Vector.<String>;

            if ( profile == "auto" )
                profiles = AVAILABLE_PROFILES.slice ();
            else if ( profile is String )
                profiles = new <String>[ profile as String ];
            else if ( profile is Vector.<String> )
                profiles = profile as Vector.<String>;
            else if ( profile is Array )
            {
                profiles = new <String>[];

                for ( var i : int = 0; i < profile.length; ++i )
                    profiles[ i ] = profile[ i ];
            }
            else
            {
                throw new ArgumentError ( "Profile must be of type 'String', 'Array', " +
                        "or 'Vector.<String>'" );
            }

            mProfiles = profiles;
            mRenderMode = renderMode;

            // sort profiles descending
            profiles.sort ( compareProfiles );

            function compareProfiles ( a : String, b : String ) : int
            {
                var indexA : int = AVAILABLE_PROFILES.indexOf ( a );
                var indexB : int = AVAILABLE_PROFILES.indexOf ( b );

                if ( indexA < indexB ) return -1;
                else if ( indexA > indexB ) return 1;
                else return 0;
            }

            requestNextProfile ();
        }

        private function requestNextProfile () : void
        {
            // pull off the next profile and try to init Stage3D with it
            mProfile = mProfiles.shift ();

            try
            {
//				if("requestContext3DMatchingProfiles" in stage3D){
//					stage3D.requestContext3DMatchingProfiles(AVAILABLE_PROFILES);
//				}
//				else{
                stage3D.requestContext3D ( mRenderMode, mProfile );
//				}
            }
            catch ( e : Error )
            {
                if ( mProfiles.length > 0 )
                {
                    // try again next frame
                    setTimeout ( requestNextProfile, 1 );
                }
                else
                {
                    showFatalError ( "Context3D error: " + e.message );
                }
            }
        }

        private function initialize () : void
        {
            makeCurrent ();

            initializeGraphicsAPI ();
            initializeRoot ();

            mTouchProcessor.simulateMultitouch = mSimulateMultitouch;
            mLastFrameTimestamp = getTimer () / 1000.0;

            if ( !mIsSoftwareMode )
                disposeCompositorTexture ();
        }

        private function disposeCompositor () : void
        {
            var compositorLen : int = mCompositors.length;
            for ( var i : int = 0; i < compositorLen; ++i )
            {
                mCompositors[ i ].dispose ();
            }
            mCompositors.fixed = false;
            mCompositors.length = 0;
            mCompositors = null;

            disposeCompositorTexture ();
        }

        private function disposeCompositorTexture () : void
        {
            if ( mCompositorInTexture )
            {
                RenderTexturePool.instance().recycleTexture(mCompositorInTexture);
                mCompositorInTexture = null;
            }

            if ( mCompositorOutTexture )
            {
                RenderTexturePool.instance().recycleTexture(mCompositorOutTexture);
                mCompositorOutTexture = null;
            }
        }

        private function initializeGraphicsAPI () : void
        {
            mContext = mStage3D.context3D;
            mContext.enableErrorChecking = mEnableErrorChecking;
            mDriverInfo = mContext.driverInfo;

            var str : String = mDriverInfo.toLocaleLowerCase ();
            mIsOpenGL = (str.indexOf ( "opengl" ) > -1);

            if ( mProfile == null )
                mProfile = mContext[ "profile" ];

            updateViewPort ( true );

            trace ( "[Starling] Initialization complete." );
            trace ( "[Starling] Display Driver:", mDriverInfo );

            dispatchEventWith ( QFLib.Graphics.RenderCore.starling.events.Event.CONTEXT3D_CREATE, false, mContext );
        }

        private function initializeRoot () : void
        {
            if ( mRoot == null )
            {
                mRoot = new mRootClass () as DisplayObject;
                if ( mRoot == null ) throw new Error ( "Invalid root class: " + mRootClass );
                mStage.addChildAt ( mRoot, 0 );

                dispatchEventWith ( QFLib.Graphics.RenderCore.starling.events.Event.ROOT_CREATED, false, mRoot );
            }
        }

        /*texture*/
        public function createTexture ( width : int, height : int, format : String, optimizeForRenderToTexture : Boolean, streamingLevels : int = 0 ) : flash.display3D.textures.Texture
        {
            return mContext.createTexture ( width, height, format, optimizeForRenderToTexture, streamingLevels );
        }

        public function uploadTextureData () : void
        {

        }

        public function calcTextureSize () : uint
        {
            return 0;
        }

        public function createRectangleTexture ( width : int, height : int, format : String, optimizeForRenderToTexture : Boolean ) : TextureBase
        {
            return mContext[ "createRectangleTexture" ] ( width, height, format, optimizeForRenderToTexture );
        }

        /*Resources*/
        //vertex buffer manage
        public function createVertexBuffer ( numVertices : int, data32PerVertex : int, bufferUsage : String = "staticDraw" ) : VertexBuffer3D
        {
            ++mVertexBufferCount;
            if ( !mFlashPriorOrEqualTo12 )
                return mContext.createVertexBuffer ( numVertices, data32PerVertex, bufferUsage );
            else
                return mContext.createVertexBuffer ( numVertices, data32PerVertex );
        }

        public function uploadVertexBufferData ( vertexBuffer : VertexBuffer3D, data : Vector.<Number>, startOffset : int, count : int ) : void
        {
            vertexBuffer.uploadFromVector ( data, startOffset, count );
        }

        public function uploadVertexBufferBytes ( vertexBuffer : VertexBuffer3D, data : ByteArray, byteArrayOffset : int, startVertex : int, numVertices : int ) : void
        {
            vertexBuffer.uploadFromByteArray ( data, byteArrayOffset, startVertex, numVertices );
        }

        public function destroyVertexBuffer ( vertexBuffer : VertexBuffer3D ) : void
        {
            if ( null == vertexBuffer )
            {
                return;
            }

            --mVertexBufferCount;
            vertexBuffer.dispose ();
            vertexBuffer = null;
        }

        //index buffer manage
        public function createIndexBuffer ( numIndices : int, bufferUsage : String = "staticDraw" ) : IndexBuffer3D
        {
            ++mIndexBufferCount;
            if ( !mFlashPriorOrEqualTo12 )
                return mContext.createIndexBuffer ( numIndices, bufferUsage );
            else
                return mContext.createIndexBuffer ( numIndices );
        }

        public function uploadIndexBufferData ( indexBuffer : IndexBuffer3D, data : Vector.<uint>, startOffset : int, count : int ) : void
        {
            indexBuffer.uploadFromVector ( data, startOffset, count );
        }

        public function destroyIndexBuffer ( indexBuffer : IndexBuffer3D ) : void
        {
            if ( null == indexBuffer )
            {
                return;
            }

            --mIndexBufferCount;
            indexBuffer.dispose ();
            indexBuffer = null;
        }

        /*shaders*/
        public function createProgram () : Program3D
        {
            return mContext.createProgram ();
        }

        public function setProgram ( program : Program3D ) : void
        {
            mContext.setProgram ( program );
        }

        public function setProgramConstantsFromMatrix ( programType : String, firstRegister : int, matrix : Matrix3D, transposedMatrix : Boolean = false ) : void
        {
            mContext.setProgramConstantsFromMatrix ( programType, firstRegister, matrix, transposedMatrix );
        }

        public function setProgramConstantsFromVector ( programType : String, firstRegister : int, data : Vector.<Number>, numRegisters : int = -1 ) : void
        {
            mContext.setProgramConstantsFromVector ( programType, firstRegister, data, numRegisters );
        }

        /*render commands, eg.set***()*/
        public function setTexture ( slot : uint, texture : TextureBase ) : void
        {
            mContext.setTextureAt ( slot, texture );
        }

        public function setBlendFactors ( sourceFactor : String, destinationFactor : String ) : void
        {
            mContext.setBlendFactors ( sourceFactor, destinationFactor );
        }

        public function setScissorRectangle ( rectangle : Rectangle ) : void
        {
            mContext.setScissorRectangle ( rectangle );
        }

        public function setRenderToTexture ( texture : TextureBase, enableDepthAndStencil : Boolean = false, antiAlias : int = 0, surfaceSelector : int = 0, colorOutputIndex : int = 0 ) : void
        {
            if ( !mFlashPriorOrEqualTo14 )
                mContext.setRenderToTexture ( texture, enableDepthAndStencil, antiAlias, surfaceSelector, colorOutputIndex );
            else
                mContext.setRenderToTexture ( texture );
        }

        public function setRenderToBackBuffer () : void
        {
            mContext.setRenderToBackBuffer ();
        }

        public function setVertexBuffer ( index : uint, buffer : VertexBuffer3D, offset : uint, format : String ) : void
        {
            mContext.setVertexBufferAt ( index, buffer, offset, format );
        }

        public function clearVertexBuffer ( index : uint ) : void
        {
            mContext.setVertexBufferAt ( index, null );
        }

        public function present () : void
        {
            mContext.present ();
        }

        /*draw call & clear*/
        public function clear ( red : Number = 0.0, green : Number = 0.0, blue : Number = 0.0, alpha : Number = 1.0, depth : Number = 1.0, stencil : uint = 0, mask : uint = 0 ) : void
        {
            mContext.clear ( red, green, blue, alpha, depth, stencil, mask );
        }

        public function drawTriangles ( indexBuffer : IndexBuffer3D, index : int, numTriangles : int ) : void
        {
            ++mDrawCallCount;
            mContext.drawTriangles ( indexBuffer, index, numTriangles );
        }

        /*others*/
        public function isProfileBaselineConstrained () : Boolean
        {
            return mProfile == "baselineConstrained";
        }

        public function isCreateRectangleTextureInContext () : Boolean
        {
            return "createRectangleTexture" in mContext;
        }

        public function drawToBitmapData ( destination : BitmapData ) : void
        {
            mContext.drawToBitmapData ( destination );
        }

        /** Calls <code>advanceTime()</code> (with the time that has passed since the last frame)
         *  and <code>render()</code>. */
        public function nextFrame () : void
        {
            var now : Number = getTimer () / 1000.0;
            var passedTime : Number = now - mLastFrameTimestamp;
            mLastFrameTimestamp = now;

            advanceTime ( passedTime );

            for each ( var func : Function in mFrameHandlers )
                func ( passedTime );

            mSceneManager.updateScene ( passedTime, mStage );

            render ();
        }

        /** Dispatches ENTER_FRAME events on the display list, advances the Juggler
         *  and processes touches. */
        public function advanceTime ( passedTime : Number ) : void
        {
            if ( !contextValid )
                return;

            makeCurrent ();

            mTouchProcessor.advanceTime ( passedTime );
            mStage.advanceTime ( passedTime );
        }

        /** Renders the complete display list. Before rendering, the context is cleared; afterwards,
         *  it is presented. This can be avoided by enabling <code>shareContext</code>.*/
        public function render () : void
        {
            mDrawCallCount = 0;
            if ( !contextValid )
                return;

            dispatchEventWith ( QFLib.Graphics.RenderCore.starling.events.Event.PRE_RENDER );
            makeCurrent ();

            updateViewPort ();
            if ( mClippedViewPort.width <= 0 || mClippedViewPort.height <= 0 )
                return;

            updateNativeOverlay ();
            mSupport.nextFrame ();

            mContext.setDepthTest ( false, Context3DCompareMode.ALWAYS );
            mContext.setCulling ( Context3DTriangleFace.NONE );

            if ( !mShareContext )
                RenderSupport.clear ( mStage.color, 1.0 );

            if ( !mIsSoftwareMode )
            {
                var firIndex : int = firstEnableCompositorIndex ();
                if ( !mFlashPriorOrEqualTo14 )
                {
                    if ( firIndex >= 0 )
                    {
                        var compositor : ICompositor = mCompositors[ firIndex ];
                        var width : int = compositor.textureWidth;
                        var height : int = compositor.textureHeight;
                        if ( mCompositorInTexture == null )
                            mCompositorInTexture = RenderTexturePool.instance().empty( width, height, true, false, true, 1, "bgra", false );
                        else if ( width > 0 && height > 0 )
                            resizeCompositorTexture ( width, height, true, false );

                        if ( mCompositorInTexture != null )
                        {
                            mSupport.pushRenderTarget ( mCompositorInTexture );
                            mSupport.clear ();
                        }
                    }
                }
            }

            // 遍历camera，依次调用它的渲染接口
            var cameraList : Vector.<ICamera> = mRenderer.getCameraList ();
            for each ( var camera : ICamera in cameraList )
            {
                if( camera.enabled == false ) continue;
                if ( !mShareContext && camera.clearMask != 0 )
                {
                    RenderSupport.clear ( mStage.color, 1.0, 1.0, 0, camera.clearMask );
                }

                mRenderer.setCurrentCamera ( camera );
                mSceneManager.renderScene ( camera, mStage, mSupport );
                mSupport.finishQuadBatch ();
            }

            if ( !mFlashPriorOrEqualTo14 && !mIsSoftwareMode )
                renderCompositor ( firIndex );

            mUICamera.enabled = true;
            mRenderer.setCurrentCamera ( mUICamera );
            mSceneManager.renderScene ( mUICamera, mStage, mSupport );
            mUICamera.enabled = false;

            RenderCommand.clearCommands ();

            if ( mStatsDisplay )
            {
                mStatsDisplay.drawCount = mSupport.drawCount;
                mStatsDisplay.drawCount += mRenderer.drawCount;
            }
            mRenderer.clearDrawCount ();

            if ( snapshotCallback != null )
            {
                snapshotCallback();
                snapshotCallback = null;
            }

            if ( !mShareContext )
                mContext.present ();
        }

        public function snapshotRendering ( target : DisplayObject, snapshotVPW : Number, snapshotVPH : Number,
                                            camOffsetX : Number = 0, camOffsetY : Number = 0, scaleX : Number = 1, scaleY : Number = 1 ) : void
        {
            if ( !contextValid ) return;

            mSupport.nextFrame ();
            mSupport.clear ( 0x00, 0 );
            //this.setScissorRectangle ( new Rectangle (0, 0, snapshotVPW, snapshotVPH) );

            mContext.setDepthTest ( false, Context3DCompareMode.ALWAYS );
            mContext.setCulling ( Context3DTriangleFace.NONE );

            var worldMatrix : Matrix = target.worldTransform;

            var wa : Number = worldMatrix.a;
            var wb : Number = worldMatrix.b;
            var wc : Number = worldMatrix.c;
            var wd : Number = worldMatrix.d;
            var wx : Number = worldMatrix.tx;
            var wy : Number = worldMatrix.ty;

            worldMatrix.a = scaleX;
            worldMatrix.b = 0;
            worldMatrix.c = 0;
            worldMatrix.d = scaleY;
            worldMatrix.tx = ( -mClippedViewPort.width + snapshotVPW ) * 0.5 + camOffsetX;
            worldMatrix.ty = ( -mClippedViewPort.height * 0.5 + snapshotVPH ) + camOffsetY;    //y值上层都是反的。。。导致摄像机正交投影也得那么搞。。。

            mDefaultCamera.setOrthoSize ( mClippedViewPort.width, mClippedViewPort.height );
            mDefaultCamera.setPosition ( 0, 0 );
            mRenderer.setCurrentCamera ( mDefaultCamera );

            target.render ( mSupport, 1.0 );

            mSupport.finishQuadBatch ();

            worldMatrix.a = wa;
            worldMatrix.b = wb;
            worldMatrix.c = wc;
            worldMatrix.d = wd;
            worldMatrix.tx = wx;
            worldMatrix.ty = wy;
        }

        public function snapshotToBitmapData ( result : BitmapData, snapshotDraw : Boolean = true ) : BitmapData
        {
            if ( !contextValid ) return result;
            if ( snapshotDraw ) drawToBitmapData ( result );

            return result;
        }

        public function registerCompositor ( compositor : ICompositor ) : void
        {
            var len : int = mCompositors.length;
            mCompositors.fixed = false;
            mCompositors.length += 1;
            mCompositors[ len ] = compositor;
            mCompositors.fixed = true;
        }

        private function renderCompositor ( firstIndex : int ) : void
        {
            if ( firstIndex < 0 ) return;
            mSupport.popRenderTarget ();

            if ( mCompositorOutTexture == null )
                mCompositorOutTexture = RenderTexturePool.instance().empty ( mCompositorInTexture.width, mCompositorInTexture.height,
                        true, false, true, 1, "bgra", false );

            if ( mCompositorOutTexture == null ) return;

            var inRenderTexture : Texture = null;
            var command : RenderCommand;
            var compositor : ICompositor;
            var lastIndex : int = lastEnableCompositorIndex ();
            var compositorLen : int = mCompositors.length;
            mRenderer.setCurrentCamera ( mCompositorCamera );
            for ( var i : int = 0; i < compositorLen; ++i )
            {
                compositor = mCompositors[ i ];
                if ( compositor.enable )
                {
                    inRenderTexture = mCompositorInTexture;

                    if ( i < lastIndex )
                    {
                        var width : int = compositor.textureWidth;
                        var height : int = compositor.textureHeight;
                        if ( width > 0 && height > 0 )
                            resizeCompositorTexture ( width, height, false, true );

                        mSupport.pushRenderTarget ( mCompositorOutTexture );
                    }
                    else
                    {
                        Starling.current.setRenderToBackBuffer ();
                    }

                    RenderSupport.clear ();
                    compositor.preRenderTarget = inRenderTexture;

                    var worldMatrix : Matrix = compositor.worldMatrix;
                    command = RenderCommand.assign ( worldMatrix );
                    command.geometry = compositor.geometry;
                    command.material = compositor.material;

                    Starling.current.addToRender ( command );

                    if ( i < lastIndex )
                    {
                        mSupport.popRenderTarget ();
                    }

                    swarRenderTexture ();
                }
            }
        }

        private function swarRenderTexture () : void
        {
            // 调换输入输出纹理，以循环使用
            var tmpTexture : Texture = mCompositorInTexture;
            mCompositorInTexture = mCompositorOutTexture;
            mCompositorOutTexture = tmpTexture;
        }

        private function hasCompositorEnable () : Boolean
        {
            var compositorLen : int = mCompositors.length;
            for ( var i : int = 0; i < compositorLen; ++i )
            {
                if ( mCompositors[ i ].enable )
                {
                    return true;
                }
            }

            return false;
        }

        private function firstEnableCompositorIndex () : int
        {
            for ( var i : int = 0, len : int = mCompositors.length; i < len; ++i )
            {
                if ( mCompositors[ i ].enable )
                {
                    return i;
                }
            }

            return -1;
        }


        private function lastEnableCompositorIndex () : int
        {
            var compositorLen : int = mCompositors.length;
            for ( var i : int = compositorLen - 1; i >= 0; --i )
            {
                if ( mCompositors[ i ].enable )
                {
                    return i;
                }
            }

            return 0;
        }

        private function resizeCompositorTexture ( width : int, height : int, inTexture : Boolean = true, outTexture : Boolean = true ) : void
        {
            if ( inTexture && ( mCompositorInTexture.width != width ||
                    mCompositorInTexture.height != height ) )
            {
                width = GetNextPowerOfTwo ( width );
                height = GetNextPowerOfTwo ( height );

                RenderTexturePool.instance().recycleTexture(mCompositorInTexture);
                mCompositorInTexture = RenderTexturePool.instance().empty( width, height, true, false, true, 1, "bgra", true );
            }

            if ( outTexture && ( mCompositorOutTexture.width != width ||
                    mCompositorOutTexture.height != height ) )
            {
                width = GetNextPowerOfTwo ( width );
                height = GetNextPowerOfTwo ( height );

                RenderTexturePool.instance().recycleTexture(mCompositorOutTexture);
                mCompositorOutTexture = RenderTexturePool.instance().empty( width, height, true, false, true, 1, "bgra", true );
            }
        }

        private function updateViewPort ( forceUpdate : Boolean = false ) : void
        {
            // the last set viewport is stored in a variable; that way, people can modify the
            // viewPort directly (without a copy) and we still know if it has changed.

            if ( forceUpdate || mPreviousViewPort.width != mViewPort.width ||
                    mPreviousViewPort.height != mViewPort.height ||
                    mPreviousViewPort.x != mViewPort.x || mPreviousViewPort.y != mViewPort.y )
            {
                mPreviousViewPort.setTo ( mViewPort.x, mViewPort.y, mViewPort.width, mViewPort.height );

                mClippedViewPort = mViewPort;
                if ( !mShareContext )
                {
                    // setting x and y might move the context to invalid bounds (since changing
                    // the size happens in a separate operation) -- so we have no choice but to
                    // set the backbuffer to a very small size first, to be on the safe side.

                    if ( mProfile == "baselineConstrained" )
                        configureBackBuffer ( 32, 32, mAntiAliasing, false );

                    mStage3D.x = mClippedViewPort.x;
                    mStage3D.y = mClippedViewPort.y;

                    configureBackBuffer ( mClippedViewPort.width, mClippedViewPort.height,
                            mAntiAliasing, false, mSupportHighResolutions );

                    if ( mSupportHighResolutions && "contentsScaleFactor" in mNativeStage )
                        mNativeStageContentScaleFactor = mNativeStage[ "contentsScaleFactor" ];
                    else
                        mNativeStageContentScaleFactor = 1.0;
                }
            }
        }

        /** Configures the back buffer while automatically keeping backwards compatibility with
         *  AIR versions that do not support the "wantsBestResolution" argument. */
        private function configureBackBuffer ( width : int, height : int, antiAlias : int,
                                               enableDepthAndStencil : Boolean,
                                               wantsBestResolution : Boolean = false ) : void
        {
            var configureBackBuffer : Function = mContext.configureBackBuffer;
            var methodArgs : Array = [ width, height, antiAlias, enableDepthAndStencil ];
            if ( configureBackBuffer.length > 4 ) methodArgs.push ( wantsBestResolution );
            configureBackBuffer.apply ( mContext, methodArgs );
        }

        private function updateNativeOverlay () : void
        {
            mNativeOverlay.x = mViewPort.x;
            mNativeOverlay.y = mViewPort.y;
            mNativeOverlay.scaleX = mViewPort.width / mStage.stageWidth;
            mNativeOverlay.scaleY = mViewPort.height / mStage.stageHeight;
        }

        private function showFatalError ( message : String ) : void
        {
            var textField : TextField = new TextField ();
            var textFormat : TextFormat = new TextFormat ( "Verdana", 12, 0xFFFFFF );
            textFormat.align = TextFormatAlign.CENTER;
            textField.defaultTextFormat = textFormat;
            textField.wordWrap = true;
            textField.width = mStage.stageWidth * 0.75;
            textField.autoSize = TextFieldAutoSize.CENTER;
            textField.text = message;
            textField.x = (mStage.stageWidth - textField.width) / 2;
            textField.y = (mStage.stageHeight - textField.height) / 2;
            textField.background = true;
            textField.backgroundColor = 0x440000;
            nativeOverlay.addChild ( textField );
        }

        /** Make this Starling instance the <code>current</code> one. */
        [Inline] final public function makeCurrent () : void { sCurrent = this; }

        /** As soon as Starling is started, it will queue input events (keyboard/mouse/touch);
         *  furthermore, the method <code>nextFrame</code> will be called once per Flash Player
         *  frame. (Except when <code>shareContext</code> is enabled: in that case, you have to
         *  call that method manually.) */
        public function start () : void
        {
            mStarted = mRendering = true;
            mLastFrameTimestamp = getTimer () / 1000.0;
        }

        /** Stops all logic and input processing, effectively freezing the app in its current state.
         *  Per default, rendering will continue: that's because the classic display list
         *  is only updated when stage3D is. (If Starling stopped rendering, conventional Flash
         *  contents would freeze, as well.)
         *
         *  <p>However, if you don't need classic Flash contents, you can stop rendering, too.
         *  On some mobile systems (e.g. iOS), you are even required to do so if you have
         *  activated background code execution.</p>
         */
        public function stop ( suspendRendering : Boolean = false ) : void
        {
            mStarted = false;
            mRendering = !suspendRendering;
        }

        // render ex!
        public function addToRender ( robj : RenderCommand ) : void
        {
            mRenderer.render ( robj );
        }

        // event handlers
        private function onStage3DError ( event : ErrorEvent ) : void
        {
            if ( mProfiles.length > 0 )
            {
                setTimeout ( requestNextProfile, 1 );
                return;
            }

            if ( event.errorID == 3702 )
            {
                var mode : String = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
                showFatalError ( "Context3D not available! Possible reasons: wrong " + mode +
                        " or missing device support." );
            }
            else
                showFatalError ( "Stage3D error: " + event.text );
        }

        private function onContextCreated ( event : flash.events.Event ) : void
        {
            mIsSoftwareMode = stage3D.context3D.driverInfo.toLowerCase ().indexOf ( "software" ) >= 0;
            Quality.isSoftwareRender = mIsSoftwareMode;
            if ( mIsSoftwareMode && mProfiles.length > 0 )
            {
                // don't settle for software mode if there are more hardware profiles to try
                setTimeout ( requestNextProfile, 1 );
                return;
            }

            if ( !Starling.handleLostContext && mContext )
            {
                stop ();
                event.stopImmediatePropagation ();
                showFatalError ( "Fatal error: The application lost the device context!" );
                trace ( "[Starling] The device context was lost. " +
                        "Enable 'Starling.handleLostContext' to avoid this error." );
            }
            else
            {
                mStatsDisplay = new StatsDisplay ();
                initialize ();
            }

            invokeContext3DCreateCallback( event );
        }

        public function addFramedCB ( func : Function ) : void
        {
            if ( mFrameHandlers.indexOf ( func ) == -1 ) mFrameHandlers.push ( func );
        }
        public function removeFramedCB ( func : Function ) : void
        {
            var index : int = mFrameHandlers.indexOf ( func );
            if ( index != -1 ) mFrameHandlers.splice ( index, 1 );
        }

        public function rendering () : void
        {
            if ( !mShareContext )
            {
                if ( mStarted ) nextFrame ();
                else if ( mRendering ) render ();
            }
        }

        private function onResize ( event : flash.events.Event ) : void
        {
            makeCurrent ();

            mStage.stageWidth = mNativeStage.stageWidth;
            mStage.stageHeight = mNativeStage.stageHeight;
            mViewPort.setTo ( 0, 0, mStage.stageWidth, mStage.stageHeight );

            var stage : flash.display.Stage = event.target as flash.display.Stage;
            mStage.dispatchEvent ( new ResizeEvent ( flash.events.Event.RESIZE, stage.stageWidth, stage.stageHeight ) );
        }

        /** Indicates if this Starling instance is started. */
        public function get isStarted () : Boolean
        { return mStarted; }

        [Inline] public function get defaultCamera () : ICamera { return mDefaultCamera; }
        [Inline] public function get filterCamera () : ICamera { return mFilterCamera; }
        [Inline] public function get uiCamera () : ICamera { return mUICamera; }
        [Inline] public function get renderer () : IRenderer { return mRenderer; }

        /** A dictionary that can be used to save custom data related to the current context.
         *  If you need to share data that is bound to a specific stage3D instance
         *  (e.g. textures), use this dictionary instead of creating a static class variable.
         *  The Dictionary is actually bound to the stage3D instance, thus it survives a
         *  context loss. */
        public function get contextData () : Dictionary
        {
            return sContextData[ mStage3D ] as Dictionary;
        }

        /** Returns the actual width (in pixels) of the back buffer. This can differ from the
         *  width of the viewPort rectangle if it is partly outside the native stage. */
        [Inline] final public function get backBufferWidth () : int { return mClippedViewPort.width; }

        /** Returns the actual height (in pixels) of the back buffer. This can differ from the
         *  height of the viewPort rectangle if it is partly outside the native stage. */
        [Inline] final public function get backBufferHeight () : int { return mClippedViewPort.height; }

        /** Indicates if multitouch simulation with "Shift" and "Ctrl"/"Cmd"-keys is enabled.
         *  @default false */
        [Inline] final public function get simulateMultitouch () : Boolean { return mSimulateMultitouch; }
        public function set simulateMultitouch ( value : Boolean ) : void
        {
            mSimulateMultitouch = value;
            if ( mContext ) mTouchProcessor.simulateMultitouch = value;
        }

        /** Indicates if Stage3D render methods will report errors. Activate only when needed,
         *  as this has a negative impact on performance. @default false */
        public function get enableErrorChecking () : Boolean
        { return mEnableErrorChecking; }

        public function set enableErrorChecking ( value : Boolean ) : void
        {
            mEnableErrorChecking = value;
            if ( mContext ) mContext.enableErrorChecking = value;
        }

        /** The antialiasing level. 0 - no antialasing, 16 - maximum antialiasing. @default 0 */
        public function get antiAliasing () : int
        { return mAntiAliasing; }

        public function set antiAliasing ( value : int ) : void
        {
            if ( mAntiAliasing != value )
            {
                mAntiAliasing = value;
                if ( contextValid ) updateViewPort ( true );
            }
        }

        /** The viewport into which Starling contents will be rendered. */
        [Inline] final public function get viewPort () : Rectangle { return mViewPort; }

        /** The ratio between viewPort width and stage width. Useful for choosing a different
         *  set of textures depending on the display resolution. */
        public function get contentScaleFactor () : Number
        {
            return (mViewPort.width * mNativeStageContentScaleFactor) / mStage.stageWidth;
        }

        /** A Flash Sprite placed directly on top of the Starling content. Use it to display native
         *  Flash components. */
        [Inline] final public function get nativeOverlay () : Sprite { return mNativeOverlay; }

        /** Indicates if a small statistics box (with FPS, memory usage and draw count) is displayed. */
        [Inline] final public function get showStats () : Boolean { return mStatsDisplay && mStatsDisplay.parent; }

        public function set showStats ( value : Boolean ) : void
        {
            if ( value == showStats ) return;

            if ( value )
            {
                if ( mStatsDisplay ) mStage.addChild ( mStatsDisplay );
                else               showStatsAt ();
            }
            else mStatsDisplay.removeFromParent ();
        }

        /** Displays the statistics box at a certain position. */
        public function showStatsAt ( hAlign : String = "left", vAlign : String = "top", scale : Number = 1 ) : void
        {
            if ( mContext == null )
            {
                // Starling is not yet ready - we postpone this until it's initialized.
                addEventListener ( QFLib.Graphics.RenderCore.starling.events.Event.ROOT_CREATED, onRootCreated );
            }
            else
            {
                mStatsDisplay.touchable = false;
                var stageWidth : int = mStage.stageWidth;
                var stageHeight : int = mStage.stageHeight;

                mStatsDisplay.scaleX = mStatsDisplay.scaleY = scale;

                if ( hAlign == HAlign.LEFT ) mStatsDisplay.x = 0;
                else if ( hAlign == HAlign.RIGHT ) mStatsDisplay.x = stageWidth - mStatsDisplay.width;
                else mStatsDisplay.x = int ( (stageWidth - mStatsDisplay.width) / 2 );

                if ( vAlign == VAlign.TOP ) mStatsDisplay.y = 0;
                else if ( vAlign == VAlign.BOTTOM ) mStatsDisplay.y = stageHeight - mStatsDisplay.height;
                else mStatsDisplay.y = int ( (stageHeight - mStatsDisplay.height) / 2 );

                mStage.addChild ( mStatsDisplay );
            }

            function onRootCreated () : void
            {
                showStatsAt ( hAlign, vAlign, scale );
                removeEventListener ( QFLib.Graphics.RenderCore.starling.events.Event.ROOT_CREATED, onRootCreated );
            }
        }

        public function addStateTextHandler ( func : Function ) : void { mStatsDisplay.addTextHandler ( func ); }
        public function removeStateTextHandler ( func : Function ) : void { mStatsDisplay.removeTextHandler ( func ); }

        /** The Starling stage object, which is the root of the display tree that is rendered. */
        [Inline] final public function get stage () : Stage { return mStage; }

        /** The Flash Stage3D object Starling renders into. */
        [Inline] final public function get stage3D () : Stage3D { return mStage3D; }

        /** The Flash (2D) stage object Starling renders beneath. */
        [Inline] final public function get nativeStage () : flash.display.Stage { return mNativeStage; }

        /** The instance of the root class provided in the constructor. Available as soon as
         *  the event 'ROOT_CREATED' has been dispatched. */
        [Inline] final public function get root () : DisplayObject { return mRoot; }

        /** Indicates if the Context3D render calls are managed externally to Starling,
         *  to allow other frameworks to share the Stage3D instance. @default false */
        [Inline] final public function get shareContext () : Boolean { return mShareContext; }
        [Inline] final public function set shareContext ( value : Boolean ) : void { mShareContext = value; }

        /** The Context3D profile as requested in the constructor. Beware that if you are
         *  using a shared context, this is simply what you passed to the Starling constructor. */
        public function get profile () : String
        { return mProfile; }

        [Inline] final public function get driverInfo () : String { return mDriverInfo; }
        [Inline] final public function get isOpenGL () : Boolean { return mIsOpenGL; }
        [Inline] final public function get isSoftWareMode () : Boolean { return mIsSoftwareMode; }

        /** Indicates that if the device supports HiDPI screens Starling will attempt to allocate
         *  a larger back buffer than indicated via the viewPort size. Note that this is used
         *  on Desktop only; mobile AIR apps still use the "requestedDisplayResolution" parameter
         *  the application descriptor XML. */
        public function get supportHighResolutions () : Boolean
        { return mSupportHighResolutions; }

        public function set supportHighResolutions ( value : Boolean ) : void
        {
            if ( mSupportHighResolutions != value )
            {
                mSupportHighResolutions = value;
                if ( contextValid ) updateViewPort ( true );
            }
        }

        /** The TouchProcessor is passed all mouse and touch input and is responsible for
         *  dispatching TouchEvents to the Starling display tree. If you want to handle these
         *  types of input manually, pass your own custom subclass to this property. */
        /*public function get touchProcessor():TouchProcessor { return mTouchProcessor; }
         public function set touchProcessor(value:TouchProcessor):void
         {
         if (value != mTouchProcessor)
         {
         mTouchProcessor.dispose();
         mTouchProcessor = value;
         }
         }*/

        /** Indicates if the Context3D object is currently valid (i.e. it hasn't been lost or
         *  disposed). Beware that each call to this method causes a String allocation (due to
         *  internal code Starling can't avoid), so do not call this method too often. */
        public function get contextValid () : Boolean
        {
            return mContext && mContext.driverInfo != "Disposed";
        }

        public function get support () : RenderSupport
        {
            return mSupport;
        }

        /** The original width of starling*/
        public function get originWidth () : Number
        {
            return mOriginalWidth;
        }

        public function get currentScale () : Number
        {
            return mOriginalWidth == 0 ? 1.0 : mNativeStage.stageWidth / mOriginalWidth;
        }

        // static properties

        /** The currently active Starling instance. */
        public static function get current () : Starling
        { return sCurrent; }

        /** The contentScaleFactor of the currently active Starling instance. */
        public static function get contentScaleFactor () : Number
        {
            return sCurrent ? sCurrent.contentScaleFactor : 1.0;
        }

        /** Indicates if Starling should automatically recover from a lost device context.
         *  On some systems, an upcoming screensaver or entering sleep mode may
         *  invalidate the render context. This setting indicates if Starling should recover from
         *  such incidents. Beware that this has a huge impact on memory consumption!
         *  It is recommended to enable this setting on Android and Windows, but to deactivate it
         *  on iOS and Mac OS X. @default false */
        public static function get handleLostContext () : Boolean
        { return sHandleLostContext; }



        public static function addContext3DCreateCallback( object : Object, func : Function ) : void
        {
            if ( LISTEN_CONTEXT3D_CREATED_TYPE == 1 )
            {
                Starling.current.stage3D.addEventListener ( Event.CONTEXT3D_CREATE,
                        func, false, 0, true );
            }
            else if ( LISTEN_CONTEXT3D_CREATED_TYPE == 2 )
            {
                if ( sCurrent != null && sCurrent.mEventDict )
                {
                    sCurrent.mEventDict[ object ] = func;
                }
            }
        }

        public static function removeContext3DCreateCallback( object : Object, func : Function ) : void
        {
            if ( LISTEN_CONTEXT3D_CREATED_TYPE == 1 )
            {
                Starling.current.stage3D.removeEventListener ( Event.CONTEXT3D_CREATE, func );
            }
            else if ( LISTEN_CONTEXT3D_CREATED_TYPE == 2 )
            {
                if ( sCurrent != null && sCurrent.mEventDict )
                {
                    delete sCurrent.mEventDict[ object ];
                }
            }
        }

        private static function invokeContext3DCreateCallback( e : * )
        {
            var arr : Array = [];
            var dict : Dictionary = sCurrent.mEventDict;
            for each ( var func : Function in dict )
            {
                arr.push( func );
            }
            for each ( func in arr )
            {
                func( e );
            }
        }

        // 1:src, 2:new
        public static var LISTEN_CONTEXT3D_CREATED_TYPE : int = 1;

        public static function set handleLostContext ( value : Boolean ) : void
        {
            if ( sCurrent ) throw new IllegalOperationError (
                    "'handleLostContext' must be set before Starling instance is created" );
            else
                sHandleLostContext = value;
        }

        public function get sceneManager () : SceneManager
        {
            return mSceneManager;
        }

        public function getProgram ( name : String ) : Program3D
        {
            throw new DefinitionError ( "Can't use this function. " +
                    "It use to make spine.starling.PolygonBatch happy!" );
            return null;
        }

        public function registerProgramFromSource ( name : String, vertexShader : String, fragmentShader : String ) : Program3D
        {
            throw new DefinitionError ( "Can't use this function. " +
                    "It use to make spine.starling.PolygonBatch happy!" );
            return null;
        }
    }
}
