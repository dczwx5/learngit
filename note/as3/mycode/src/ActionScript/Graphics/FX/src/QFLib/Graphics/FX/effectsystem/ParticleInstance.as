package QFLib.Graphics.FX.effectsystem
{

    import QFLib.Graphics.FX.effectsystem.keyFrame.KeyFrame;
    import QFLib.Graphics.FX.effectsystem.keyFrame.ParticleKeyFrame;
    import QFLib.Graphics.FX.effectsystem.particleModifier.CParticleModifier;
    import QFLib.Graphics.FX.effectsystem.particleModifier.CParticleModifierFactory;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;
    import QFLib.Math.CVector2;

    public class ParticleInstance extends BaseEffectInstance
    {
        public const BILLBOARD : int = 0;
        public const ARROW : int = 1;

        public const WaitLifeEnd : int = 0;
        public const WaitParticlesClear : int = 1;

        private var _modifiers : Vector.<CParticleModifier> = new <CParticleModifier>[];
        private var _emitter : ParticleBaseEmitter;

        private var _type : int;
        private var _loopEmitType : int = WaitLifeEnd;

        private var _matrixInitialized : Boolean = false;

        public function ParticleInstance ()
        {
            _vertices = new VertexData ( 0, true );
            _indices = new Vector.<uint> ();
            _indices.fixed = false;
            type = BILLBOARD;
        }

        public override function dispose () : void
        {
            _emitter.dispose ();
            _emitter = null;

            for each( var modifier : CParticleModifier in _modifiers )
            {
                CParticleModifierFactory.deallocate ( modifier );
            }
            _modifiers.length = 0;
            _modifiers = null;

            super.dispose ();
        }

        public override function get isDead () : Boolean
        {
            if ( _loop && _emitter.isDead )
                _reset ();

            return _emitter.isDead;
        }

        public function set type ( value : int ) : void
        {
            var particleKeyFrame : ParticleKeyFrame = _keyFrame as ParticleKeyFrame;
            var e : ParticleBaseEmitter = null;
            if ( value == BILLBOARD )
                e = new ParticleBillboardEmitter ( this, particleKeyFrame, _modifiers );
            else if ( value == ARROW )
                e = new ParticleArrowEmitter ( this, particleKeyFrame, _modifiers );
            else
                trace ( "no such type" );

            _type = value;
            _emitter = e;
        }

        [Inline]
        final public function get modifiers () : Vector.<CParticleModifier> { return _modifiers; }

        public function addModifier ( modifier : CParticleModifier ) : void
        {
            var index : int = _modifiers.indexOf ( modifier );
            if ( index == -1 )
                _modifiers[ _modifiers.length ] = modifier;
        }

        public function removeModifier ( modifier : CParticleModifier ) : void
        {
            var index : int = _modifiers.indexOf ( modifier );
            if ( index != -1 )
                _modifiers.splice ( index, 1 );
        }

        protected override function _loadFromObject ( data : Object ) : void
        {
            if ( checkObject ( data, "type" ) )
                type = data.type;
            if ( checkObject ( data, "emitter" ) )
                _emitter.loadFromObject ( data.emitter );
            if ( data.hasOwnProperty ( "loopEmitType" ) )
                _loopEmitType = data.loopEmitType;

            if ( data.hasOwnProperty ( "modifiers" ) )
            {
                var modifiers : Array = data[ "modifiers" ];
                for ( var i : int = 0, l : int = modifiers.length; i < l; ++i )
                {
                    _addModifierFromData ( modifiers[ i ] );
                }
            }
        }

        override protected function _destroyBuffers() : void
        {
            _destroyVertextBufferEx ();
            _destroyIndexBufferEx ();
        }

        protected override function _updateMesh () : void
        {
            var particles : Vector.<Particle> = _emitter.particles;
            var particleCount : int = _emitter.validParticleCount;
            if ( particleCount < 1 ) return;

            _usedNumVertices = particleCount * 4;
            if ( _usedNumVertices  > _vertices.numVertices )
            {
                _vertices.numVertices = _usedNumVertices * 1.5;
                _vertexBufDirty = true;
            }
            var usedNumIndices : int = particleCount * 6;
            _usedNumTriangles = particleCount * 2;
            if ( usedNumIndices > _indices.length )
            {
                _indices.length = usedNumIndices * 1.5;
                _indexBufDirty = true;
            }

            var verticesRawData : Vector.<Number> = _vertices.rawData;
            for ( var i : int = 0; i < particleCount; ++i )
            {
                var vIndex : int = i * 32;
                var iIndex : int = i * 6;

                var particle : Particle = particles[ i ];
                var sizeX : Number = particle.size.x * 0.5;
                var sizeY : Number = particle.size.y * 0.5;

                //update vertex position
                verticesRawData[ vIndex ] = -sizeX;
                verticesRawData[ vIndex + 1 ] = -sizeY;

                verticesRawData[ vIndex + 8 ] = +sizeX;
                verticesRawData[ vIndex + 9 ] = -sizeY;

                verticesRawData[ vIndex + 16 ] = +sizeX;
                verticesRawData[ vIndex + 17 ] = +sizeY;

                verticesRawData[ vIndex + 24 ] = -sizeX;
                verticesRawData[ vIndex + 25 ] = +sizeY;

                for ( var j : int = 0; j < 4; ++j )
                {
                    var index : Number = vIndex + j * 8;
                    _rotate2D ( verticesRawData[ index ], verticesRawData[ index + 1 ],
                            particle.rotation, verticesRawData, index );
                    verticesRawData[ index ] += particle.position.x;
                    verticesRawData[ index + 1 ] += particle.position.y;
                }

                //update vertex uv
                _setUV ( verticesRawData, vIndex + 6, particle.normalLife );

                //update vertex color
                var color : uint = particle.color;
                var red : Number = ( ( color >> 24 ) & 0xff ) / 255.0;
                var green : Number = ( ( color >> 16 ) & 0xff ) / 255.0;
                var blue : Number = ( ( color >> 8 ) & 0xff ) / 255.0;
                var alpha : Number = ( color & 0xff ) / 255.0;
                verticesRawData[ vIndex + 2 ] = verticesRawData[ vIndex + 10 ] = verticesRawData[ vIndex + 18 ] = verticesRawData[ vIndex + 26 ] = red;
                verticesRawData[ vIndex + 3 ] = verticesRawData[ vIndex + 11 ] = verticesRawData[ vIndex + 19 ] = verticesRawData[ vIndex + 27 ] = green;
                verticesRawData[ vIndex + 4 ] = verticesRawData[ vIndex + 12 ] = verticesRawData[ vIndex + 20 ] = verticesRawData[ vIndex + 28 ] = blue;
                verticesRawData[ vIndex + 5 ] = verticesRawData[ vIndex + 13 ] = verticesRawData[ vIndex + 21 ] = verticesRawData[ vIndex + 29 ] = alpha;

                //update index
                vIndex = i * 4;
                _indices[ iIndex + 0 ] = vIndex + 0;
                _indices[ iIndex + 1 ] = vIndex + 1;
                _indices[ iIndex + 2 ] = vIndex + 2;
                _indices[ iIndex + 3 ] = vIndex + 0;
                _indices[ iIndex + 4 ] = vIndex + 2;
                _indices[ iIndex + 5 ] = vIndex + 3;
            }
        }

        protected override function _update ( deltaTime : Number ) : void
        {
            super._update( deltaTime );
            if ( !_matrixInitialized || worldMatrixDirty )
            {
                _emitter.setWorldScale ( this.worldScaleX, this.worldScaleY );
                _emitter.worldRotation = this.worldRotation;
                _matrixInitialized = true;
            }

            var newLife:Number = _currentLife + deltaTime;
            if ( newLife >= life && _currentLife < life)
            {
                _emitter.tick(life - _currentLife);
                _emitter.isExpire = true;
                _emitter.tick(newLife - life);
                _currentLife = newLife;
                if ( _loop && _loopEmitType == WaitLifeEnd )
                {
                    _currentLife = 0.0;
                    _emitter.isExpire = false;
                }
            }
            else
            {
                _currentLife = newLife;
                _emitter.tick ( deltaTime );
            }
        }

        protected override function _render ( support : RenderSupport, alpha : Number ) : void
        {
            var particleCount : int = _emitter.validParticleCount;
            var pTex : Texture = _material.texture;
            if ( particleCount < 1 || pTex == null || !pTex.uploaded || pTex.base == null ) return;

            _updateMesh ();
            _syncBuffersEx ();

            var rcmd : RenderCommand = RenderCommand.assign ();
            rcmd.geometry = this;
            rcmd.material = _material.concreteMaterial;
            if ( _emitter.isWorld )
                rcmd.matWorld2D = sMatrixIdentity;
            else
                rcmd.matWorld2D = this.worldTransform;

            Starling.current.addToRender ( rcmd );
        }

        protected override function _reset () : void
        {
            super._reset ();
            _currentLife = 0.0;
            _emitter.reset ();
        }

        protected override function _createKeyFrame () : KeyFrame { return new ParticleKeyFrame (); }

        private function _addModifierFromData ( data : Object ) : void
        {
            var modifier : CParticleModifier = CParticleModifierFactory.allocate ( data, this );
            _modifiers[ _modifiers.length ] = modifier;
        }

        private function _rotate2D ( x : Number, y : Number, r : CVector2, v : Vector.<Number>, i : int ) : void
        {
            v[ i ] = x * r.x + y * r.y;
            v[ i + 1 ] = y * r.x - x * r.y;
        }

        private function _setUV ( verticesRawData : Vector.<Number>, index : int, normalLife : Number ) : void
        {
            var uvOffset : int = _material.getUVOffsetByNormalLife ( normalLife );
            var uvList : Vector.<Number> = _material.uvList;

            var indexOffset : int = 0;
            var rIndex : int = index;
            var uvIndex : int = 0;
            for ( var i : int = 0; i < 4; i++ )
            {
                indexOffset = i * 8;
                rIndex = index + indexOffset;
                uvIndex = uvOffset + 2 * i;
                verticesRawData[ rIndex ] = uvList[ uvIndex ];
                verticesRawData[ rIndex + 1 ] = uvList[ uvIndex + 1 ];
            }
        }
    }
}