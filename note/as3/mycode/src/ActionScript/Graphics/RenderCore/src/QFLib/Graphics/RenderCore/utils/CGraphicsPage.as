/**
 * Created by burgess on 2017/6/2.
 */
package QFLib.Graphics.RenderCore.utils {
import QFLib.DashBoard.CDashBoard;
import QFLib.DashBoard.CDashPage;
import QFLib.Graphics.RenderCore.starling.core.Starling;
import QFLib.Graphics.RenderCore.starling.utils.RenderTexturePool;

import flash.text.TextField;

public class CGraphicsPage extends CDashPage
{

    public function CGraphicsPage( theDashBoard : CDashBoard )
    {
        super( theDashBoard );

        m_theResourceText = new TextField();
        m_theResourceText.defaultTextFormat.font = "Terminal";
        m_theResourceText.textColor = 0xFFFFFF;
        m_theResourceText.wordWrap = true;
        m_theResourceText.multiline = true;
        m_theResourceText.border = true;
        m_theResourceText.borderColor = 0xFFFFFF;
        m_theResourceText.scrollV = m_theResourceText.numLines;
        m_thePageSpriteRoot.addChild( m_theResourceText );
    }

    public override function dispose() : void
    {
        super.dispose();
    }

    public override function get name() : String
    {
        return "GraphicsPage";
    }

    public override function onResize() : void
    {
        super.onResize();

        m_theResourceText.x = m_theDashBoardRef.pageX + 10;
        m_theResourceText.y = m_theDashBoardRef.pageY + 10;
        m_theResourceText.width = m_theDashBoardRef.pageWidth - 20 - 160 - 10;
        m_theResourceText.height = m_theDashBoardRef.pageHeight - 20;
    }

    public override function update( fDeltaTime : Number ) : void
    {
        super.update( fDeltaTime );

        m_fUpdateTime += fDeltaTime;
        if( m_fUpdateTime > m_fUpdatePeriod )
        {
            m_theStarling = Starling.current;
            m_theResourceText.htmlText = "draw call : " + m_theStarling.drawCall.toString() + "\n"
            + "index buffer count : " + m_theStarling.indexBufferCount.toString() + "               vertex buffer count : " + m_theStarling.vertexBufferCount.toString() + "\n"
            + RenderTexturePool.instance().renderTextureState;


//            sContext += "\n";

            m_fUpdateTime %= m_fUpdatePeriod;
        }
    }
    //
    //
    protected var m_theStarling : Starling = null;
    protected var m_theResourceText : TextField = null;
    protected var m_fUpdateTime : Number = 0.0;
    protected var m_fUpdatePeriod : Number = 0.1;
}
}
