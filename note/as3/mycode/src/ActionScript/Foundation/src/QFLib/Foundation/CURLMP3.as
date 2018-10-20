//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Foundation {

import flash.media.Sound;

public class CURLMP3 extends CURLFile {

    public function CURLMP3( sURL : String = "", sURLVersion : String = null, bLoadFileWithVersionOnly : Boolean = false, pStreamLoaderClass : Class = null ) {
        super( sURL, sURLVersion, bLoadFileWithVersionOnly, pStreamLoaderClass );
    }

    public function get soundMP3() : Sound {
        return m_pSound;
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pUrlStreamDelegater )
            m_pUrlStreamDelegater.dispose();
        m_pUrlStreamDelegater = null;
    }

    override protected function createStreamLoader() : IURLFileStream {
        m_pUrlStreamDelegater = new this.streamLoaderClass( Sound );
        this.m_pSound = m_pUrlStreamDelegater.target as Sound;
        return m_pUrlStreamDelegater;
    }

    //
    private var m_pSound : Sound;
    private var m_pUrlStreamDelegater : IURLFileStream;

}
}
