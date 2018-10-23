package game.view {
    import a_core.framework.CViewBean;
    import ui.MessageViewUI;

    public class CMessageView extends CViewBean {
        public function CMessageView() {

        }

        protected override function onAwake() : void {
			super.onAwake();

		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

            return ret;
		}
		protected override function onDestroy() : void {
			super.onDestroy();
		}

        protected override function _onShow() : void {
            super._onShow();
            if (!m_view) {
                m_view = new MessageViewUI();

                
            }
            uiSystem.addToTopLayer(m_view);
            m_view.txt.text = data as String;

            m_passTime = 0;
            invalidate();
        }
        public override function updateData(delta:Number) : void {
            super.updateData(delta);

            m_passTime += delta;
            if (m_passTime < 2) {
                if (m_passTime > 1) {
                    m_view.y -= delta * 100;
                }
                invalidate();
            } else {
                hide();
            }
		}

        protected override function _onHide() : void {
            super._onHide();
            uiSystem.removeTopView(m_view);
        }

        private var m_view:MessageViewUI;

        private var m_passTime:Number;
    }
}