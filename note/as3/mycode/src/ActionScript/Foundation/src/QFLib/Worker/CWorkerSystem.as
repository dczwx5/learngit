package QFLib.Worker
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.ResourceLoader.CBaseLoader;
    import QFLib.ResourceLoader.CByteArrayLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;
import QFLib.Utils.CFlashVersion;

import flash.system.Worker;
    import flash.utils.ByteArray;

    public class CWorkerSystem
	{
		public function CWorkerSystem()
		{
		}

        public function dispose() : void
        {
        }

        public function get isWorkerSupported() : Boolean
        {
            return Worker.isSupported;
        }

        //
        // function onWorkerStartFinished( sName : String, sFilename : String, theWorkerRef : CWorkerRef, idErrorCode : int ) : void
        //
        public function createWorker( sName : String, sSWFFilename : String, fnOnWorkerStartFinished : Function,
                                        iPriority : int = ELoadingPriority.NORMAL, bSuppressLoadErrorMsg : Boolean = false, bAutoStart : Boolean = true ) : Boolean
        {
            if( this.isWorkerSupported == false )
            {
                if( bSuppressLoadErrorMsg == false ) Foundation.Log.logErrorMsg( "Worker system is not supported!" );
                return false;
            }
            if( CFlashVersion.isPlayerVersionPriorOrEqualTo( 11, 4 ) )
            {
                if( bSuppressLoadErrorMsg == false ) Foundation.Log.logErrorMsg( "Flash version(" + CFlashVersion.getPlayerVersion() + ") is too old to support mutex object!" );
                return false;
            }

            CResourceLoaders.instance().startLoadFile( sSWFFilename, _onSWFLoadFinished, CByteArrayLoader.NAME, iPriority, bSuppressLoadErrorMsg, false, null, sName, fnOnWorkerStartFinished, bAutoStart );
            m_mapWorkerSWFs.add( sName, sSWFFilename );
            return true;
        }

        //
        private function _onSWFLoadFinished( loader : CBaseLoader, idErrorCode : int ) : void
        {
            var sName : String = loader.arguments[ 0 ];
            var fnOnWorkerStartFinished : Function = loader.arguments[ 1 ];
            var bAutoStart : Boolean = loader.arguments[ 2 ];

            if( idErrorCode == 0 )
            {
                var theSWFResource : CResource = loader.createResource();
                if( theSWFResource == null )
                {
                    Foundation.Log.logErrorMsg( "_onSWFLoadFinished(): cannot get SWF data(null): " + loader.loadingFilename );
                    return ;
                }

                var aBytes : ByteArray = theSWFResource.theObject as ByteArray;

                var theWorkerRef : CWorkerRef = new CWorkerRef();
                if( theWorkerRef._initialize( sName, loader.loadingFilename, aBytes, fnOnWorkerStartFinished ) == false )
                {
                    if( fnOnWorkerStartFinished != null ) fnOnWorkerStartFinished( sName, loader.loadingFilename, null, -1 );
                }
                else
                {
                    m_mapWorkers.add( sName, theWorkerRef );
                    theSWFResource.dispose();

                    if( bAutoStart ) theWorkerRef.start();
                    else
                    {
                        if( fnOnWorkerStartFinished != null ) fnOnWorkerStartFinished( sName, loader.loadingFilename, theWorkerRef, 0 );
                    }
                }
            }
            else
            {
                if( fnOnWorkerStartFinished != null ) fnOnWorkerStartFinished( sName, loader.loadingFilename, null, idErrorCode );
            }
        }

        //
        private var m_mapWorkerSWFs : CMap = new CMap();
        private var m_mapWorkers : CMap = new CMap();
	}
}