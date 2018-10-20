package QFLib.Worker.Event
{
    public class CTextEvent extends CEvent
	{
        public function CTextEvent( sText : String = null )
        {
            m_theJson.text = sText;
        }

        public function get text() : String { return m_theJson.text; }
        public function set text( sText : String ) : void { m_theJson.text = sText; }
    }
}