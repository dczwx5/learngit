/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/12/12.
 */
package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.Passes.PSmooth;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class MSmooth extends MaterialBase implements IMaterial
    {
        public function MSmooth()
        {
            super( 1 );

            _inactivePasses.add( PSmooth.sName, _passSmooth );
            _passSmooth.uvOffsets = _uvOffsets;
            _passes[ 0 ] = _passSmooth;
        }
        private var _passSmooth : PSmooth = new PSmooth();

        public override function set texture( value : Texture ) : void
        {
            super.texture = value;
            _passes[ 0 ].texture = value;
        }

        private var _uvOffsets : Vector.<Number> = new <Number>[ 1.0, 0.0, 1.0, 4.0 ];

        public function set uvOffsets( value : Vector.<Number> ) : void
        {
            for( var i : int = 0; i < 4; i++ )
            {
                _uvOffsets[ i ] = value[ i ];
            }
        }

        public function equal( other : IMaterial ) : Boolean
        {
            return false;
        }

        public function copySingleton() : IMaterial
        {
            return null;
        }
    }
}
