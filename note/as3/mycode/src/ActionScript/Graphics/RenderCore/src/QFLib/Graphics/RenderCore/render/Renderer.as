package QFLib.Graphics.RenderCore.render
{
    import QFLib.Graphics.RenderCore.render.pass.PassBase;
    import QFLib.Graphics.RenderCore.render.shader.ShaderLib;
    import QFLib.Graphics.RenderCore.render.shader.VBase;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.errors.AbstractClassError;
    import QFLib.Graphics.RenderCore.starling.errors.MissingContextError;
    import QFLib.Graphics.RenderCore.starling.events.Event;

    import flash.display3D.Context3DProgramType;
    import flash.display3D.Program3D;
    import flash.geom.Matrix3D;
    import flash.utils.Dictionary;

    public class Renderer implements IRenderer
    {
        private static var sAssembler : AGALMiniAssembler = new AGALMiniAssembler ();

        private var _lastProgram : Program = null;
        private var _lastBlendMode : String = null;
        private var _lastBlendModePMA : Boolean = false;
        private var _lastSrcOp : String = null;
        private var _lastDstOp : String = null;

        private var _programs : Dictionary = new Dictionary ();

        private var _matrixHolder : PassBase;
        private var _matrixProj : Matrix3D = null;
        private var _matrixMVP : Matrix3D;

        private var _drawCount : int = 0;

        private var _cameras : Vector.<ICamera> = new <ICamera>[];
        private var _currentCamera : ICamera = null;
        private var _cameraDepthDirty : Boolean = true;

        public function Renderer ()
        {
            _matrixHolder = new PassBase ();
            _matrixMVP = _matrixHolder.createMatrix ( VBase.matrixMVP );
            Starling.current.addEventListener ( Event.CONTEXT3D_CREATE, onContextCreated );
        }

        public function dispose () : void
        {
            _lastProgram = null;
            _lastBlendMode = null;
            _lastSrcOp = null;
            _lastDstOp = null;
            _programs = null;

            if ( _matrixHolder != null )
            {
                _matrixHolder.dispose ();
                _matrixHolder = null;
            }

            _matrixProj = null;
            _matrixMVP = null;

            if ( _cameras != null )
            {
                _cameras.length = 0;
                _cameras = null;
            }
        }

        public function setCurrentCamera ( camera : ICamera ) : void
        {
            _currentCamera = camera;
            _matrixProj = camera.matrixProj;
            _matrixHolder.registerMatrix ( VBase.matrixProj, camera.matrixProj );
        }

        [Inline]
        public function getCurrentCamera () : ICamera { return _currentCamera; }

        // renderer接口
        public function render ( rcmd : RenderCommand ) : void
        {
            renderImmediatly ( rcmd );
        }

        public function get drawCount () : int
        {
            return _drawCount;
        }

        public function clearDrawCount () : void
        {
            _drawCount = 0;
        }

        public function clearCachedProgram () : void
        {
            if ( _lastProgram != null )
            {
                for ( var i : int = 0; i < _lastProgram.fragShader.textureLayout.length; ++i )
                {
                    Starling.current.setTexture ( _lastProgram.fragShader.textureLayout[ i ].index, null );
                }
            }
            _lastProgram = null;
        }

        public function clearCachedBlendMode () : void
        {
            this._lastSrcOp = null;
            this._lastDstOp = null;
            this._lastBlendMode = null;
        }

        public function get matrixProj () : Matrix3D
        {
            return _matrixProj;
        }

        private function renderImmediatly ( rcmd : RenderCommand ) : void
        {
            if ( rcmd == null || _currentCamera == null || !rcmd.valid )
            {
                RenderCommand.recycle ( rcmd );
                return;
            }

            renderObject ( rcmd );
            RenderCommand.recycle ( rcmd );
        }

        private function renderObject ( robj : RenderCommand ) : void
        {
            var pMaterial : IMaterial = robj.material;
            //XXX:残影特别实现，需改进优化，残影材质仍然会丢失部分信息
            if ( robj.mainTexture != null )
                pMaterial.mainTexture = robj.mainTexture;

            pMaterial.update ();
            var pSupport : RenderSupport = Starling.current.support;
            for ( var p : int = 0, count : int = pMaterial.passes.length; p < count; ++p )
            {
                var pass : IPass = pMaterial.passes[ p ];
                if ( pass == null || !pass.enable ) continue;

                //现在有可能乱入，这个不能延迟
                if ( pass.usingRTT )
                {
                    pSupport.pushRenderTarget ( pass.renderTarget );
                    if ( pass.isClearRT )
                    {
                        pSupport.clear ();
                    }
                }

                //渲染 pass
                renderPass ( robj, pass );

                if ( pass.usingRTT )
                {
                    pSupport.popRenderTarget ();
                }
            }
        }

        //实现
        private function renderPass ( robj : RenderCommand, pass : IPass ) : void
        {
            //设置shader和参数
            var vertShader : IVertexShader = ShaderLib.getVertex ( pass.vertexShader );
            var fragShader : IFragmentShader = ShaderLib.getFragment ( pass.fragmentShader );

            var numTexture : int = fragShader.textureLayout.length;
            var i : int = 0;

            var program : Program = getProgram ( pass );
            var instance : Starling = Starling.current;

            if ( _lastProgram != program )
            {
                if ( _lastProgram != null )
                {
                    // 关闭上次使用过的，本次不需要使用的texture slot
                    for ( i = 0; i < _lastProgram.fragShader.textureLayout.length; ++i )
                    {
                        instance.setTexture ( _lastProgram.fragShader.textureLayout[ i ].index, null );
                    }
                }

                _lastProgram = program;
                instance.setProgram ( program.program );
            }
            var blendMode : String = pass.blendMode;
            if ( blendMode == "custom" )
            {
                if ( _lastSrcOp != pass.srcOp
                        || _lastDstOp != pass.dstOp )
                {
                    _lastSrcOp = pass.srcOp;
                    _lastDstOp = pass.dstOp;
                    instance.setBlendFactors ( _lastSrcOp, _lastDstOp );
                }
                _lastBlendMode = null;
            }
            else
            {
                if ( _lastBlendMode != null || _lastBlendMode != blendMode || _lastBlendModePMA != pass.pma )
                {
                    _lastBlendMode = blendMode;
                    _lastBlendModePMA = pass.pma;
                    RenderSupport.setBlendFactors ( _lastBlendModePMA, _lastBlendMode );
                }
            }

            buildWorldMatrix ( robj );

            var paramCount : int = vertShader.paramLayout.length;
            var param : ParamConst;
            var matrix : Matrix3D;
            for ( i = 0; i < paramCount; ++i )
            {
                param = vertShader.paramLayout[ i ];
                if ( param.isMatrix )
                {
                    matrix = pass.getMatrix ( param.name );
                    if ( matrix == null )
                    {
                        matrix = _matrixHolder.getMatrix ( param.name );
                    }
                    instance.setProgramConstantsFromMatrix ( Context3DProgramType.VERTEX, param.index, matrix, param.transpose );
                }
                else
                {
                    instance.setProgramConstantsFromVector ( Context3DProgramType.VERTEX, param.index, pass.getVector ( param.name ) );
                }
            }

            paramCount = fragShader.paramLayout.length;
            for ( i = 0; i < paramCount; ++i )
            {
                param = fragShader.paramLayout[ i ];
                if ( param.isMatrix )
                {
                    matrix = pass.getMatrix ( param.name );
                    if ( matrix == null )
                    {
                        matrix = _matrixHolder.getMatrix ( param.name );
                    }
                    instance.setProgramConstantsFromMatrix ( Context3DProgramType.FRAGMENT, param.index, matrix, param.transpose );
                }
                else
                {
                    instance.setProgramConstantsFromVector ( Context3DProgramType.FRAGMENT, param.index, pass.getVector ( param.name ) );
                }
            }

            for ( i = 0; i < numTexture; ++i )
            {
                instance.setTexture ( i, pass.getTexture ( fragShader.textureLayout[ i ].name ).base );
            }

            robj.geometry.setVertexBuffers ();
            robj.geometry.draw ();
        }

        private function buildWorldMatrix ( robj : RenderCommand ) : void
        {
            _matrixHolder.registerMatrix ( VBase.matrixWorld, robj.matWorld3D );
            _matrixMVP.copyFrom ( robj.matWorld3D );
            _matrixMVP.append ( _matrixProj );
        }

        private function onContextCreated () : void
        {
            // program must be recompile after device lost
            _programs = new Dictionary ();
        }

        private function getProgram ( pass : IPass ) : Program
        {
            if ( pass.shaderName in _programs )
            {
                return _programs[ pass.shaderName ];
            }

            var vs : IVertexShader = ShaderLib.getVertex ( pass.vertexShader );
            var fs : IFragmentShader = ShaderLib.getFragment ( pass.fragmentShader );
            return compileShader ( vs, fs, pass.shaderName, pass.texFlagList );
        }

        private function compileShader ( vs : IVertexShader, fs : IFragmentShader, name : Number, texFlagList : Vector.<String> ) : Program
        {
            var i : int;
            var fsCode : String = fs.code;
            for ( i = 0; i < fs.textureLayout.length; ++i )
            {
                fsCode = fsCode.replace ( new RegExp ( "fs" + i, "g" ), "fs" + i + " " + texFlagList[ i ] );
            }

            var vsCode : String = vs.code;

            var vPattern : RegExp = /v([0-7]{1})/gi;
            var vFlagVertex : uint = calcFlag ( vPattern, vsCode );
            var vFlagFragment : uint = calcFlag ( vPattern, fsCode );
            if ( vFlagVertex != vFlagFragment )
            {
                throw new Error ( "can not compile shader program since vertex shader: "
                        + vs.name + "[" + vFlagVertex +
                        "] and fragment shader: "
                        + fs.name + "[" + vFlagFragment + "] is not matched!" );
                //return null;
            }

            var program : Program = new Program ();
            var program3D : Program3D = Starling.current.createProgram ();
            assembleAgal ( vsCode, fsCode, program3D );

            if ( program3D != null )
            {
                program.vertShader = vs;
                program.fragShader = fs;
                program.program = program3D;
                program.inFlag = calcFlag ( /va([0-7]{1})/gi, vsCode );
                _programs[ name ] = program;
                return program;
            }

            throw new Error ( "can not compile shader program from vertex shader: "
                    + vs.name + "[" + vFlagVertex +
                    "] and fragment shader: "
                    + fs.name + "[" + vFlagFragment + "]" );
            //return null;
        }

        private function calcFlag ( pattern : RegExp, shaderCode : String ) : uint
        {
            var flag : uint = 0;
            var result : Object = pattern.exec ( shaderCode );
            while ( result != null )
            {
                flag |= (1 << int ( result[ 1 ] ));
                result = pattern.exec ( shaderCode );
            }

            return flag;
        }

        /** Assembles fragment- and vertex-shaders, passed as Strings, to a Program3D. If you
         *  pass a 'resultProgram', it will be uploaded to that program; otherwise, a new program
         *  will be created on the current Stage3D context. */
        public static function assembleAgal ( vertexShader : String, fragmentShader : String,
                                              resultProgram : Program3D = null ) : Program3D
        {
            if ( resultProgram == null )
            {
                var instance : Starling = Starling.current;
                if ( !instance.contextValid ) throw new MissingContextError ();
                resultProgram = instance.createProgram ();
            }

            resultProgram.upload (
                    sAssembler.assemble ( Context3DProgramType.VERTEX, vertexShader ),
                    sAssembler.assemble ( Context3DProgramType.FRAGMENT, fragmentShader ) );

            return resultProgram;
        }

        public function addCamera ( camera : ICamera ) : void
        {
            var baseCamera : Camera = camera as Camera;

            if ( baseCamera == null )
            {
                throw new AbstractClassError ( "Camera must be inherite from QFLib.Graphics.RenderCore.render.Camera!" );
            }

            _cameraDepthDirty = true;
            baseCamera.setDepthChangeListener ( onCameraDepthChange );

            _cameras.push ( baseCamera );
        }

        public function removeCamera ( camera : ICamera ) : void
        {
            var index : int = _cameras.indexOf ( camera );
            (camera as Camera).setDepthChangeListener ( null );

            if ( index != -1 )
            {
                _cameras.splice ( index, 1 );
            }
        }

        public function getCameraList () : Vector.<ICamera>
        {
            if ( _cameraDepthDirty )
            {
                _cameras.sort ( onCameraSort );

                _cameraDepthDirty = false;
            }
            return _cameras;
        }

        private function onCameraSort( a : ICamera, b : ICamera ) : int
        {
            return a.depth - b.depth;
        }

        private function onCameraDepthChange () : void
        {
            _cameraDepthDirty = true;
        }
    }
}