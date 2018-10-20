package QFLib.ResourceLoader.Worker
{
    import QFLib.Worker.Event.*;

    import flash.utils.ByteArray;

    public class CFileCheckRequestEvent extends CEvent
	{
        public function CFileCheckRequestEvent()
        {
        }

        public function set( iLoaderID : int, sFilename : String, sChecksum : String, aBytes : ByteArray ) : void
        {
            this.loaderID = iLoaderID;
            this.filename = sFilename;
            this.checksum = sChecksum;
            this.setByteArray( 0, aBytes );
        }

        public function get loaderID() : int { return m_theJson.loaderID; }
        public function set loaderID( iID : int ) : void { m_theJson.loaderID = iID; }

        public function get filename() : String { return m_theJson.filename; }
        public function set filename( sFilename : String ) : void { m_theJson.filename = sFilename; }

        public function get checksum() : String { return m_theJson.checksum; }
        public function set checksum( sChecksum : String ) : void { m_theJson.checksum = sChecksum; }

    }
}