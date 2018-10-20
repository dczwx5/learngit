package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Foundation;
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class MaterialBase
    {
        protected var _passes : Vector.<IPass> = null;
        protected var _mainTexture : Texture = null;
        protected var _parentAlpha : Number = 1.0;
        protected var _selfAlpha : Number = 1.0;
        protected var _premultiplyAlpha : Boolean = false;
        protected var _useNormal : Boolean = false;

        public function MaterialBase ( passCount : int )
        {
            _passes = new Vector.<IPass> ( passCount );
        }

        public function dispose () : void
        {
            for each ( var pass : IPass in _passes )
            {
                if ( pass == null ) continue;
                pass.dispose ();
                pass = null;
            }
            _passes.fixed = false;
            _passes.length = 0;
            _passes.fixed = true;
            _passes = null;

            _mainTexture = null;
        }

        [Inline] public function get passes () : Vector.<IPass> { return _passes; }

        [Inline] public function get pma () : Boolean { return _premultiplyAlpha; }
        [Inline] public function set pma ( value : Boolean ) : void { _premultiplyAlpha = value; }

        [Inline] public function get alpha () : Number { return _selfAlpha * _parentAlpha; }
        [Inline] public function get selfAlpha () : Number { return _selfAlpha * _parentAlpha; }
        [Inline] public function set selfAlpha ( value : Number ) : void { _selfAlpha = value; }
        [Inline] public function get parentAlpha () : Number { return _parentAlpha; }
        [Inline] public function set parentAlpha ( value : Number ) : void { _parentAlpha = value; }

        [Inline] public function set mainTexture ( value : Texture ) : void { _mainTexture = value; }
        [Inline] public function get mainTexture () : Texture { return _mainTexture; }

        [Inline] public function get useTexcoord () : Boolean { return mainTexture != null; }
        [Inline] public function get useColor () : Boolean { return true; }
        [Inline] public function get useNormal () : Boolean { return false; }

        public function addPass ( name : String, className : Class, enable : Boolean = true, disableOthers : Boolean = false, ...args ) : IPass
        {
            var pass : IPass = findPass ( name );
            if ( pass == null )
            {
                pass = new className ( args );
                pass.mainTexture = _mainTexture;
                var len : int = _passes.length;
                _passes.fixed = false;
                _passes.length += 1;
                _passes[ len ] = pass;
                _passes.fixed = true;
            }

            if ( disableOthers )
                setAllPassEnable ( false );
            pass.enable = enable;
            return pass;
        }

        public function setPassEnable ( passName : String, enable : Boolean = true, disableOthers : Boolean = false ) : Boolean
        {
            if ( disableOthers )
                setAllPassEnable ( false );

            var pass : IPass = findPass ( passName );
            if ( pass != null )
            {
                pass.enable = enable;
                return true;
            }
            else
            {
                Foundation.Log.logMsg ( "The material does not has the pass that named " + passName );
                return false;
            }
        }

        public function setAllPassEnable ( enable : Boolean = true ) : void
        {
            for each ( var pass : IPass in _passes )
            {
                if ( pass == null )
                    continue;
                pass.enable = enable;
            }
        }

        public function reset () : void {}
        public function update () : void {}

        protected function innerEqual ( other : MaterialBase ) : Boolean
        {
            if ( _passes.length != other.passes.length
                    || this.pma != other.pma
                    || this.parentAlpha != other.parentAlpha
                    || this.selfAlpha != other.selfAlpha )
            {
                return false;
            }

            for ( var i : int = 0, count : int = _passes.length; i < count; i++ )
            {
                if ( _passes[ i ] == null && other.passes[ i ] == null ) continue;
                if ( !_passes[ i ] || !_passes[ i ].equal ( other.passes[ i ] ) )
                    return false;
            }

            if ( this.mainTexture && other.mainTexture )
            {
                if ( this.mainTexture.base != other.mainTexture.base )
                    return false;
            }
            else if ( this.mainTexture || other.mainTexture )
            {
                return false;
            }
            return true;
        }

        private function findPass ( name : String ) : IPass
        {
            for each ( var pass : IPass in _passes )
            {
                if ( pass == null )
                    continue;
                if ( pass.name == name )
                    return pass;
            }
            return null;
        }
    }
}