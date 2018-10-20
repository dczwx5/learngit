package QFLib.Graphics.FX.effectsystem
{

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Foundation.CPath;
import QFLib.Graphics.RenderCore.CTextureLoader;
import QFLib.Graphics.RenderCore.starling.textures.Texture;
import QFLib.Graphics.RenderCore.starling.utils.VertexData;
import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.ELoadingPriority;
import QFLib.Utils.Quality;

public class SpriteAnimationInstance extends BaseEffectInstance
    {
        private var _textureResources : Vector.<CResource> = new Vector.<CResource> ();
        private var _infoVector : Vector.<SpriteInfo> = null;
        private var _textures : CMap = null;

        private var _fCurrentTime : Number = 0.0;
        private var _textureLen : int = 0;
        private var _iCurrentSprite : int = -1;
        private var _iNextSprite : int = 0;

        public function SpriteAnimationInstance ()
        {
            _vertices = new VertexData ( 4 );
        }

        public override function dispose () : void
        {
            if ( _textureResources != null )
            {
                for ( var i : int = 0; i < _textureResources.length; i++ )
                {
                    _textureResources[ i ].dispose ();
                    _textureResources[ i ] = null;
                }

                _textureResources.fixed = false;
                _textureResources.length = 0;
                _textureResources = null;
            }

            _infoVector.fixed = false;
            _infoVector.length = 0;
            _infoVector.fixed = true;
            _infoVector = null;

            super.dispose ();
        }

        // try getting all used resources - implement by the derived classes
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            if ( _textureResources != null )
            {
                var iCount : int = 0;
                for ( var i : int = 0; i < _textureResources.length; i++ )
                {
                    if( vResources != null )
                    {
                        vResources[ iBeginIndex + iCount ] = _textureResources[i];
                    }
                    iCount++;
                }

                return iCount;
            }
            return 0;
        }

        public override function get isDead () : Boolean
        { return _fCurrentTime >= life; }

        protected override function _reset () : void
        {
            super._reset ();
            _fCurrentTime = 0.0;
            _iCurrentSprite = -1;
            _iNextSprite = 0;
        }

        protected override function _updateMesh () : void
        {
            var verticesRawData : Vector.<Number> = _vertices.rawData;

            //update vertex position
            verticesRawData[ 0 ] = -100.0;
            verticesRawData[ 1 ] = -100.0;

            verticesRawData[ 8 ] = 100.0;
            verticesRawData[ 9 ] = -100.0;

            verticesRawData[ 16 ] = 100.0;
            verticesRawData[ 17 ] = 100.0;

            verticesRawData[ 24 ] = -100.0;
            verticesRawData[ 25 ] = 100.0;

            //update vertex color
            //var color : uint = 0xFFFFFFFF;

            //update vertex uv
            verticesRawData[ 6 ] = 0.0;
            verticesRawData[ 7 ] = 0.0;

            verticesRawData[ 14 ] = 1.0;
            verticesRawData[ 15 ] = 0.0;

            verticesRawData[ 22 ] = 1.0;
            verticesRawData[ 23 ] = 1.0;

            verticesRawData[ 30 ] = 0.0;
            verticesRawData[ 31 ] = 1.0;
        }

        protected override function _update ( deltaTime : Number ) : void
        {
            super._update( deltaTime );
            _fCurrentTime += deltaTime;

            if ( _iNextSprite >= _textureLen ) return;

            var nextInfo : SpriteInfo = _infoVector[ _iNextSprite ];
            if ( _fCurrentTime > nextInfo.fStartTime )
            {
                _iCurrentSprite = _iNextSprite;
                _iNextSprite++;
            }

            _material.texture = _textures[ nextInfo.textureName ];
        }

        protected override function _loadFromObject ( data : Object ) : void
        {
            if ( checkObject ( data, "sprites" ) )
            {
                var sprites : Array = data.sprites;
                var len : int = sprites.length;

                if ( _infoVector == null )
                    _infoVector = new Vector.<SpriteInfo> ( len );

                if ( _textures == null )
                    _textures = new CMap ();
                else
                    _textures.clear ();

                var info : SpriteInfo = null;
                for ( var i : int = 0; i < len; i++ )
                {
                    info = new SpriteInfo ();
                    if ( checkObject ( sprites[ i ], "starttime" ) )
                        info.fStartTime = sprites[ i ].starttime;

                    if ( checkObject ( sprites[ i ], "texture" ) )
                        info.textureName = sprites[ i ].texture;

                    _infoVector[ i ] = info;
                }

                _textureLen = _infoVector.length;
            }
        }

        protected override function _loadMaterial ( url : String, iLoadingPriority : int = ELoadingPriority.NORMAL ) : void
        {
            var dir : String = CPath.driverDirParent ( url );
            dir = CPath.removeRightSlash ( dir ) + "/textures/";

            var textureUrl : String = null;
            var vFilenames : Vector.<String> = new Vector.<String> ( 3 );
            for ( var i : int = 0; i < _infoVector.length; i++ )
            {
                textureUrl = dir + _infoVector[ i ].textureName;

                if(Quality.isLowQualityOfRender)
                {
                    if(Quality.knifeImageManualSwitch)
                    {
                        vFilenames[ 0 ] = textureUrl.toLowerCase () + "_ko.png";
                        vFilenames[ 1 ] = textureUrl.toLowerCase () + "_ko.png";
                    }
                    else
                    {
                        vFilenames[ 0 ] = textureUrl.toLowerCase () + ".png";
                        vFilenames[ 1 ] = textureUrl.toLowerCase () + ".png";
                    }
                }
                else
                {
                    vFilenames[ 0 ] = textureUrl.toLowerCase () + ".atf";
                    vFilenames[ 1 ] = textureUrl.toLowerCase () + ".png";
                }
                vFilenames[ 2 ] = textureUrl.toLowerCase () + ".jpg";

                CResourceLoaders.instance ().startLoadFileFromPathSequence ( vFilenames, _onTexturesLoadFinished, CTextureLoader.NAME, iLoadingPriority, true );
            }
        }

        private function _onTexturesLoadFinished ( loader : CTextureLoader, idErrorCode : int ) : void
        {
            if ( _material == null ) return; // disposed before this load finished get called

            if ( idErrorCode != 0 )
            {
                Foundation.Log.logErrorMsg ( "onTextureLoadFinished(): Can not load texture: " + loader.filename );
                if ( _onEffectLoadFunc != null )
                    _onEffectLoadFunc (false);
                return;
            }

            _textureResources.fixed = false;
            var len : int = _textureResources.length;
            var texResource : CResource = _textureResources[ len ] = loader.createResource ();
            _textureResources.fixed = true;

            var tex : Texture = texResource.theObject as Texture;
            if ( null == tex )
            {
                Foundation.Log.logErrorMsg ( "onTextureLoadFinished(): cannot get texture's data( null): " + loader.filename );
                if ( _onEffectLoadFunc != null )
                    _onEffectLoadFunc (false);
                return;
            }

            _textures.add ( texResource.name, tex );

            if ( len == 0 )
                _material.texture = tex;

            if ( len + 1 == _infoVector.length )
            {
                _enable = true;
                if ( _onEffectLoadFunc != null )
                    _onEffectLoadFunc ();
            }
        }
    }
}

class SpriteInfo
{
    public var textureName : String = "";
    public var fStartTime : Number = 0.0;
}



