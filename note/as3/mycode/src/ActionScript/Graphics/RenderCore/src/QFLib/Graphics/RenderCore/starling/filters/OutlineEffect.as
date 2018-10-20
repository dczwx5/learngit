////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Graphics.RenderCore.starling.filters
{
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.render.material.MOutline;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class OutlineEffect extends FilterEffect
    {
        public static const Name : String = "Outline";
        private static var sVectorHelper : Vector.<Number> = new Vector.<Number> ( 2 );

        public function OutlineEffect ( pFilter : ObjectFilter )
        {
            super ( pFilter );
            m_Material = new MOutline ();
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        [Inline] override public function get name () : String { return Name; }

        /**
         *
         * @param color
         */
        [Inline] public function setOutlineColor ( color : Vector.<Number> ) : void
        {
            ( m_Material as MOutline ).outlineColor = color;
        }

        [Inline] public function setOutlineSize ( size : Number ) : void
        {
            m_OutlineSize = size;
            m_SizeDirty = true;
        }

        override public function render ( pOnwer : DisplayObject, support : RenderSupport, alpha : Number, pInTexture : Texture ) : Boolean
        {
            if ( super.render ( pOnwer, support, alpha, pInTexture ) )
            {
                var pInstance : Starling = Starling.current;
                pInstance.addToRender ( getRenderCommand () );

                return true;
            }
            return false;
        }

        override protected function getRenderCommand () : RenderCommand
        {
            var matOutline : MOutline = m_Material as MOutline;
            var matTexture : Texture = matOutline.mainTexture;
            var textureSizeDirty : Boolean = matTexture != null &&
                    ( matTexture.width != m_pInTexture.width || matTexture.height != m_pInTexture.height );
            matOutline.mainTexture = m_pInTexture;
            matOutline.pma = m_pInTexture.premultipliedAlpha;

            if ( m_SizeDirty || textureSizeDirty )
            {
                var texelWidth : Number = 1.0 / m_pInTexture.width;
                var texelHeight: Number = 1.0 / m_pInTexture.height;
                sVectorHelper[ 0 ] = m_OutlineSize * texelWidth;
                sVectorHelper[ 1 ] = m_OutlineSize * texelHeight;

                matOutline.uvExpand = sVectorHelper;
                m_SizeDirty = false;
            }
            return super.getRenderCommand ();
        }

        override protected function destroyMaterial () : void
        {
            var outlineMat : MOutline = m_Material as MOutline;
            if ( outlineMat != null )
            {
                outlineMat.dispose ();
                outlineMat = null;
            }
        }

        private var m_OutlineSize : Number = 1.0;
        private var m_SizeDirty : Boolean = false;
    }
}
