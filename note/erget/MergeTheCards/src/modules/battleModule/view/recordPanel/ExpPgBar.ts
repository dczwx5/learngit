class ExpPgBar extends eui.Component implements  eui.UIComponent {

	private rect_bg:eui.Rect;
	private rect_value:eui.Rect;

	public constructor() {
		super();
	}

	public setProgress(curr:number, max:number){
		let percent = curr/max;
		this.rect_value.width = this.width * percent;
	}

	public set displayColor(color:number){
		this.rect_value.fillColor = color;
	}
	public set bgColor(color:number){
		this.rect_bg.fillColor = color;
	}
}
window['ExpPgBar'] = ExpPgBar;