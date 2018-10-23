class BattleMenuWindow extends App.BaseWindow {
	public readonly resources: string[] = [];

	public icon_backHome:eui.Image;
	public icon_continue:eui.Image;
	public icon_reset:eui.Image;

	public constructor() {
		super("BattleMenuWindowSkin");
	}


	protected onInit() {
	}

	protected onDestroy() {
	}
}