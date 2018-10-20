//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package tutor {

import action.CActionBase;
import action.CActionCommon;
import action.EKeyCode;
import config.CPathConfig;
import morn.core.handlers.Handler;
import tutor.actionPackage.CActionPackageBase;
import tutor.actionPackage.CActionPackageBuilder;
import tutor.actionPackage.CDescPackage;
import tutor.actionPackage.CFlyUIPackage;
import tutor.actionPackage.CQtePackage;
import view.CQTEViewHandler;

public class CTutor1002 extends CTutorBase {
    protected var _key:String;
    protected var _keyDescContent:String;

    public function CTutor1002() {

    }

    protected override function onInitialize() : void {
        _key = EKeyCode.J;

        // hide skill panel
        battleTutor.instanceHelper.uploadData(CPathConfig.STEP_200);
        
        var changeDirAct:CActionBase = new CActionCommon();
        changeDirAct.addStartHandler(new Handler(battleTutor.actorHelper.turnRight));
        this.addAction(changeDirAct);

        var pauseAct:CActionBase = new CActionCommon();
//        pauseAct.addStartHandler(new Handler(battleTutor.actorHelper.slowGame));
        this.addAction(pauseAct);

        var packageDesc:CDescPackage = CActionPackageBuilder.build(CDescPackage, this, null, null, false) as CDescPackage;
        packageDesc._uploadGuideStep1 = CPathConfig.STEP_205;
        packageDesc._audioID = CPathConfig.AUDIO_4;
        packageDesc._descIndex = 1;
        var keyDescAct:CActionBase = packageDesc.buildAction();
        this.addAction(keyDescAct);



        var forcePressKey:Boolean = true;
        var qtePackage:CActionPackageBase = CActionPackageBuilder.build(CQtePackage, this, [_key], null, forcePressKey);
        qtePackage._uploadGuideStep1 = CPathConfig.STEP_210;
        qtePackage.totalPressCount = 1;
        qtePackage._showJClip = true;
        var qteAct:CActionBase = qtePackage.buildAction();
        this.addAction(qteAct);

        var flyAct:CActionBase = CActionPackageBuilder.build(CFlyUIPackage, this, [EKeyCode.J], null, forcePressKey).buildAction();
        flyAct.addFinishHandler(new Handler(battleTutor.viewHelper.hideView, [CQTEViewHandler]));
        flyAct.addFinishHandler(new Handler(battleTutor.instanceHelper.uploadData, [CPathConfig.STEP_220]));
        this.addAction(flyAct);

    }
}
}
