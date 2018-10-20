//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Dan 2017/3/13
//----------------------------------------------------------------------------------------------------------------------
package QFLib.Framework {

    import QFLib.Foundation;
    import QFLib.Graphics.Sprite.CSpriteText;

//
//
//
public class CText extends CImage
{

    public function CText( theBelongFramework:CFramework, fWidth : Number, fHeight : Number, bCenterAnchor : Boolean = false )
    {
        m_theImageObject = new CSpriteText( theBelongFramework.spriteSystem, fWidth, fHeight, bCenterAnchor );
        super( theBelongFramework );
        if( m_theImageObject is CSpriteText == false )
        {
            Foundation.Log.logErrorMsg( "CText: m_theImageObject should be a CSpriteText" );
            m_theImageObject.dispose();
            m_theImageObject = new CSpriteText( theBelongFramework.spriteSystem, fWidth, fHeight, bCenterAnchor );
        }
    }

    public override function dispose() : void
    {
        super.dispose();
    }

    public function get spriteText() : CSpriteText
    {
        return m_theImageObject as CSpriteText;
    }

    //
}

}
