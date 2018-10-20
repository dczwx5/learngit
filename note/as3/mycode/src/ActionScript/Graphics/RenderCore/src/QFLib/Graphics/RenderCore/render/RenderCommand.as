package QFLib.Graphics.RenderCore.render
{

    import QFLib.Foundation;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.MatrixUtil;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;

    import flash.geom.Matrix;
    import flash.geom.Matrix3D;

    public class RenderCommand
    {
        private var _matrixWorld3D : Matrix3D;
        private var _matrixWorld2D : Matrix;
        //XXX:残影需要，这种实现后面有时间需优化，残影节点仍会丢失一些材质信息
        private var _pMainTexture : Texture = null;
        private var _pGeometry : IGeometry;
        private var _pMaterial : IMaterial;
        private var _pCamera : ICamera;

        private static var _commandVector : Vector.<RenderCommand> = new Vector.<RenderCommand> ();
        private static var _usingCmdCount : int = 0;
        private static var _clearTick : int = 0;

        static public function assign ( value : Matrix = null ) : RenderCommand
        {
            var cmd : RenderCommand = null;
            var length : int = _commandVector.length;
            if ( length > 0 )
            {
                cmd = _commandVector.pop ();
                cmd.matWorld2D = value;
            }
            else
            {
                var expansion : int =  _usingCmdCount * 1.5;
                for ( var i : int = 0; i < expansion - 1; i++ )
                {
                    _commandVector.push ( new RenderCommand() );
                }
                cmd = new RenderCommand ();
                cmd.matWorld2D = value;
            }

            ++_usingCmdCount;

            return cmd;
        }

        static public function recycle ( cmd : RenderCommand ) : void
        {
            if ( cmd == null )
            {
                Foundation.Log.logWarningMsg ( "the recycled render command equals to null, please check it!" );
                return;
            }

            cmd.reset ();
            _commandVector.push ( cmd );
            --_usingCmdCount;
        }

        static public function clearCommands () : void
        {
            if ( ++_clearTick > 600 )
            {
                var length : int = _commandVector.length;
                var mul : Number = length / _usingCmdCount;
                if ( length > 30 && mul > 0.5 )
                {
                    var deleteIndex : int = _usingCmdCount * 0.5;
                    var deleteCount : int = length - deleteIndex + 1;
                    _commandVector.splice ( deleteIndex, deleteCount );
                }
                _clearTick = 0;
            }
        }

        public function RenderCommand ()
        {
            _matrixWorld3D = new Matrix3D ();
            reset ();
        }

        [Inline]
        public function get valid () : Boolean { return _pGeometry && _pMaterial; }

        [Inline]
        public function get geometry () : IGeometry { return _pGeometry; }
        [Inline]
        public function set geometry ( value : IGeometry ) : void { _pGeometry = value; }

        [Inline]
        public function get material () : IMaterial { return _pMaterial; }
        [Inline]
        public function set material ( value : IMaterial ) : void { _pMaterial = value; }

        //XXX:残影需要，需改进，残影仍会丢失掉部分的材质信息
        [Inline]
        public function get mainTexture () : Texture { return _pMainTexture; }
        [Inline]
        public function set mainTexture ( value : Texture ) : void { _pMainTexture = value; }

        [Inline]
        public function get matWorld3D () : Matrix3D { return _matrixWorld3D; }
        [Inline]
        public function get matWorld2D () : Matrix { return _matrixWorld2D; }
        public function set matWorld2D ( value : Matrix ) : void
        {
            _matrixWorld2D = value;
            if ( value )
            {
                MatrixUtil.convertTo3D ( value, _matrixWorld3D );
            }
        }

        [Inline]
        public function set camera ( pCamera : ICamera ) : void { _pCamera = pCamera; }
        [Inline]
        public function get camera () : ICamera { return _pCamera; }

        public function reset () : void
        {
            _pGeometry = null;
            _pMaterial = null;
            _pMainTexture = null;
            _matrixWorld2D = null;
            _matrixWorld3D.identity ();
        }
    }
}