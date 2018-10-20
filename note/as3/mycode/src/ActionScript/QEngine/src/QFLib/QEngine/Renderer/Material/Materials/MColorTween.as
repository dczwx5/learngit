/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Passes.PColorMatrix;
    import QFLib.QEngine.Renderer.Material.Passes.PColorSpriteTint;
    import QFLib.QEngine.Renderer.Material.Passes.PSpriteSimple;
    import QFLib.QEngine.Renderer.Utils.Util;

    public class MColorTween extends MSprite
    {
        private static const IDENTITY : Vector.<Number> = Vector.<Number>[ 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0 ];

                public function MColorTween()
        {
            super();

            mShaderMatrix = new <Number>[];

            var passColorMatrix : PColorMatrix = new PColorMatrix();
            _inactivePasses.add( PColorMatrix.sName, passColorMatrix );
            passColorMatrix.tintColor = _tintColor;
            passColorMatrix.maskColor = _maskColor;
            passColorMatrix.colorMatrix = mShaderMatrix;
        } // offset in range 0-1, changed order
private var mShaderMatrix : Vector.<Number>;

        /** A vector of 20 items arranged as a 4x5 matrix. */
        public function set matrix( value : Vector.<Number> ) : void
        {
            if( value && value.length != 20 )
                throw new ArgumentError( "Invalid matrix length: must be 20" );

            if( value == null )
            {
                value = IDENTITY;
            }

            mShaderMatrix.length = 0;
            mShaderMatrix.push(
                    value[ 0 ], value[ 1 ], value[ 2 ], value[ 3 ],
                    value[ 5 ], value[ 6 ], value[ 7 ], value[ 8 ],
                    value[ 10 ], value[ 11 ], value[ 12 ], value[ 13 ],
                    value[ 15 ], value[ 16 ], value[ 17 ], value[ 18 ],
                    value[ 4 ] / 255.0, value[ 9 ] / 255.0, value[ 14 ] / 255.0, value[ 19 ] / 255.0
            );

            updatePass();
        }

        override public function dispose() : void
        {
            if( mShaderMatrix )
            {
                mShaderMatrix.length = 0;
                mShaderMatrix = null;
            }

            super.dispose();
        }

        override public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MColorTween = other as MColorTween;
            if( otherAlias == null )
            {
                return false;
            }

            if( !super.equal( other ) )
            {
                return false;
            }

            return Util.comapreNumberList( mShaderMatrix, otherAlias.mShaderMatrix );
        }

        override protected function updatePass() : void
        {
            if( !hasTexture )
            {
                var pass : IPass = _inactivePasses.find( PSpriteSimple.sName );
                _passes[ 0 ] = pass;
                _orignalPass = _passes[ 0 ];
            }
            else if( mShaderMatrix.length > 0 )
            {
                pass = _inactivePasses.find( PColorMatrix.sName );
                _passes[ 0 ].texture = _texture;
                _passes[ 0 ] = pass;
                _orignalPass = pass;
            }
            else
            {
                pass = _inactivePasses.find( PColorSpriteTint.sName );
                _passes[ 0 ] = pass;
                _passes[ 0 ].texture = _texture;
                _orignalPass = pass;
            }
        }
    }
}