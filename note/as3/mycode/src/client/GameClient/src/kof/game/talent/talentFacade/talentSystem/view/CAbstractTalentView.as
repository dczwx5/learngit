//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 14:50
 */
package kof.game.talent.talentFacade.talentSystem.view {

    import kof.game.talent.talentFacade.talentSystem.mediator.CAbstractTalentMediator;
    import kof.ui.IUICanvas;

    public class CAbstractTalentView {
        private var _parent : IUICanvas = null;
        protected var _mediator : CAbstractTalentMediator = null;

        public function CAbstractTalentView(mediator:CAbstractTalentMediator) {
            this._mediator = mediator;
        }

        public function show(data:Object=null) : void {
            throw new Error( "没有实现此方法" );
        }

        public function close() : void {
            throw new Error( "没有实现此方法" );
        }

        public function update() : void {
            throw new Error( "没有实现此方法" );
        }

        public function set parent( value : IUICanvas ) : void {
            if ( !_parent ) {
                _parent = value;
            }
        }

        public function get parent() : IUICanvas {
            return _parent;
        }
    }
}
