/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/8.
 */
package QFLib.QEngine.Renderer.Device
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Renderer.*;
    import QFLib.QEngine.Renderer.Events.RendererEvent;
    import QFLib.QEngine.Renderer.States.BlendState;
    import QFLib.QEngine.Renderer.States.DepthStencilState;
    import QFLib.QEngine.Renderer.States.RasterState;
    import QFLib.QEngine.Renderer.States.SampleState;
    import QFLib.QEngine.Renderer.Textures.Texture;
    import QFLib.QEngine.Renderer.Textures.TextureSlot;
    import QFLib.QEngine.Renderer.Textures.TextureSmoothing;
    import QFLib.QEngine.Renderer.Utils.SystemUtil;

    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DClearMask;
    import flash.display3D.Context3DMipFilter;
    import flash.display3D.Context3DProfile;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTextureFilter;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.TextureBase;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.system.Capabilities;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.ByteArray;
    import flash.utils.setTimeout;

    public class RenderDevice extends EventDispatcher implements IDisposable
    {
        use namespace Engine_Internal;

        public static const PENDING_VIEWPORT : uint = 1;
        public static const PENDING_INDEXBUF : uint = 2;
        public static const PENDING_VERTEXLAYOUT : uint = 4;
        public static const PENDING_TEXTURES : uint = 8;
        public static const PENDING_SCISSSOR : uint = 16;
        public static const PENDING_RENDERSTATE : uint = 32;

        private static const AVAILABLE_PROFILES : Vector.<String> = new <String>[ "standard", Context3DProfile.BASELINE_EXTENDED, Context3DProfile.BASELINE, Context3DProfile.BASELINE_CONSTRAINED ];

        /**
         * upload shader code to program3D
         */
        private static var sAssembler : AGALMiniAssembler = new AGALMiniAssembler();

        /**
         *
         */
        private static var sVertexBufferCount : int = 0;
        private static var sIndexBufferCount : int = 0;

        /** TextureLookupFlags helper */
        private static var sTextureFormats : Vector.<String> = new <String>[ Context3DTextureFormat.COMPRESSED, Context3DTextureFormat.COMPRESSED_ALPHA, "" ];
        private static var sIsMipMapping : Vector.<Boolean> = new <Boolean>[ true, false ];
        private static var sIsRepeat : Vector.<Boolean> = new <Boolean>[ true, false ];
        private static var sSmoothings : Vector.<String> = new <String>[ TextureSmoothing.NONE, TextureSmoothing.BILINEAR, "" ];
        private static var sTextureFlagTables : Vector.<String> = null;
        private static var sFlag : int;
        private static var sSmoothingIndex : int;

        /** Returns the flags that are required for AGAL texture lookup,
         *  including the '&lt;' and '&gt;' delimiters. */
        public static function getTextureLookupFlags( format : String, mipMapping : Boolean,
                                                      repeat : Boolean = false,
                                                      smoothing : String = "bilinear" ) : String
        {
            if( sTextureFlagTables == null )
            {
                sTextureFlagTables = generateTextureLookupFlags();
            }

            sFlag = sTextureFormats.indexOf( format );

            if( sFlag < 0 )
            {
                sFlag = 2;
            }

            sFlag = sFlag * sIsMipMapping.length + sIsMipMapping.indexOf( mipMapping );
            sFlag = sFlag * sIsRepeat.length + sIsRepeat.indexOf( repeat );
            sFlag = sFlag * sSmoothings.length;

            sSmoothingIndex = sSmoothings.indexOf( smoothing );
            if( sSmoothingIndex < 0 )
            {
                sSmoothingIndex = 2;
            }

            sFlag += sSmoothingIndex;

            return sTextureFlagTables[ sFlag ];
        }

        public static function calcTextureLookupFlags( format : String, mipMapping : Boolean,
                                                       repeat : Boolean = false,
                                                       smoothing : String = "bilinear" ) : String
        {
            var options : Array = [ "2d", repeat ? "repeat" : "clamp" ];

            if( format == Context3DTextureFormat.COMPRESSED )
                options.push( "dxt1" );
            else if( format == "compressedAlpha" )
                options.push( "dxt5" );

            if( smoothing == TextureSmoothing.NONE )
                options.push( "nearest", mipMapping ? "mipnearest" : "mipnone" );
            else if( smoothing == TextureSmoothing.BILINEAR )
                options.push( "linear", mipMapping ? "mipnearest" : "mipnone" );
            else
                options.push( "linear", mipMapping ? "miplinear" : "mipnone" );

            return "<" + options.join() + ">";
        }

        private static function generateTextureLookupFlags() : Vector.<String>
        {
            var result : Vector.<String> = new Vector.<String>();

            for( var i : int = 0; i < sTextureFormats.length; ++i )
            {
                for( var j : int = 0; j < sIsMipMapping.length; ++j )
                {
                    for( var k : int = 0; k < sIsRepeat.length; ++k )
                    {
                        for( var l : int = 0; l < sSmoothings.length; ++l )
                        {
                            result.push( calcTextureLookupFlags( sTextureFormats[ i ], sIsMipMapping[ j ], sIsRepeat[ k ], sSmoothings[ l ] ) );
                        }
                    }
                }
            }

            return result;
        }

        private static function assembleAgal( vsShader : String, fsShader : String, program : Program3D ) : void
        {
            if( program != null )
            {
                program.upload(
                        sAssembler.assemble( Context3DProgramType.VERTEX, vsShader ),
                        sAssembler.assemble( Context3DProgramType.FRAGMENT, fsShader ) );

                return;
            }

            throw new Error( "" )

        }

        /**
         * CRenderDevice Constructor
         * @param stage
         * @param renderMode
         * @param profile
         */
        public function RenderDevice( stage : Stage, renderMode : String = "auto",
                                      profile : Object = "baselineConstrained" )
        {
            m_RenderMode = renderMode;
            m_Profile = profile as String;

            var devicesManager : RenderDeviceManager = RenderDeviceManager.getInstance();
            m_Index = devicesManager._addRenderDevice( this, stage );
            initialize( stage, stage.stage3Ds[ m_Index ] );

            m_TextureSlotStack = new Vector.<TextureSlot>( 8 );
            var i : int = 0;
            while( i < 8 )
            {
                m_TextureSlotStack[ i ] = new TextureSlot();
                ++i;
            }
            m_RenderTargetStack = new Vector.<RenderTargetInfo>();

            m_mapShaderPrograms = new CMap();

            devicesManager.makeCurrent( this );
        }
        private var m_NativeStage : Stage;
        private var m_NativeOverlay : Sprite;
        private var m_Stage3D : Stage3D;
        private var m_Context : Context3D;
        private var m_Profiles : Vector.<String>;
        private var m_Profile : String;
        private var m_RenderMode : String;
        private var m_DriverInfo : String;
        private var m_PendingFilter : uint = 0;
        /**
         * raster state
         */
        private var m_CurRasterState : RasterState = null;
        private var m_NewRasterState : RasterState = new RasterState();
        /**
         * blend state
         */
        private var m_CurBlendState : BlendState = null;
        private var m_NewBlendState : BlendState = new BlendState();
        /**
         * depth and stencil state
         */
        private var m_CurDepthStencilState : DepthStencilState = null;
        private var m_NewDepthStencilState : DepthStencilState = new DepthStencilState();
        /**
         * manage render target
         */
        private var m_RenderTargetStack : Vector.<RenderTargetInfo> = null;
        /**
         * manager shader program
         */
        private var m_mapShaderPrograms : CMap = null;
        private var m_pLastProgram : Program3D = null;
        private var m_bUseDiffProgram : Boolean = false;
        /**
         * texture slot
         */
        private var m_TextureSlotStack : Vector.<TextureSlot> = null;
        private var m_UsedTextureSlotCount : int = 0;
        /**
         * scissor rect
         */
        private var m_ScissorRect : Rectangle = null;
        /**
         * anti alias
         */
        private var m_AntiAliasing : int = 0;
        /**
         * viewport
         */
        private var m_ViewportX : int = -1;
        private var m_ViewportY : int = -1;
        private var m_BackBufferWidth : int = -1;
        private var m_BackBufferHeight : int = -1;
        private var m_ViewportDirty : Boolean = false;
        /**
         * backBuffer color/depth/stencil
         */
        private var m_ClearRed : Number = 0.0;
        private var m_ClearGreen : Number = 0.0;
        private var m_ClearBlue : Number = 0.0;
        private var m_ClearAlpha : Number = 0.0;
        private var m_ReferenceDepth : Number = Number.MAX_VALUE;
        private var m_ReferenceStencil : uint = 0;
        private var m_StencilReadMask : uint = 255;
        private var m_StencilWriteMask : uint = 255;
        /**
         * index in device manager
         */
        private var m_Index : int = -1;
        private var m_IsSoftwareMode : Boolean = false;
        private var m_IsOpenGL : Boolean = false;
        private var m_ShareContext : Boolean = false;

        //Context3D set render state, set texture, and draw call command
        private var m_EnableErrorChecking : Boolean = false;
        private var m_BackBufferEnableDepthAndStencil : Boolean = true;
        private var m_BackBufferDirty : Boolean = true;
        private var m_HandleLostContext : Boolean = true;

        /*Resources*/

        public function get enableErrorChecking() : Boolean
        {
            return m_EnableErrorChecking;
        }

        public function set enableErrorChecking( value : Boolean ) : void
        {
            m_EnableErrorChecking = value;
            if( m_Context ) m_Context.enableErrorChecking = value;
        }

        public function get backBufferEnableDepthAndStencil() : Boolean
        {
            return m_BackBufferEnableDepthAndStencil;
        }

        public function set backBufferEnableDepthAndStencil( value : Boolean ) : void
        {
            m_BackBufferEnableDepthAndStencil = value;
            m_BackBufferDirty = true;
        }

        public function get backBufferWidth() : uint
        {
            return m_BackBufferWidth;
        }

        public function set backBufferWidth( value : uint ) : void
        {
            if( value != m_BackBufferWidth )
            {
                m_BackBufferWidth = value;
                m_BackBufferDirty = true;
            }
        }

        public function get backBufferHeight() : uint
        {
            return m_BackBufferHeight;
        }

        public function set backBufferHeight( value : uint ) : void
        {
            if( value != m_BackBufferHeight )
            {
                m_BackBufferHeight = value;
                m_BackBufferDirty = true;
            }
        }

        public function get antiAlias() : uint
        {
            return m_AntiAliasing;
        }

        public function set antiAlias( antiAlias : uint ) : void
        {
            m_AntiAliasing = antiAlias;
            m_BackBufferDirty = true;
        }

        public function get shareContext() : Boolean
        {
            return m_ShareContext;
        }

        public function get driverInfo() : String
        {
            return m_DriverInfo;
        }

        public function get contextValid() : Boolean
        {
            return m_Context && m_Context.driverInfo != "Disposed";
        }

        public function get handleLostContext() : Boolean
        {
            return m_HandleLostContext;
        }

        public function set handleLostContext( value : Boolean ) : void
        {
            m_HandleLostContext = value;
        }

        public function set backGroundColor( value : uint ) : void
        {
            m_ClearRed = ( ( value & 0xff000000 ) >> 24 ) / 255;
            m_ClearGreen = ( ( value & 0x00ff0000 ) >> 16 ) / 255;
            m_ClearBlue = ( ( value & 0x0000ff00 ) >> 8 ) / 255;
            m_ClearAlpha = ( ( value & 0xff ) ) / 255;
        }

        [Inline]
        final public function get vx() : int
        { return m_ViewportX; }

        [Inline]
        final public function get vy() : int
        { return m_ViewportY; }

        [Inline]
        final public function get vw() : int
        { return m_BackBufferWidth; }

        [Inline]
        final public function get vh() : int
        { return m_BackBufferHeight; }

        public function get contentScaleFactor() : Number
        {
            return 1.0;
            //return (m_BackBufferWidth * 1.0 ) / m_NativeStage.stageWidth;
        }

        public function dispose() : void
        {
            m_NativeStage.removeChild( m_NativeOverlay );
            m_Stage3D.removeEventListener( Event.CONTEXT3D_CREATE, onContextCreated, false );
            m_Stage3D.removeEventListener( ErrorEvent.ERROR, onStage3DError, false );

            if( m_Context && !m_ShareContext )
            {
                // Per default, the context is recreated as long as there are listeners on it.
                // Beginning with AIR 3.6, we can avoid that with an additional parameter.
                var disposeContext3D : Function = m_Context.dispose;
                if( disposeContext3D.length == 1 ) disposeContext3D( false );
                else disposeContext3D();
            }

            m_Profile = null;
            m_Profiles.fixed = false;
            m_Profiles.length = 0;
            m_Profiles = null;

            m_DriverInfo = null;
            m_RenderMode = null;

            m_ShareContext = false;

            m_Stage3D = null;
            m_NativeStage = null;
            m_NativeOverlay = null;

            var i : int = 0;
            var len : int = m_RenderTargetStack.length;
            while( i < len )
            {
                m_RenderTargetStack[ i ].dispose();
                m_RenderTargetStack[ i ] = null;
                ++i;
            }
            m_RenderTargetStack.fixed = false;
            m_RenderTargetStack.length = 0;
            m_RenderTargetStack = null;

            i = 0;
            len = m_TextureSlotStack.length;
            while( i < len )
            {
                m_TextureSlotStack[ i ].dispose();
                m_TextureSlotStack[ i ] = null;
                ++i;
            }
            m_TextureSlotStack.fixed = false;
            m_TextureSlotStack.length = 0;
            m_TextureSlotStack = null;

            for each ( var program : Program3D in m_mapShaderPrograms )
            {
                program.dispose();
                program = null;
            }
            m_mapShaderPrograms.clear();
            m_mapShaderPrograms = null;

            RenderDeviceManager.getInstance()._removeRenderDevice( m_Index );
        }

        public function setBackGroundColor( red : Number, green : Number, blue : Number, alpha : Number ) : void
        {
            m_ClearRed = red;
            m_ClearGreen = green;
            m_ClearBlue = blue;
            m_ClearAlpha = alpha;
        }

        public function setViewport( x : Number, y : Number, width : int, height : int ) : void
        {
            if( m_ViewportX != x || m_ViewportY != y )
            {
                m_ViewportX = x;
                m_ViewportY = y;
                m_ViewportDirty = true;
                m_PendingFilter |= PENDING_VIEWPORT;
            }

            backBufferWidth = width;
            backBufferHeight = height;

            if( m_BackBufferDirty ) m_PendingFilter |= PENDING_VIEWPORT;
        }

        public function pushRenderTarget( target : Texture, antiAliasing : int = 0 ) : void
        {
            m_RenderTargetStack.push( new RenderTargetInfo( target, antiAliasing ) );
            setRenderToTexture( target.base, antiAliasing );
        }

        public function popRenderTarget() : void
        {
            m_RenderTargetStack.pop();
            if( m_RenderTargetStack.length > 0 )
            {
                var renderTargetInfo : RenderTargetInfo = m_RenderTargetStack[ m_RenderTargetStack.length - 1 ];
                setRenderToTexture( renderTargetInfo.texture.base, renderTargetInfo.enableDepthAndStencil, renderTargetInfo.antiAliasing );
            }
            else
            {
                setRenderToBackBuffer();
            }
        }

        public function updateBackBuffer() : void
        {
            if( contextValid && m_BackBufferDirty )
            {
                m_Context.configureBackBuffer( m_BackBufferWidth, m_BackBufferHeight, m_AntiAliasing );
                m_BackBufferDirty = false;
            }
        }

        public function findShaderProgram( name : Number ) : Program3D
        {
            return m_mapShaderPrograms.find( name );
        }

        public function createShaderProgram( programName : Number, vsName : String, fsName : String, vsCode : String, fsCode : String, texCount : int, texFlagList : Vector.<String> ) : Program3D
        {
            var i : int;
            for( i = 0; i < texCount; ++i )
            {
                fsCode = fsCode.replace( new RegExp( "fs" + i, "g" ), "fs" + i + " " + texFlagList[ i ] );
            }

            var vPattern : RegExp = /v([0-7]{1})/gi;
            var vFlagVertex : uint = calcFlag( vPattern, vsCode );
            var vFlagFragment : uint = calcFlag( vPattern, fsCode );

            if( vFlagVertex != vFlagFragment )
            {
                throw new Error( "can not compile shader program since vertex shader: "
                        + vsName + "[" + vFlagVertex +
                        "] and fragment shader: "
                        + fsName + "[" + vFlagFragment + "] is not matched!" );
            }

            var programe : Program3D = createProgram();
            if( programe != null )
            {
                assembleAgal( vsCode, fsCode, programe );
                m_mapShaderPrograms.add( programName, programe );
                return programe;
            }

            throw new Error( "[QRenderer] [CRenderDevice] failed to create shader program, check it! " );
        }

        public function bindShaderProgram( pProgram : Program3D ) : void
        {
            if( pProgram == null ) return;

            m_bUseDiffProgram = m_pLastProgram != pProgram;
            if( m_bUseDiffProgram )
            {
                m_Context.setProgram( pProgram );
                m_pLastProgram = pProgram;

                /** when program3D has changed, clear texture slots **/
                clearTexturesSlot();
            }
        }

        /*others*/

        public function bindShaderProgramByName( name : Number ) : void
        {
            var pProgram : Program3D = m_mapShaderPrograms.find( name );
            bindShaderProgram( pProgram );
        }

        public function destroyProgram( name : Number ) : void
        {
            var program : Program3D = m_mapShaderPrograms.find( name );
            program.dispose();
            m_mapShaderPrograms.remove( name );
        }

        /**
         * texture
         * */
        public function createTexture( width : int, height : int, format : String, optimizeForRenderToTexture : Boolean, streamingLevels : int = 0 ) : flash.display3D.textures.Texture
        {
            return m_Context.createTexture( width, height, format, optimizeForRenderToTexture, streamingLevels );
        }

        public function uploadTextureData() : void
        {

        }

        public function calcTextureSize() : uint
        {
            return 0;
        }

        public function createRectangleTexture( width : int, height : int, format : String, optimizeForRenderToTexture : Boolean ) : TextureBase
        {
            return m_Context[ "createRectangleTexture" ]( width, height, format, optimizeForRenderToTexture );
        }

        /**
         * vertex buffer manage
         */
        public function createVertexBuffer( numVertices : int, data32PerVertex : int, bufferUsage : String = "staticDraw" ) : VertexBuffer3D
        {
            ++sVertexBufferCount;
            return m_Context.createVertexBuffer( numVertices, data32PerVertex, bufferUsage );
        }

        public function uploadVertexBufferData( vertexBuffer : VertexBuffer3D, data : Vector.<Number>, startOffset : int, count : int ) : void
        {
            vertexBuffer.uploadFromVector( data, startOffset, count );
        }

        public function uploadVertexBufferBytes( vertexBuffer : VertexBuffer3D, data : ByteArray, byteArrayOffset : int, startVertex : int, numVertices : int ) : void
        {
            vertexBuffer.uploadFromByteArray( data, byteArrayOffset, startVertex, numVertices );
        }

        public function destroyVertexBuffer( vertexBuffer : VertexBuffer3D ) : void
        {
            if( null == vertexBuffer )
            {
                return;
            }

            --sVertexBufferCount;
            vertexBuffer.dispose();
            vertexBuffer = null;
        }

        /**
         * index buffer manage
         */
        public function createIndexBuffer( numIndices : int, bufferUsage : String = "staticDraw" ) : IndexBuffer3D
        {
            ++sIndexBufferCount;
            return m_Context.createIndexBuffer( numIndices, bufferUsage );
        }

        public function uploadIndexBufferData( indexBuffer : IndexBuffer3D, data : Vector.<uint>, startOffset : int, count : int ) : void
        {
            indexBuffer.uploadFromVector( data, startOffset, count );
        }

        public function destroyIndexBuffer( indexBuffer : IndexBuffer3D ) : void
        {
            if( null == indexBuffer )
            {
                return;
            }

            --sIndexBufferCount;
            indexBuffer.dispose();
            indexBuffer = null;
        }

        /**
         * shaders
         * */
        public function createProgram() : Program3D
        {
            return m_Context.createProgram();
        }

        public function setProgram( program : Program3D ) : void
        {
            m_Context.setProgram( program );
        }

        public function setProgramConstantsFromMatrix( programType : String, firstRegister : int, matrix : Matrix3D, transposedMatrix : Boolean = false ) : void
        {
            m_Context.setProgramConstantsFromMatrix( programType, firstRegister, matrix, transposedMatrix );
        }

        public function setProgramConstantsFromVector( programType : String, firstRegister : int, data : Vector.<Number>, numRegisters : int = -1 ) : void
        {
            m_Context.setProgramConstantsFromVector( programType, firstRegister, data, numRegisters );
        }

        /**
         * render commands, eg.set***()
         * */
        public function setColorMask( red : Boolean, green : Boolean, blue : Boolean, alpha : Boolean ) : void
        {
            var clearMask : int = ( red ? 1 : 0 ) << 3;
            clearMask |= ( ( green ? 1 : 0 ) << 2 );
            clearMask |= ( ( blue ? 1 : 0 ) << 1 );
            clearMask |= ( alpha ? 1 : 0 );

            if( ( m_NewRasterState.clearMask & clearMask ) != 0 ) return;

            m_NewRasterState.clearMask |= clearMask;
            m_PendingFilter |= PENDING_RENDERSTATE;
        }

        public function setDepthTest( depthMask : Boolean, passCompareMode : String ) : void
        {
            var result : Boolean = ( depthMask == m_NewDepthStencilState.enableDepthTest ) &&
                    ( passCompareMode == m_NewDepthStencilState.depthTestFunc );
            if( result ) return;

            m_NewDepthStencilState.enableDepthTest = depthMask;
            m_NewDepthStencilState.depthTestFunc = passCompareMode;
            m_PendingFilter |= PENDING_RENDERSTATE;
        }

        public function setCullingMode( triangleFaceToCull : String ) : void
        {
            if( m_NewRasterState.cullingMode == triangleFaceToCull ) return;

            m_NewRasterState.cullingMode = triangleFaceToCull;
            m_PendingFilter |= PENDING_RENDERSTATE;
        }

        public function setStencilActions( triangleFace : String = "frontAndBack", compareMode : String = "always", actionOnBothPass : String = "keep",
                                           actionOnDepthFail : String = "keep", actionOnDepthPassStencilFail : String = "keep" ) : void
        {

        }

        public function setStencilReferenceValue( referenceValue : uint, readMask : uint = 255, writeMask : uint = 255 ) : void
        {
            m_ReferenceStencil = referenceValue;
            m_StencilReadMask = readMask;
            m_StencilWriteMask = writeMask;
            m_PendingFilter |= PENDING_RENDERSTATE;
        }

        public function setTextureBase( slot : uint, texture : TextureBase ) : void
        {
            m_Context.setTextureAt( slot, texture );
        }

        public function setTexture( slot : uint, texture : Texture ) : void
        {
            if( slot > m_UsedTextureSlotCount )
                Foundation.Log.logErrorMsg( "please check it, you should use the fs" + m_UsedTextureSlotCount + " first!" );

            var wrapMode : String = texture.repeat ? "repeat" : "clamp";
            var filter : String = Context3DTextureFilter.LINEAR;
            var mipFilter : String = texture.mipMapping ? Context3DMipFilter.MIPLINEAR : Context3DMipFilter.MIPNONE;

            m_TextureSlotStack[ slot ].texture = texture.base;
            m_TextureSlotStack[ slot ].newSampleState.wrapMode = wrapMode;
            m_TextureSlotStack[ slot ].newSampleState.filter = filter;
            m_TextureSlotStack[ slot ].newSampleState.mipFilter = mipFilter;

            if( m_bUseDiffProgram )
                m_UsedTextureSlotCount++;

            m_PendingFilter |= PENDING_TEXTURES;
        }

        public function clearTexturesSlot() : void
        {
            var i : int = 0;
            while( i < m_UsedTextureSlotCount )
            {
                m_Context.setTextureAt( i, null );
                ++i;
            }
            m_UsedTextureSlotCount = 0;
        }

        public function setSamplerStateAt( sampler : int, wrap : String, filter : String, mipfilter : String ) : void
        {
            if( sampler >= m_UsedTextureSlotCount )
            {
                Foundation.Log.logErrorMsg( "Please set texture first!" );
                return;
            }

            m_TextureSlotStack[ sampler ].newSampleState.wrapMode = wrap;
            m_TextureSlotStack[ sampler ].newSampleState.filter = filter;
            m_TextureSlotStack[ sampler ].newSampleState.mipFilter = mipfilter;

            m_PendingFilter |= PENDING_TEXTURES;
        }

        public function setBlendFactors( sourceFactor : String, destinationFactor : String ) : void
        {
            var result : Boolean = ( sourceFactor == m_NewBlendState.srcBlendFunc ) &&
                    ( destinationFactor == m_NewBlendState.dstBlendFunc );
            if( result ) return;

            m_NewBlendState.srcBlendFunc = sourceFactor;
            m_NewBlendState.dstBlendFunc = destinationFactor;

            m_PendingFilter |= PENDING_RENDERSTATE;
        }

        public function setScissorRectangle( rectangle : Rectangle ) : void
        {
            if( m_ScissorRect.equals( rectangle ) )
            {
                m_ScissorRect = rectangle;
                return;
            }
            m_PendingFilter |= PENDING_SCISSSOR;
        }

        public function setRenderToTexture( texture : TextureBase, enableDepthAndStencil : Boolean = false, antiAlias : int = 0, surfaceSelector : int = 0, colorOutputIndex : int = 0 ) : void
        {
            m_Context.setRenderToTexture( texture, enableDepthAndStencil, antiAlias, surfaceSelector, colorOutputIndex );
        }

        public function setRenderToBackBuffer() : void
        {
            m_Context.setRenderToBackBuffer();
        }

        public function setVertexBuffer( index : uint, buffer : VertexBuffer3D, offset : uint, format : String ) : void
        {
            m_Context.setVertexBufferAt( index, buffer, offset, format );
        }

        public function clearVertexBuffer( index : uint ) : void
        {
            m_Context.setVertexBufferAt( index, null );
        }

        public function present() : void
        {
            m_Context.present();
        }

        /**
         * draw call & clear
         */
        public function setClearColorAndMask( red : Number = 0.0, green : Number = 0.0, blue : Number = 0.0, alpha : Number = 1.0, depth : Number = 1.0, stencil : uint = 0, mask : uint = 0xffffffff ) : void
        {
            var result : Boolean = ( red == m_ClearRed ) &&
                    ( green == m_ClearGreen ) &&
                    ( blue == m_ClearBlue ) &&
                    ( alpha == m_ClearAlpha  ) &&
                    ( depth == m_ReferenceDepth ) &&
                    ( stencil == m_ReferenceStencil ) &&
                    ( mask == m_NewRasterState.clearMask );
            if( result ) return;

            m_ClearRed = red;
            m_ClearGreen = green;
            m_ClearBlue = blue;
            m_ClearAlpha = alpha;
            m_ReferenceDepth = depth;
            m_ReferenceStencil = stencil;

            m_NewRasterState.clearMask = mask;
            m_PendingFilter |= PENDING_RENDERSTATE;
        }

        public function clear() : void
        {
            m_Context.clear( m_ClearRed, m_ClearGreen, m_ClearBlue, m_ClearAlpha, m_ReferenceDepth, m_ReferenceStencil, Context3DClearMask.ALL );
        }

        public function drawTriangles( indexBuffer : IndexBuffer3D, index : int, numTriangles : int ) : void
        {
            m_Context.drawTriangles( indexBuffer, index, numTriangles );
        }

        public function isProfileBaselineConstrained() : Boolean
        {
            return m_Profile == "baselineConstrained";
        }

        public function isCreateRectangleTextureInContext() : Boolean
        {
            return "createRectangleTexture" in m_Context;
        }

        public function drawToBitmapData( destination : BitmapData ) : void
        {
            m_Context.drawToBitmapData( destination );
        }

        public function commitStates( filter : uint = 63 ) : void
        {
            var result : uint = m_PendingFilter & filter;
            if( result > 0 )
            {
                //set viewport
                if( ( result & PENDING_VIEWPORT ) > 0 )
                {
                    if( m_ViewportDirty )
                    {
                        m_Stage3D.x = m_ViewportX;
                        m_Stage3D.y = m_ViewportY;
                        m_ViewportDirty = false;
                    }
                    updateBackBuffer();
                    m_PendingFilter &= ~PENDING_VIEWPORT;
                }

                //bind index buffer

                //bind vertes buffer

                //bind texture
                if( ( result & PENDING_TEXTURES ) > 0 )
                {
                    applySampleState();
                    m_PendingFilter &= ~PENDING_TEXTURES;
                }

                //set scissor test
                if( ( result & PENDING_SCISSSOR ) > 0 )
                {
                    m_Context.setScissorRectangle( m_ScissorRect );
                    m_PendingFilter &= ~PENDING_SCISSSOR;
                }

                //render state
                if( ( result & PENDING_RENDERSTATE ) > 0 )
                {
                    applyRenderState();
                    m_PendingFilter &= ~PENDING_RENDERSTATE;
                }
            }
        }

        private function calcFlag( pattern : RegExp, shaderCode : String ) : uint
        {
            var flag : uint = 0;
            var result : Object = pattern.exec( shaderCode );
            while( result != null )
            {
                flag |= (1 << int( result[ 1 ] ));
                result = pattern.exec( shaderCode );
            }

            return flag;
        }

        private function initialize( stage : Stage, stage3D : Stage3D ) : void
        {
            if( stage == null ) throw new ArgumentError( "Stage must not be null" );
            if( stage3D == null ) stage3D = stage.stage3Ds[ 0 ];

            SystemUtil.initialize();

            m_NativeStage = stage;
            m_NativeOverlay = new Sprite();
            m_NativeStage.addChild( m_NativeOverlay );
            m_Stage3D = stage3D;

            //set back buffer width/height
            m_BackBufferWidth = stage.width;
            m_BackBufferHeight = stage.height;

            // all other modes are problematic, so we force those here
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            // register other event handlers
            m_Stage3D.addEventListener( Event.CONTEXT3D_CREATE, onContextCreated, false, 10, true );
            m_Stage3D.addEventListener( ErrorEvent.ERROR, onStage3DError, false, 10, true );

            if( m_Stage3D.context3D && m_Stage3D.context3D.driverInfo != "Disposed" )
            {
                if( m_Profile == "auto" || m_Profile is Array || m_Profile is Vector.<String> )
                    throw new ArgumentError( "When sharing the context3D, the actual profile has " +
                            "to be passed as last argument to constuctor" );

                m_ShareContext = true;
                setTimeout( initializeGraphicsAPI, 1 ); // we don't call it right away, because qrenderer should
                // behave the same way with or without a shared context
            }
            else
            {
                m_ShareContext = false;
                requestContext3D( stage3D, m_RenderMode, m_Profile );
            }
        }

        private function initializeGraphicsAPI() : void
        {
            RenderDeviceManager.getInstance().makeCurrent( this );

            m_Context = m_Stage3D.context3D;
            m_Context.enableErrorChecking = true;
            m_DriverInfo = m_Context.driverInfo;

            var str : String = m_DriverInfo.toLocaleLowerCase();
            m_IsOpenGL = ( str.indexOf( "opengl" ) > -1 );

            if( m_Profile == null )
                m_Profile = m_Context[ "profile" ];

            //configure the back buffer
            updateBackBuffer();

            trace( "[QRenderer] Initialization complete." );
            trace( "[QRenderer] Display Driver:", m_DriverInfo );
        }

        private function requestContext3D( stage3D : Stage3D, renderMode : String, profile : Object ) : void
        {
            var profiles : Vector.<String>;

            if( profile == "auto" )
                profiles = AVAILABLE_PROFILES.slice();
            else if( profile is String )
                profiles = new <String>[ profile as String ];
            else if( profile is Vector.<String> )
                profiles = profile as Vector.<String>;
            else if( profile is Array )
            {
                profiles = new <String>[];

                for( var i : int = 0; i < profile.length; ++i )
                    profiles[ i ] = profile[ i ];
            }
            else
            {
                throw new ArgumentError( "Profile must be of type 'String', 'Array', " +
                        "or 'Vector.<String>'" );
            }

            m_Profiles = profiles;
            m_RenderMode = renderMode;

            // sort profiles descending
            profiles.sort( compareProfiles );

            function compareProfiles( a : String, b : String ) : int
            {
                var indexA : int = AVAILABLE_PROFILES.indexOf( a );
                var indexB : int = AVAILABLE_PROFILES.indexOf( b );

                if( indexA < indexB ) return -1;
                else if( indexA > indexB ) return 1;
                else return 0;
            }

            requestNextProfile();
        }

        private function requestNextProfile() : void
        {
            // pull off the next profile and try to init Stage3D with it
            m_Profile = m_Profiles.shift();

            try
            {
                m_Stage3D.requestContext3D( m_RenderMode, m_Profile );
            }
            catch( e : Error )
            {
                if( m_Profiles.length > 0 )
                {
                    // try again next frame
                    setTimeout( requestNextProfile, 1 );
                }
                else
                {
                    showFatalError( "Context3D error: " + e.message );
                }
            }
        }

        private function showFatalError( message : String ) : void
        {
            var textField : TextField = new TextField();
            var textFormat : TextFormat = new TextFormat( "Verdana", 12, 0xFFFFFF );
            textFormat.align = TextFormatAlign.CENTER;
            textField.defaultTextFormat = textFormat;
            textField.wordWrap = true;
            textField.width = m_NativeStage.stageWidth * 0.75;
            textField.autoSize = TextFieldAutoSize.CENTER;
            textField.text = message;
            textField.x = (m_NativeStage.stageWidth - textField.width) / 2;
            textField.y = (m_NativeStage.stageHeight - textField.height) / 2;
            textField.background = true;
            textField.backgroundColor = 0x440000;
            m_NativeOverlay.addChild( textField );
        }

        private function applyRenderState() : void
        {
            //raster state
            if( !compareRasterState() )
            {
                m_CurRasterState.copy( m_NewRasterState );
                m_Context.setCulling( m_CurRasterState.cullingMode );
                m_Context.clear( m_ClearRed, m_ClearGreen, m_ClearBlue, m_ClearAlpha, m_ReferenceDepth, m_ReferenceStencil, m_CurRasterState.clearMask );
            }
            //blend state
            if( !compareBlendState() )
            {
                m_CurBlendState.copy( m_NewBlendState );
                m_Context.setBlendFactors( m_CurBlendState.srcBlendFunc, m_CurBlendState.dstBlendFunc );
            }
            //depth and stencil state
            if( !compareDepthStencilState() )
            {
                m_CurDepthStencilState.copy( m_NewDepthStencilState );
                m_Context.setDepthTest( m_CurDepthStencilState.enableDepthTest, m_CurDepthStencilState.depthTestFunc );
                //m_Context.setStencilActions ();
            }
        }

        private function applySampleState() : void
        {
            var textureSlot : TextureSlot = null;
            var i : int = 0;
            while( i < m_UsedTextureSlotCount )
            {
                textureSlot = m_TextureSlotStack[ i ];
                m_Context.setTextureAt( i, textureSlot.texture );

                if( !compareSampleState( textureSlot.curSampleState, textureSlot.newSampleState ) )
                {
                    if( textureSlot.curSampleState == null ) textureSlot.curSampleState = new SampleState();
                    textureSlot.curSampleState.copy( textureSlot.newSampleState );
                    m_Context.setSamplerStateAt( i, textureSlot.curSampleState.wrapMode, textureSlot.curSampleState.filter, textureSlot.curSampleState.mipFilter );
                }
                ++i;
            }
        }

        private function compareRasterState() : Boolean
        {
            if( m_CurRasterState == null )
            {
                m_CurRasterState = new RasterState();
                return false;
            }

            var result : Boolean = m_CurRasterState.clearMask == m_NewRasterState.clearMask;
            result = result && ( m_CurRasterState.cullingMode == m_NewRasterState.cullingMode );
            result = result && ( m_CurRasterState.fillMode == m_NewRasterState.fillMode );

            return result;
        }

        private function compareBlendState() : Boolean
        {
            if( m_CurBlendState == null )
            {
                m_CurBlendState = new BlendState();
                return false;
            }

            var result : Boolean = ( m_CurBlendState.srcBlendFunc == m_NewBlendState.srcBlendFunc );
            result = result && ( m_CurBlendState.dstBlendFunc == m_NewBlendState.dstBlendFunc );

            return result;
        }

        private function compareDepthStencilState() : Boolean
        {
            if( m_CurDepthStencilState == null )
            {
                m_CurDepthStencilState = new DepthStencilState();
                return false;
            }

            var result : Boolean = ( m_CurDepthStencilState.enableDepthTest == m_NewDepthStencilState.enableDepthTest );
            result = result && ( m_CurDepthStencilState.depthTestFunc == m_NewDepthStencilState.depthTestFunc );
            result = result && ( m_CurDepthStencilState.stencilTestAction == m_NewDepthStencilState.stencilTestAction );

            return result;
        }

        private function compareSampleState( curState : SampleState, newState : SampleState ) : Boolean
        {
            if( curState == null )
                return false;

            var result : Boolean = ( curState.wrapMode == newState.wrapMode );
            result = result && ( curState.filter == newState.filter );
            result = result && ( curState.mipFilter == newState.mipFilter );

            return result;
        }

        private function onContextCreated( event : Event ) : void
        {
            if( m_Stage3D.context3D )
            {
                m_IsSoftwareMode = m_Stage3D.context3D.driverInfo.toLowerCase().indexOf( "software" ) >= 0;
                if( m_IsSoftwareMode && m_Profiles.length > 0 )
                {
                    // don't settle for software mode if there are more hardware profiles to try
                    setTimeout( requestNextProfile, 1 );
                    return;
                }

                if( !m_HandleLostContext && m_Context )
                {
                    showFatalError( "Fatal error: The application lost the device context!" );
                    trace( "[QRenderer] The device context was lost. " +
                            "Enable 'QRenderer.handleLostContext' to avoid this error." );
                }
                else
                {
                    //if device lost, it will recreate defaultly
                    initializeGraphicsAPI();
                }

                //TODO: Dispatch QRenderer Event CONTEXT3D_CREATED
                dispatchEvent( new RendererEvent( RendererEvent.CONTEXT3D_CREATED ) );
            }
            else
            {
                throw new Error( "Rendering context lost!" );
            }
        }

        private function onStage3DError( event : ErrorEvent ) : void
        {
            if( m_Profiles.length > 0 )
            {
                setTimeout( requestNextProfile, 1 );
                return;
            }

            if( event.errorID == 3702 )
            {
                var mode : String = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
                showFatalError( "Context3D not available! Possible reasons: wrong " + mode +
                        " or missing device support." );
            }
            else
                showFatalError( "Stage3D error: " + event.text );
        }
    }
}

import QFLib.Interface.IDisposable;
import QFLib.QEngine.Renderer.Textures.Texture;

class RenderTargetInfo implements IDisposable
{
    public var texture : Texture;
    public var antiAliasing : int;
    public var enableDepthAndStencil : Boolean = false;

    public function RenderTargetInfo( pTexture : Texture, antiAliasing : int, enableDepthAndStencil : Boolean = false )
    {
        this.texture = pTexture;
        this.antiAliasing = antiAliasing;
        this.enableDepthAndStencil = enableDepthAndStencil;
    }

    public function dispose() : void
    {
        texture = null;
    }
}