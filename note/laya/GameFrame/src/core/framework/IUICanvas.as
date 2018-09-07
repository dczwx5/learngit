package core.framework
{
	import laya.ui.Box;
	import core.framework.CViewBean;
	import laya.ui.Dialog;
	/**
	 * ...
	 * @author
	 */
	public interface IUICanvas {
		function addToRoot(comp:Box) : void ;
		function addToView(comp:Box) : void ;
		function addToDialog(dialg:Dialog, closeOther:Boolean = false, showEffect:Boolean = true) : void ;
		function addToPopupDialog(dialg:Dialog, closeOther:Boolean = false, showEffect:Boolean = true) : void ;
		function addToLoading(comp:Box) : void ;

		function closeDialog(dialog:Dialog) : void ;
		
		function registry(view:CViewBean) : void;
	}

}