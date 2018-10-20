package QFLib.Graphics.FX.effectsystem
{

	import QFLib.Foundation;
	import QFLib.Foundation.CPath;
	import QFLib.Graphics.FX.CFxAtlasInfo;
	import QFLib.Graphics.FX.effectsystem.keyFrame.KeyFrame;
	import QFLib.Graphics.RenderCore.CTextureAtlasLoader;
	import QFLib.Graphics.RenderCore.CTextureLoader;
	import QFLib.Graphics.RenderCore.render.ICuller;
	import QFLib.Graphics.RenderCore.render.IGeometry;
	import QFLib.Graphics.RenderCore.render.RenderCommand;
	import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
	import QFLib.Graphics.RenderCore.starling.core.Starling;
	import QFLib.Graphics.RenderCore.starling.core.StaticBuffers;
	import QFLib.Graphics.RenderCore.starling.display.RenderQueueGroup;
	import QFLib.Graphics.RenderCore.starling.textures.Texture;
	import QFLib.Graphics.RenderCore.starling.textures.TextureAtlas;
	import QFLib.Graphics.RenderCore.starling.utils.VertexData;
	import QFLib.Math.CVector2;
	import QFLib.ResourceLoader.CResource;
	import QFLib.ResourceLoader.CResourceLoaders;
	import QFLib.ResourceLoader.CXmlLoader;
	import QFLib.ResourceLoader.ELoadingPriority;
	import QFLib.Utils.Quality;

	import flash.display3D.Context3DBufferUsage;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix;

	public class BaseEffectInstance extends BaseEffect implements IGeometry
    {
        protected static var sMatrixIdentity : Matrix = new Matrix ();
        protected static var sVector2DHelper0 : CVector2 = new CVector2 ();
        protected static var sVector2DHelper1 : CVector2 = new CVector2 ();

        protected var _vertexBuffer : VertexBuffer3D = null;
        protected var _indexBuffer : IndexBuffer3D = null;
        protected var _vertices : VertexData = null;
        protected var _indices : Vector.<uint> = null;

        protected var _keyFrame : KeyFrame;
        protected var _material : EffectMaterial;

        protected var _usedNumVertices : int = 4;
        protected var _usedNumTriangles : int = 2;
        protected var _enable : Boolean = false;
        protected var _vertexBufDirty : Boolean = false;
        protected var _indexBufDirty : Boolean = false;

        private var _plistResource : CResource;
        private var _texResource : CResource;
        private var _textureName:String;

        public function BaseEffectInstance ()
        {
            if ( sMatrixIdentity ) sMatrixIdentity.identity ();

            _keyFrame = _createKeyFrame ();
            _material = new EffectMaterial ();

            Starling.addContext3DCreateCallback( this, onContextCreated );
        }

        override public function dispose () : void
        {
            Starling.removeContext3DCreateCallback( this, onContextCreated );
            _destroyBuffers ();
            if ( _material != null )
            {
                _material.dispose ();
                _material = null;
            }

            if ( _keyFrame != null )
            {
                _keyFrame.dispose ();
                _keyFrame = null;
            }

            if(_plistResource != null)
            {
                _plistResource.dispose();
                _plistResource = null;
            }

            if ( _texResource != null )
            {
                _texResource.dispose ();
                _texResource = null;
            }

            if ( _vertices != null )
            {
                _vertices.dispose ();
                _vertices = null;
            }

            if ( _indices != null )
            {
                _indices.fixed = false;
                _indices.length = 0;
                _indices = null;
            }

            super.dispose ();
        }

        // try getting all used resources - implement by the derived classes
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            var iCount : int = 0;
            if ( null != _texResource )
            {
                if( vResources != null )
                {
                    vResources[ iBeginIndex + iCount ] = _texResource;
                }
                iCount++;
            }

            if( null != _plistResource)
            {
                if( vResources != null )
                {
                    vResources[ iBeginIndex + iCount ] = _plistResource;
                }
                iCount++;
            }
            return iCount;
        }

        public override function get isDead () : Boolean { return false; }

        override public function setColor ( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            _material.setColor ( r, g, b, alpha, masking );
        }
        override public function resetColor () : void { _material.resetColor (); }

        override public function loadFromObject ( url : String, data : Object, iLoadingPriority : int = ELoadingPriority.NORMAL, onEffectLoadFinished : Function = null ) : void
        {
            super.loadFromObject ( url, data, iLoadingPriority, onEffectLoadFinished );

            if ( checkObject ( data, "life" ) ) _life = data.life;

            if ( checkObject ( data, "keyFrame" ) ) _keyFrame.loadFromObject ( data.keyFrame );

            if ( checkObject ( data, "material" ) ) _material.loadFromObject ( data.material );

            if ( checkObject ( data, "effect" ) ) _loadFromObject ( data.effect );

            _loadMaterial ( url, iLoadingPriority );
        }

        [Inline] override public function get enable () : Boolean { return _enable; }

        [Inline] public override function isDrawSelf () : Boolean { return true; }

        override public function addToRenderQueue ( culler : ICuller, groups : RenderQueueGroup ) : void
        {
            if ( !enable || isDead || !hasVisibleArea || !_bScreenVisible ) return;

            if ( _isRootEffect && _bound != null)
                this.isInRender = /*_bound != null &&*/                     //当前默认，没有bound照样渲染
                        culler.checkCullingMask ( this ) &&
                        culler.isVisibleNode ( this );

            if ( this.isInRender )
            {
                groups.addNode ( renderQueueID, this );
            }
        }

        override public function render ( support : RenderSupport, alpha : Number ) : void
        {
            if ( !enable || isDead || !isVisbile ) return;

            if ( !_delaying )
            {
                _render ( support, alpha );
            }
        }

        public function setVertexBuffers() : void
        {
            var pInstance : Starling = Starling.current;
            pInstance.setVertexBuffer ( 0, _vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
            pInstance.setVertexBuffer ( 1, _vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4 );
            pInstance.setVertexBuffer ( 2, _vertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
        }
        public function draw() : int
        {
            var pInstance : Starling = Starling.current;
            pInstance.drawTriangles ( _indexBuffer, 0, _usedNumTriangles );
            pInstance.clearVertexBuffer ( 0 );
            pInstance.clearVertexBuffer ( 1 );
            pInstance.clearVertexBuffer ( 2 );
            return 1;
        }

        protected function _syncBuffers () : void
        {
            _syncVertexBuffer ();
            _syncIndexBuffer ();
        }
        protected function _syncBuffersEx () : void
        {
            _syncVertexBufferEx ();
            _syncIndexBufferEx ();
        }

        override protected function _render ( support : RenderSupport, alpha : Number ) : void
        {
            var pTex : Texture = _material.texture;
            if ( pTex == null || !pTex.uploaded || pTex.base == null ) return;

            _updateMesh ();
            _syncBuffers ();

            var rcmd : RenderCommand = RenderCommand.assign ( worldTransform );
            rcmd.geometry = this;
            rcmd.material = _material.concreteMaterial;
            Starling.current.addToRender ( rcmd );
        }

        override protected function _postUpdate () : void
        {
            _updateMaterial ();
        }

        protected function _updateMaterial () : void
        {
            _material.updateMaterial ( finalAlpha );
        }

        protected function _updateMesh () : void { }

        protected virtual function _createKeyFrame () : KeyFrame { return new KeyFrame (); }

        protected virtual function _loadFromObject ( data : Object ) : void { }

        protected function _loadMaterial ( url : String, iLoadingPriority : int = ELoadingPriority.NORMAL ) : void
        {
            if ( _material.textureName == null || _material.textureName == "" )
            {
                return;
            }

            var dir : String = CPath.driverDirParent ( url );
            dir = CPath.removeRightSlash ( dir );

            if(Quality.useFxAtlas)
            {
                _textureName = CFxAtlasInfo.getFileName(_material.textureName);
                var atlasName:String = CFxAtlasInfo.instance.atlasInfo[_textureName];
                var plistUrl:String = dir + "/textureAltas/" + atlasName + ".plist";
                CResourceLoaders.instance ().startLoadFile (plistUrl , onPlistLoadFinished, CXmlLoader.NAME, iLoadingPriority, true, false, null, plistUrl, atlasName );
            }
            else
            {
                var textureUrl : String = dir + "/textures/" + _material.textureName;
                var vFilenames : Vector.<String> = new Vector.<String> ();
                if(Quality.isLowQualityOfRender)
                {
                    if(Quality.knifeImageManualSwitch)
                    {
                        vFilenames[ 0 ] = textureUrl + "_ko.png";
                    }
                    else
                    {
                        vFilenames[ 0 ] = textureUrl + ".png";
                    }
                }
                else
                {
                    vFilenames[ 0 ] = textureUrl + ".atf";
                    vFilenames[ 1 ] = textureUrl + ".png";
                }

                CResourceLoaders.instance ().startLoadFileFromPathSequence ( vFilenames, onTextureLoadFinished, CTextureLoader.NAME, iLoadingPriority, true );
            }
        }

        private function onPlistLoadFinished ( loader : CXmlLoader, idErrorCode : int ) : void
        {
            var plistUrl : String = loader.arguments[ 0 ];
            var atlasName : String = loader.arguments[ 1 ];
            if ( idErrorCode == 0 )
            {
                _plistResource = loader.createResource();
                var theXml : XML = _plistResource.theObject as XML;

                if ( null == theXml ) {
                    Foundation.Log.logErrorMsg( "effect load failure:" + plistUrl );
                    return;
                }

                var vFilenames : Vector.<String> = new Vector.<String>();
                if ( Quality.isLowQualityOfRender ) {
                    if ( Quality.knifeImageManualSwitch ) {
                        vFilenames[ 0 ] = plistUrl.replace( ".plist", "_ko.png" );
                    }
                    else {
                        vFilenames[ 0 ] = plistUrl.replace( ".plist", ".png" );
                    }
                }
                else {
                    vFilenames[ 0 ] = plistUrl.replace( ".plist", ".atf" );
                    vFilenames[ 1 ] = plistUrl.replace( ".plist", ".png" );
                }
                CResourceLoaders.instance().startLoadFileFromPathSequence( vFilenames, onTextureAtlasLoadFinished, CTextureAtlasLoader.NAME,
                        ELoadingPriority.NORMAL, true, false, null, plistUrl, theXml, atlasName );
            }
            else {
                Foundation.Log.logErrorMsg( "FX load failed, please check the fx url: " + plistUrl );
            }
        }

        private function onTextureAtlasLoadFinished( loader : CTextureAtlasLoader, idErrorCode : int ) : void
        {
            if( idErrorCode != 0 )
            {
                Foundation.Log.logErrorMsg( "onTextureLoadFinished(): Can not load texture: " + loader.loadingFilename );
                if ( _onEffectLoadFunc != null )
                    _onEffectLoadFunc (false);
                return ;
            }

            _texResource = loader.createResource ();
            if ( _texResource != null )
            {
                var atlas:TextureAtlas = _texResource.theObject as TextureAtlas;
                if ( null == atlas )
                {
                    Foundation.Log.logErrorMsg ( "onTextureLoadFinished(): cannot get texture's data( null): " + loader.filename );
                    if ( _onEffectLoadFunc != null )
                        _onEffectLoadFunc (false);
                    return;
                }

                if(_material)
                {
                    _material.textureRegion = atlas.getRegion(_textureName);
                    _material.isRotate = atlas.getRotation(_textureName);
                    _material.texture = atlas.texture;
                }
                _enable = true;

                if ( _onEffectLoadFunc != null )
                    _onEffectLoadFunc ();
            }
        }

    private function onTextureLoadFinished ( loader : CTextureLoader, idErrorCode : int ) : void
    {
        if ( _material == null ) return; // disposed before this load finished get called

        if ( idErrorCode != 0 )
        {
            _assetsSize = 0;

            Foundation.Log.logErrorMsg ( "onTextureLoadFinished(): Can not load texture: " + loader.filename + ". The effect name is: " + this._effectURL );
            if ( _onEffectLoadFunc != null )
                _onEffectLoadFunc (false);
            return;
        }

        _texResource = loader.createResource ();
        if ( _texResource != null )
        {
            var tex : Texture = _texResource.theObject as Texture;
            if ( null == tex )
            {
                Foundation.Log.logErrorMsg ( "onTextureLoadFinished(): cannot get texture's data( null): " + loader.filename );
                return;
            }

            _material.texture = tex;
            _enable = true;

            if ( _onEffectLoadFunc != null )
            {
                var params : Array = [ _material.textureName, _texResource.resourceSize ];
                _onEffectLoadFunc ( true, params );
            }
        }
    }

        override protected virtual function _reset () : void { _material.resetColor (); }

        protected function _syncVertexBuffer () : void
        {
            if ( _vertexBuffer == null )
                _vertexBuffer = StaticBuffers.getInstance().fxStaticVertexBuffer;
            _vertexBuffer.uploadFromVector ( _vertices.rawData, 0, _usedNumVertices );
        }
        protected function _syncIndexBuffer () : void
        {
            if ( _indexBuffer == null )
                _indexBuffer = StaticBuffers.getInstance().fxStaticIndexBuffer;
        }
        protected function _syncVertexBufferEx() : void
        {
            var pStarling : Starling = Starling.current;
            if ( _vertexBuffer == null || _vertexBufDirty )
            {
                if ( _vertexBuffer != null ) pStarling.destroyVertexBuffer ( _vertexBuffer );
                _vertexBuffer = pStarling.createVertexBuffer ( _vertices.numVertices, 8, Context3DBufferUsage.DYNAMIC_DRAW );
                _vertexBufDirty = false;
            }
            pStarling.uploadVertexBufferData ( _vertexBuffer, _vertices.rawData, 0, _vertices.numVertices );
        }
        protected function _syncIndexBufferEx() : void
        {
            var pStarling : Starling = Starling.current;
            if ( _indexBuffer == null || _indexBufDirty )
            {
                if ( _indexBuffer != null ) pStarling.destroyIndexBuffer ( _indexBuffer );
                _indexBuffer = pStarling.createIndexBuffer ( _indices.length, Context3DBufferUsage.DYNAMIC_DRAW );
                _indexBufDirty = false;
            }
            pStarling.uploadIndexBufferData ( _indexBuffer, _indices, 0, _indices.length );
        }

        protected function _destroyBuffers () : void
        {
            _destroyVertextBuffer ();
            _destroyIndexBuffer ();
        }

        protected function _destroyVertextBuffer () : void
        {
            _vertexBuffer = null;
        }
        protected function _destroyIndexBuffer () : void
        {
            _indexBuffer = null;
        }
        protected function _destroyVertextBufferEx() : void
        {
            if ( _vertexBuffer != null )
            {
                var pStarling : Starling = Starling.current;
                pStarling.destroyVertexBuffer ( _vertexBuffer );
                _vertexBuffer = null;
            }
        }
        protected function _destroyIndexBufferEx() : void
        {
            if ( _indexBuffer != null )
            {
                var pStarling : Starling = Starling.current;
                pStarling.destroyIndexBuffer ( _indexBuffer );
                _indexBuffer = null;
            }
        }

        private function onContextCreated ( event : Object ) : void
        {
            _destroyBuffers ();
        }
    }
}