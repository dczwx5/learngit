package game.view
{
	import laya.ui.DialogManager;
	import laya.ui.Dialog;

	/**
	 * ...
	 * @author
	 */
	public class CDialogLayer extends DialogManager {
		public function CDialogLayer(){
			
		}

		/**
		 * 显示对话框(非模式窗口类型)。
		 * @param dialog 需要显示的对象框 <code>Dialog</code> 实例。
		 * @param closeOther 是否关闭其它对话框，若值为ture，则关闭其它的对话框。
		 * @param showEffect 是否显示弹出效果
		 */
		public override function open(dialog:Dialog, closeOther:Boolean = false, showEffect:Boolean=false):void {
			/**(*if (closeOther) _closeAll();
			if (dialog.popupCenter) _centerDialog(dialog);
			addChild(dialog);
			if (dialog.isModal || this._$P["hasZorder"]) timer.callLater(this, _checkMask);
			if (showEffect && dialog.popupEffect != null) dialog.popupEffect.runWith(dialog);
			else doOpen(dialog);
			event(Event.OPEN);*/
			super.open(dialog, closeOther, showEffect);
		}

		/**
		 * 关闭对话框。
		 * @param dialog 需要关闭的对象框 <code>Dialog</code> 实例。
		 * @param type	关闭的类型，默认为空
		 * @param showEffect 是否显示弹出效果
		 */
		public override function close(dialog:Dialog, type:String = null, showEffect:Boolean=false):void {
			// if (showEffect && dialog.closeEffect != null) dialog.closeEffect.runWith([dialog, type]);
			// else doClose(dialog, type);
			// event(Event.CLOSE);
			super.close(dialog, type, showEffect);
		}
	}

}