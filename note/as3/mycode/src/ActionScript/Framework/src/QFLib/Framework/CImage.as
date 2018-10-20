//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Jave.Lin 2017/3/2
//----------------------------------------------------------------------------------------------------------------------
package QFLib.Framework {
import QFLib.Framework.CFramework;
import QFLib.Framework.CObject;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Graphics.RenderCore.CImageObject;
import QFLib.Graphics.RenderCore.starling.display.Image;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;
import QFLib.Node.EDirtyFlag;
import QFLib.ResourceLoader.ELoadingPriority;

/**
 * @author Jave.Lin
 * @date 2017/3/2
 */
public class CImage extends CObject
{
    public static var sEnabledSuperUpdateMatrix : Boolean = true;

    public function CImage( theBelongFramework:CFramework, bCenterAnchor : Boolean = true )
    {
        super(theBelongFramework);

        if( m_theImageObject == null ) m_theImageObject = new CImageObject( theBelongFramework.renderer, bCenterAnchor );
    }

    public override function dispose() : void
    {
        if ( m_theImageObject )
        {
            m_theImageObject.dispose();
            m_theImageObject = null;
        }
        m_fnFinished = null;
        super.dispose();
    }

    public override function set opaque( fOpaque : Number ) : void
    {
        super.opaque = fOpaque;
        m_theImageObject.opaque = fOpaque * m_fInnerOpaque;
    }

    public override function set innerOpaque( fInnerOpaque : Number ) : void
    {
        super.innerOpaque = fInnerOpaque;
        m_theImageObject.opaque = fInnerOpaque * m_fOpaque;
    }

    public override function get theObject() : CBaseObject
    {
        return m_theImageObject;
    }

    public function createByUniformColor( color : uint, w : Number, h : Number ) : void
    {
        m_theImageObject.createEmpty( w, h );
        var img : Image = m_theImageObject.renderableObject as Image;
        img.verticesColor = color;
    }

    //
    // loading functions
    // callback: function onLoadFinished( theImage : CImage, iResult : int ) : void
    //
    public function loadFile( sFilename : String, a_fnOnFinished : Function = null, a_iPriority : int = ELoadingPriority.NORMAL ) : void
    {
        m_sFilename = sFilename;
        m_fnFinished = a_fnOnFinished;
        m_theImageObject.loadFile(sFilename, _onImageObjectLoadedFinished,a_iPriority);
    }

    override public virtual function setColor(r:Number, g:Number, b:Number, alpha:Number = 1.0, masking:Boolean = false):void
    {
        super.setColor( r, g, b, alpha, masking );
        if ( m_theImageObject )
        {
            m_theImageObject.setColor( r, g, b, alpha, masking );
        }
    }
    override public function resetColor () : void
    {
        if ( m_theImageObject != null ) m_theImageObject.resetColor ();
    }

    [Inline]
    final public function get filename() : String
    {
        return m_sFilename;
    }

    public override function update( fDeltaTime : Number ) : void
    {
        super.update( fDeltaTime );
        if ( m_bEnableViewingCheckAnimation && m_bInViewRange == false ) return; // not in view range

        updateMatrix();
    }

    public override function updateMatrix( bCheckDirty : Boolean = true ) : void
    {
        if ( sEnabledSuperUpdateMatrix )
        {
            super.updateMatrix( bCheckDirty );
        }

        if (_checkDirtyFlags(EDirtyFlag.MX_FLAG_UPDATED) || bCheckDirty == false)
        {
            _unsetDirtyFlags(EDirtyFlag.MX_FLAG_UPDATED);

            // set matrix to character object
            var vPosition:CVector3 = this.position;
            var vSrcPos : CVector3 = m_theImageObject.position;
            if ( !vSrcPos.equals( vPosition ) )
            {
                m_theImageObject.setPosition3D(vPosition.x, vPosition.y, vPosition.z);
            }

            // set 2D position again due to the customized depth value,
            if( this.depth2D != 0.0 ) m_theImageObject.setPosition( m_theImageObject.x, m_theImageObject.y, this.depth2D );

            m_theImageObject.setRotation( CMath.degToRad( this.localRotation.z ) );

            var vScale : CVector3 = this.scale;
            var vSrcScale : CVector3 = m_theImageObject.scale;
            if ( vSrcScale.x != vScale.x || vSrcScale.y != vScale.y )
            {
                m_theImageObject.setScale( vScale.x, vScale.y );
            }

            if ( m_theImageObject.flipX != flipX )
            {
                m_theImageObject.flipX = this.flipX;
            }
            if ( m_theImageObject.flipY != this.flipY )
            {
                m_theImageObject.flipY = this.flipY;
            }
        }
    }

    //
    protected function _onImageObjectLoadedFinished( theImageObject: CImageObject, iErrorCode:int ):void
    {
        if( theImageObject.isLoaded )
        {
            m_theImageObject.opaque = this.opaque * this.innerOpaque;
            m_sFilename = theImageObject.filename;
            updateMatrix( false );
        }
        else
        {
            m_sFilename = null;
        }

        if( m_fnFinished != null ) m_fnFinished( this, iErrorCode );
    }

    protected var m_theImageObject : CImageObject = null;
    protected var m_sFilename : String = null;
    protected var m_fnFinished : Function = null;

}

}
