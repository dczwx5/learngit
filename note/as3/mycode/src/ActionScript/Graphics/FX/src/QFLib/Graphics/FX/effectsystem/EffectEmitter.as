package QFLib.Graphics.FX.effectsystem
{
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.geom.Matrix3D;

    public class EffectEmitter extends BaseEffectContainer
    {
        private static var sEmitRangeDefault : CVector2 = CVector2.zero();
        private static var sPositionHelper : CVector2 = CVector2.zero ();

        public var range : CVector2 = CVector2.zero();
        public var scaler : CVector2 = CVector2.one();
        public var emitType : int = EffectSystem.RING;
        public var templateTransform : Matrix3D = new Matrix3D ();
        private var _interval : Number = 0.15;
        private var _emitCount : int = 1;
        private var _emittedCount : int = 0;
        private var _maxLife : Number;
        private var _effects : Vector.<IEffect>;
        private var _jsonUrl : String;

        public function EffectEmitter ()
        {
            emitType = EffectSystem.RING;
            _effects = new Vector.<IEffect> ();
            _effects.fixed = true;
        }

        public override function dispose () : void
        {
            for ( var i : int = 0, n : int = _effects.length; i < n; i++ )
            {
                _effects[ i ].dispose ();
                _effects[ i ] = null;
            }

            templateTransform = null;

            super.dispose ();
        }

        override public function get assetsSize () : int
        {
            if ( _effects != null && _effects.length > 0 )
                _assetsSize = _effects[ 0 ].assetsSize;
            return _assetsSize;
        }

        public function get interval () : Number { return _interval; }
        public function set interval ( value : Number ) : void
        {
            _interval = value;
            _maxLife = value * _emittedCount;
        }

        public function get emitCount () : int { return _emitCount; }
        public function set emitCount ( value : int ) : void
        {
            _emitCount = value;
            _maxLife = value * interval;
        }

        public override function get isDead () : Boolean
        {
            var dead : Boolean = true;
            if ( _maxLife > _currentLife )
                dead = false;
            else
            {
                for ( var i : int = 0; i < _emittedCount; i++ )
                {
                    if ( !_effects[ i ].isDead )
                        dead = false;
                }
            }

            if ( _loop && dead )
                _reset ();

            return dead;
        }

        public override function get enable () : Boolean
        {
            for ( var i : int = 0, n : int = _effects.length; i < n; i++ )
            {
                if ( !_effects[ i ].enable ) return false;
            }

            return true;
        }

        protected override function _loadFromJson ( url : String, data : Object, iLoadingPriority : int = ELoadingPriority.NORMAL ) : void
        {
            _jsonUrl = url;

            if ( checkObject ( data, "emitType" ) )
                emitType = data.emitType;

            if ( checkObject ( data, "interval" ) )
                interval = data.interval;

            if ( checkObject ( data, "emitCount" ) )
                emitCount = data.emitCount;

            if ( checkObject ( data, "range" ) )
                range = new CVector2 ( data.range.x, data.range.y );

            if ( checkObject ( data, "scaler" ) )
                scaler = new CVector2 ( data.scaler.x, data.scaler.y );

            checkObject ( data, "templateTransform" );
            readMatrix ( data.templateTransform, templateTransform );

            if ( checkObject ( data, "template" ) )
                createTemplateEffect ( data.template );
        }

        protected override function _reset () : void
        {
            _currentLife = 0.0;
            _emittedCount = 0;

            for ( var i : int = 0, n : int = _effects.length; i < n; i++ )
            {
                _effects[ i ].reset ();
            }
        }

        protected override function _update ( deltaTime : Number ) : void
        {
            super._update( deltaTime );

            beforeUpdate ( deltaTime );

            for ( var i : int = 0; i < _emittedCount; i++ )
            {
                if ( !_effects[ i ].isDead )
                {
                    _effects[ i ].update ( deltaTime );
                }
            }
        }

        private function beforeUpdate ( deltaTime : Number ) : void
        {
            _currentLife += deltaTime;

            if ( (_emittedCount < _emitCount) && ((_currentLife / _interval) > _emittedCount) )
            {
                emit ();
                ++_emittedCount;
            }
        }

        private function emit () : void
        {
            var effect : IEffect = _effects[ _emittedCount ];
            var position : CVector2 = genLocalTransform ();
            var object : DisplayObject = effect as DisplayObject;
            if ( object != null )
            {
                object.x = position.x;
                object.y = position.y;
            }
        }

        private function createTemplateEffect ( data : Object, iLoadingPriority : int = ELoadingPriority.NORMAL ) : void
        {
            for ( var i : int = 0; i < _emitCount; i++ )
            {
                var effect : IEffect = EffectSystem.createEffect ( data.type );
                effect.loadFromObject ( _jsonUrl, data, iLoadingPriority, _onEffectLoadFunc );
                ( effect as BaseEffect ).isRootEffect = false;

                if ( effect != null )
                {
                    _effects.fixed = false;
                    _effects[ _effects.length ] = effect;
                    _effects.fixed = true;

                    var object : DisplayObject = effect as DisplayObject;
                    if ( object != null )
                    {
                        this.addChild ( object );
                    }
                }
            }
        }

        private function genLocalTransform () : CVector2
        {
            var position : CVector2;
            if ( emitType == EffectSystem.RING )
            {
                sEmitRangeDefault.x = range.x + (_emittedCount * 1.0 / emitCount) * (range.y - range.x);
                sEmitRangeDefault.y = sEmitRangeDefault.x;
                position = EmitGenerator.genPosition ( emitType, sEmitRangeDefault, scaler, sPositionHelper );
            }
            else
            {
                position = EmitGenerator.genPosition ( emitType, range, scaler, sPositionHelper );
            }

            return position;
        }
    }
}
