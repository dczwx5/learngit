//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/9.
 */
package kof.game.platform {

public class CPlatformFunctionData {
    public function CPlatformFunctionData(platform:String, dataClass:Class, signatureRenderClass:Class, getSignatureViewClass:Class) {
        this.signatureRenderClass = signatureRenderClass;
        this.platform = platform;
        this.dataClass = dataClass;
        this.dataClass = dataClass;
        this.getSignatureViewClass = getSignatureViewClass;

    }

    public var signatureRenderClass:Class;
    public var getSignatureViewClass:Class;
    public var platform:String;
    public var dataClass:Class;
}
}
