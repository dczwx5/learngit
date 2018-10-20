//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.handler {

import QFLib.Framework.CFramework;

import kof.game.core.CGameSystemHandler;
import kof.game.scene.ISceneFacade;
import kof.util.CAssertUtils;

/**
 * 用于渲染调用，永远位于最后调用在每一帧
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CRenderHandler extends CGameSystemHandler {

    private var m_pFramework : CFramework;

    public function CRenderHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        m_pFramework = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            var v_pSceneFacade : ISceneFacade = this.system.stage.getSystem( ISceneFacade ) as ISceneFacade;
            if ( v_pSceneFacade ) {
                m_pFramework = v_pSceneFacade.scenegraph.graphicsFramework;
            }
            CAssertUtils.assertNotNull( m_pFramework, "CFramework needed in CRenderHandler." );
            m_pFramework.autoRendering = false;
        }

        return ret;
    }

    override public function afterTick( delta : Number ) : void {
        super.afterTick( delta );

        if ( !m_pFramework )
            return;

        m_pFramework.render( /*delta*/ );
    }


}
}
