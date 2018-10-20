//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/27.
 */
package tutor.actionPackage {

import tutor.CTutorBase;

public class CActionPackageBuilder {
    public static function build(clazz:Class, tutorBase:CTutorBase, keyList:Array, contentList:Array, forcePressKey:Boolean) : CActionPackageBase {
        var builder:CActionPackageBase = new clazz;
        builder.tutorBase = tutorBase;
        builder.keyList = keyList;
        builder.contentList = contentList;
        builder.forcePressKey = forcePressKey;
        return builder;
    }
}
}
