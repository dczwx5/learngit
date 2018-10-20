package QFLib.ResourceLoader.Worker
{
    import QFLib.Worker.Event.*;

    import flash.utils.ByteArray;

    public class CFileCheckResponseEvent extends CEvent
	{
        public function CFileCheckResponseEvent()
        {
        }

        public function set( iLoaderID : int, sFilename : String, iResult : int ) : void
        {
            this.loaderID = iLoaderID;
            this.filename = sFilename;
            this.result = iResult;
        }

        public function get loaderID() : int { return m_theJson.loaderID; }
        public function set loaderID( iID : int ) : void { m_theJson.loaderID = iID; }

        public function get filename() : String { return m_theJson.filename; }
        public function set filename( sFilename : String ) : void { m_theJson.filename = sFilename; }

        public function get result() : int { return m_theJson.result; }
        public function set result( iResult : int ) : void { m_theJson.result = iResult; }
    }
}