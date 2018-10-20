package QFLib.Worker.Event
{
    public class CStartEvent extends CEvent
	{
        public function CStartEvent( sName : String = null, sFilename : String = null )
        {
            m_theJson.name = sName;
            m_theJson.filename = sFilename;
        }

        [Inline]
        public final function get name():String { return m_theJson.name; }
        [Inline]
        public final function get filename():String { return m_theJson.filename; }
	}
}