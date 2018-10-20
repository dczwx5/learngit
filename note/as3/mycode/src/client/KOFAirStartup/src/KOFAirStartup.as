//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package {

import QFLib.Foundation.CURLSwf;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.events.InvokeEvent;

[SWF(backgroundColor='#000000', width='1500', height='900', quality='best', frameRate='60')]
public class KOFAirStartup extends Sprite {

    public function KOFAirStartup() {
        super();

        this.init();
    }

    protected function init() : void {
        NativeApplication.nativeApplication.addEventListener( InvokeEvent.INVOKE, _onInvoke, false, 0, true );

        // Imports and run gaming bootstrap SWF.
        this.runApp();
    }

    private function _onInvoke( event : InvokeEvent ) : void {
        // parse arguments here.
    }

    protected function runApp() : void {
        var swfLoader : CURLSwf = new CURLSwf( "LoginStandalone.swf" );
        swfLoader.allowCodeImport = true;
        swfLoader.parameters = {
            'configXML': 'config.xml'
        };
        swfLoader.startLoad( _onFinished, null, null );

        function _onFinished( cf : CURLSwf, idError : int ) : void {
            if ( 0 == idError ) {
                // success
                addChild( cf.loader );
            }
        }
    }

}
}
