//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/5/16.
 */
package QFLib.Graphics.RenderCore.starling.filters
{
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.render.material.MAlpha;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class AlphaEffect extends FilterEffect
    {
        public static const Name : String = "Alpha";

        public function AlphaEffect ( pFilter : ObjectFilter )
        {
            super ( pFilter );
            m_Material = new MAlpha ();
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        [Inline] override public function get name () : String { return Name; }

        public function set alpha ( value : Number ) : void
        {
            if ( m_Material != null )
            {
                var matAlpha : MAlpha = m_Material as MAlpha;
                matAlpha.alpha = value;
            }
        }

        override public function render ( pOnwer : DisplayObject, support : RenderSupport, alpha : Number, pInTexture : Texture ) : Boolean
        {
            if ( super.render ( pOnwer, support, alpha, pInTexture ) )
            {
                var pInstance : Starling = Starling.current;
                pInstance.addToRender ( getRenderCommand() );

                return true;
            }

            return false;
        }

        override protected function getRenderCommand () : RenderCommand
        {
            var matAlpha : MAlpha = m_Material as MAlpha;
            matAlpha.mainTexture = m_pInTexture;
            return super.getRenderCommand ();
        }

        override protected function destroyMaterial () : void
        {
            var alphaMat : MAlpha = m_Material as MAlpha;
            if ( alphaMat != null )
            {
                alphaMat.dispose ();
                alphaMat = null;
            }
        }
    }
}
