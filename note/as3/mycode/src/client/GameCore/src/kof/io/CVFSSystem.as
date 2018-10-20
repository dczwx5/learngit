//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.io {

import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.framework.vfs.CActionScript3File;
import kof.framework.vfs.IFile;

/**
 * Virtual File System
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CVFSSystem extends CAppSystem {

    public function CVFSSystem() {
        super();
    }

    override protected virtual function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        return ret;
    }

    override protected function enterStage(appStage:CAppStage):void {
        super.enterStage(appStage);
    }

    public function getFile(path:String):IFile {
        var as3File:CActionScript3File = CActionScript3File.createWithVFS(stage.vfs, path);

        return as3File;
    }

}
}
