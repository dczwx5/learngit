package a_core.framework
{
	import laya.ui.Box;
	import a_core.framework.CViewBean;
	import laya.ui.Dialog;
	import laya.ui.View;
	import laya.display.Sprite;
	/**
	 * ...
	 * @author
	 */
	public interface IUICanvas {
		function addToRoot(comp:Sprite) : void ;
		function addToView(comp:Sprite) : void ;
		function addToDialog(dialg:Dialog, closeOther:Boolean = false, showEffect:Boolean = true) : void ;
		function addToPopupDialog(dialg:Dialog, closeOther:Boolean = false, showEffect:Boolean = true) : void ;
		function addToLoading(comp:Sprite) : void ;

		function closeDialog(dialog:Dialog) : void ;
		function removeView(view:Sprite) : void ;

		function registry(view:CViewBean) : void;
	}

}