/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.Foundation.CMap;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Passes.PassBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.VBase;
    import QFLib.QEngine.Renderer.Textures.Texture;

    import flash.geom.Matrix3D;

    public class MFilter extends MaterialBase implements IMaterial
    {
        public function MFilter()
        {
            super( 0 );
        }

        public function set blendMode( value : String ) : void
        {
            var passes : Vector.<IPass> = _passes;
            for( var i : int = 0, l : int = passes.length; i < l; ++i )
            {
                passes[ i ].blendMode = value;
            }
        }

        public override function dispose() : void
        {

            super.dispose();
        }

        override public function clone() : IMaterial
        {
            var newMaterial : MFilter = new MFilter();
            var curr_inactivePasses : CMap = _inactivePasses;
            var new_inactivePasses : CMap = newMaterial._inactivePasses;
            for( var i : int = 0, l : int = curr_inactivePasses.count; i < l; ++i )
            {
                new_inactivePasses.add( curr_inactivePasses[ i ].name, curr_inactivePasses[ i ].clone() );
            }
            var curr_passes : Vector.<IPass> = _passes;
            var new_passes : Vector.<IPass> = newMaterial._passes;
            new_passes.length = curr_passes.length;
            for( i = 0, l = curr_passes.length; i < l; ++i )
            {
                new_passes[ new_passes.length ] = new_inactivePasses.find( curr_passes[ i ].name );
            }
            newMaterial._parentAlpha = _parentAlpha;
            newMaterial._premultiplyAlpha = _premultiplyAlpha;
            newMaterial._selfAlpha = _selfAlpha;
            newMaterial._texture = _texture;

            return newMaterial;
        }

        public function setFilterPasses( passes : Vector.<IPass>, count : int ) : void
        {
            var myPasses : Vector.<IPass> = _passes;
            //var myInactivePasses:CMap = _inactivePasses;
            myPasses.fixed = false;
            myPasses.length = count;
            myPasses.fixed = true;
            //clear old passes
            //and add new passes
            for( var i : int = 0; i < count; ++i )
            {
//				var clonePass:IPass = myInactivePasses.find(passes[i].name);
//				if(clonePass == null)
//				{
//					clonePass = passes[i].clone();
//					myInactivePasses.add(clonePass.name, clonePass);
//				}
//				else
//				{
//					clonePass.copy(passes[i]);
//				}
//				myPasses[i] = clonePass;
                //here should directly point to pass.
                myPasses[ i ] = passes[ i ];
            }
        }

        public function equal( other : IMaterial ) : Boolean
        {
            var otherAlias : MFilter = other as MFilter;
            if( otherAlias == null )
            {
                return false;
            }

            return super.innerEqual( otherAlias );
        }

        public function setRT( index : int, value : Texture ) : void
        {
            var pass : PassBase = _passes[ index ] as PassBase;
            if( pass != null )
            {
                pass.renderTarget = value;
            }
        }

        public function setTex( index : int, value : Texture ) : void
        {
            var pass : PassBase = _passes[ index ] as PassBase;
            if( pass != null )
            {
                pass.setTexture( FBase.mainTexture, value );
            }
        }

        public function setMVP( index : int, value : Matrix3D ) : void
        {
            var pass : PassBase = _passes[ index ] as PassBase;
            if( pass != null )
            {
                pass.setMatrix( VBase.matrixMVP, value );
            }
        }

        public function copySingleton() : IMaterial
        {
            return this;
        }
    }
}