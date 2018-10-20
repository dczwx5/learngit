package QFLib.Worker.Event
{
    public class CStartedEvent extends CEvent
	{
        public function CStartedEvent( sName : String = null )
        {
            m_theJson.name = sName;
        }

        [Inline]
        public final function get name():String { return m_theJson.name; }
	}
}