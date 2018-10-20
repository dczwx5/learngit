package QFLib.Graphics.RenderCore.render.material
{
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.pass.PColorMatrix;
    import QFLib.Graphics.RenderCore.starling.utils.Util;

    public class MColorTween extends MSprite
    {
        private static const IDENTITY : Vector.<Number> = Vector.<Number>[ 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0 ];

        private var mShaderMatrix : Vector.<Number>; // offset in range 0-1, changed order

        public function MColorTween ( passCount : int = 3 )
        {
            super ( passCount );

            mShaderMatrix = new <Number>[];

            var passColorMatrix : PColorMatrix = new PColorMatrix ();
            passColorMatrix.tintColor = _tintColor;
            passColorMatrix.maskColor = _maskColor;
            passColorMatrix.colorMatrix = mShaderMatrix;
            passColorMatrix.enable = true;
            _passes[ 3 ] = passColorMatrix;
        }

        override public function dispose () : void
        {
            if ( mShaderMatrix )
            {
                mShaderMatrix.length = 0;
                mShaderMatrix = null;
            }

            super.dispose ();
        }

        /** A vector of 20 items arranged as a 4x5 matrix. */
        public function set matrix ( value : Vector.<Number> ) : void
        {
            if ( value && value.length != 20 )
                throw new ArgumentError ( "Invalid matrix length: must be 20" );

            if ( value == null )
            {
                value = IDENTITY;
            }

            mShaderMatrix.length = 0;
            mShaderMatrix.push (
                    value[ 0 ], value[ 1 ], value[ 2 ], value[ 3 ],
                    value[ 5 ], value[ 6 ], value[ 7 ], value[ 8 ],
                    value[ 10 ], value[ 11 ], value[ 12 ], value[ 13 ],
                    value[ 15 ], value[ 16 ], value[ 17 ], value[ 18 ],
                    value[ 4 ] / 255.0, value[ 9 ] / 255.0, value[ 14 ] / 255.0, value[ 19 ] / 255.0
            );

            updatePass ();
        }

        override public function equal ( other : IMaterial ) : Boolean
        {
            if ( other == null ) return false;
            var otherAlias : MColorTween = other as MColorTween;
            if ( otherAlias == null ) return false;

            if ( !super.equal ( other ) ) return false;

            return Util.comapreNumberList ( mShaderMatrix, otherAlias.mShaderMatrix );
        }

        override protected function updatePass () : void
        {
            var pass : IPass = null;
            if ( !hasTexture )
            {
                pass = _passes[ 1 ];
            }
            else if ( mShaderMatrix.length > 0 )
            {
                pass = _passes[ 2 ];
                pass.mainTexture = _mainTexture;
            }
            else
            {
                pass = _passes[ 0 ];
                pass.mainTexture = _mainTexture;
            }

            setPassEnable ( pass.name, true, true );
        }
    }
}