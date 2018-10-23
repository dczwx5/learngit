class HelpWindow extends App.BaseWindow {
	readonly resources: string[] = [];

	public btn_close:eui.Image;
	public lb_context:eui.Label;

	public constructor() {
		super("HelpWindowSkin");
	}

	protected partAdded(partName:string,instance:any):void
	{
		super.partAdded(partName,instance);
	}

	protected childrenCreated():void
	{
		super.childrenCreated();
	}

	protected onInit() {
	}

	protected onDestroy() {
	}


}